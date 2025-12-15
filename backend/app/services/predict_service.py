from app.schemas import ModelPrediction
import asyncio
import time
from pathlib import Path
import cv2
import joblib
import numpy as np
from skimage import measure
from skimage.feature import graycomatrix, graycoprops


class PredictService:
    """Service untuk melakukan prediksi dengan model SVM dan KNN"""

    _MODELS = {}
    _MODEL_DIR = Path(__file__).parent.parent.parent / "models"
    _IMG_SIZE = (224, 224)
    _CLAHE = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    _INITIALIZED = False

    @classmethod
    def _load_models(cls):
        """Load model SVM dan KNN saat pertama kali digunakan"""
        if cls._INITIALIZED:
            return

        for model_type in ["svm", "knn"]:
            model_path = cls._MODEL_DIR / f"{model_type}_model.pkl"

            if not model_path.exists():
                raise FileNotFoundError(
                    f"Model {model_type.upper()} tidak ditemukan di: {model_path}"
                )

            model_artifacts = joblib.load(model_path)

            cls._MODELS[model_type] = {
                "model": model_artifacts["model"],
                "scaler": model_artifacts["scaler"],
                "pca": model_artifacts["pca"],
                "label_encoder": model_artifacts["label_encoder"],
                "class_names": model_artifacts["class_names"],
            }

        cls._INITIALIZED = True

    # ==================== PREPROCESSING FUNCTIONS ====================

    @staticmethod
    def _gray_world_white_balance(img_bgr: np.ndarray) -> np.ndarray:
        """Melakukan white balance menggunakan algoritma Gray World"""
        img = img_bgr.astype(np.float32)
        avg_bgr = img.mean(axis=(0, 1))
        gray_val = avg_bgr.mean()
        scale = gray_val / (avg_bgr + 1e-6)
        balanced = img * scale
        balanced = np.clip(balanced, 0, 255).astype(np.uint8)
        return balanced

    @staticmethod
    def _keep_largest_component(binary_mask: np.ndarray) -> np.ndarray:
        """Mempertahankan komponen terbesar dari mask biner"""
        labels = measure.label(binary_mask, connectivity=2)
        if labels.max() == 0:
            return binary_mask
        counts = np.bincount(labels.ravel())
        counts[0] = 0
        largest = counts.argmax()
        mask = (labels == largest).astype(np.uint8) * 255
        return mask

    @staticmethod
    def _build_fruit_mask(hsv_img: np.ndarray) -> np.ndarray:
        """Membangun mask untuk mengisolasi buah dari background"""
        bg_green = cv2.inRange(hsv_img, (30, 40, 0), (90, 255, 200))
        bg_brown = cv2.inRange(hsv_img, (5, 30, 0), (25, 200, 150))
        background = cv2.bitwise_or(bg_green, bg_brown)

        fruit_candidate = cv2.inRange(hsv_img, (0, 40, 40), (179, 255, 255))
        mask = cv2.bitwise_and(fruit_candidate, cv2.bitwise_not(background))

        kernel = np.ones((7, 7), np.uint8)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=1)
        mask = PredictService._keep_largest_component(mask)
        return mask

    @staticmethod
    def _mask_aware_crop(img: np.ndarray, mask: np.ndarray, pad_ratio: float = 0.05):
        """Crop gambar berdasarkan mask dengan padding"""
        ys, xs = np.where(mask > 0)
        if len(xs) == 0 or len(ys) == 0:
            fallback_mask = np.ones(img.shape[:2], dtype=np.uint8) * 255
            return img.copy(), fallback_mask
        x_min, x_max = xs.min(), xs.max()
        y_min, y_max = ys.min(), ys.max()
        h, w = img.shape[:2]
        pad_x = int((x_max - x_min) * pad_ratio)
        pad_y = int((y_max - y_min) * pad_ratio)
        x_min = max(x_min - pad_x, 0)
        x_max = min(x_max + pad_x, w)
        y_min = max(y_min - pad_y, 0)
        y_max = min(y_max + pad_y, h)
        cropped_img = img[y_min:y_max, x_min:x_max]
        cropped_mask = mask[y_min:y_max, x_min:x_max]
        return cropped_img, cropped_mask

    @classmethod
    def _preprocess_image(cls, img_bgr: np.ndarray) -> dict:
        """Preprocessing lengkap untuk gambar input"""
        wb = cls._gray_world_white_balance(img_bgr)
        denoised = cv2.bilateralFilter(wb, d=9, sigmaColor=75, sigmaSpace=75)

        hsv = cv2.cvtColor(denoised, cv2.COLOR_BGR2HSV)
        mask = cls._build_fruit_mask(hsv)

        cropped_bgr, cropped_mask = cls._mask_aware_crop(denoised, mask)
        resized_bgr = cv2.resize(cropped_bgr, cls._IMG_SIZE)
        resized_mask = cv2.resize(
            cropped_mask, cls._IMG_SIZE, interpolation=cv2.INTER_NEAREST
        )

        hsv_resized = cv2.cvtColor(resized_bgr, cv2.COLOR_BGR2HSV)
        hsv_resized[:, :, 2] = cls._CLAHE.apply(hsv_resized[:, :, 2])
        enhanced_bgr = cv2.cvtColor(hsv_resized, cv2.COLOR_HSV2BGR)

        gray = cv2.cvtColor(enhanced_bgr, cv2.COLOR_BGR2GRAY)
        gray_equalized = cv2.equalizeHist(gray)

        return {
            "mask": resized_mask,
            "enhanced": enhanced_bgr,
            "hsv": hsv_resized,
            "gray_equalized": gray_equalized,
        }

    # ==================== FEATURE EXTRACTION FUNCTIONS ====================

    @staticmethod
    def _extract_hsv_features(hsv_img: np.ndarray, bins: int = 16) -> np.ndarray:
        """Ekstraksi fitur histogram HSV"""
        h_hist = cv2.calcHist([hsv_img], [0], None, [bins], [0, 180])
        s_hist = cv2.calcHist([hsv_img], [1], None, [bins], [0, 256])
        v_hist = cv2.calcHist([hsv_img], [2], None, [bins], [0, 256])
        hist = np.concatenate([h_hist.flatten(), s_hist.flatten(), v_hist.flatten()])
        hist = hist / (hist.sum() + 1e-6)
        return hist.astype(np.float32)

    @staticmethod
    def _extract_ccd_features(mask: np.ndarray, num_points: int = 32) -> np.ndarray:
        """Ekstraksi fitur Centroid Contour Distance"""
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
        if not contours:
            return np.zeros(num_points, dtype=np.float32)
        cnt = max(contours, key=cv2.contourArea)
        moments = cv2.moments(cnt)
        if moments["m00"] == 0:
            return np.zeros(num_points, dtype=np.float32)

        cx = moments["m10"] / moments["m00"]
        cy = moments["m01"] / moments["m00"]
        centroid = np.array([cx, cy])
        points = cnt.reshape(-1, 2)

        vectors = points - centroid
        radii = np.linalg.norm(vectors, axis=1)
        angles = (np.arctan2(vectors[:, 1], vectors[:, 0]) + 2 * np.pi) % (2 * np.pi)

        bins = np.linspace(0, 2 * np.pi, num_points + 1)
        descriptor = np.zeros(num_points, dtype=np.float32)
        for i in range(num_points):
            mask_angle = (angles >= bins[i]) & (angles < bins[i + 1])
            if np.any(mask_angle):
                descriptor[i] = radii[mask_angle].max()
        if descriptor.max() > 0:
            descriptor /= descriptor.max()
        return descriptor

    @staticmethod
    def _extract_glcm_features(gray_img: np.ndarray, mask: np.ndarray) -> np.ndarray:
        """Ekstraksi fitur Gray Level Co-occurrence Matrix"""
        masked = cv2.bitwise_and(gray_img, gray_img, mask=mask)
        glcm = graycomatrix(
            masked,
            distances=[1, 2, 3],
            angles=[0, np.pi / 4, np.pi / 2, 3 * np.pi / 4],
            levels=256,
            symmetric=True,
            normed=True,
        )
        props = []
        for prop in ("contrast", "correlation", "energy", "homogeneity"):
            props.extend(graycoprops(glcm, prop).flatten())
        return np.array(props, dtype=np.float32)

    @classmethod
    def _extract_features(cls, img_bgr: np.ndarray) -> np.ndarray:
        """Ekstraksi semua fitur dari gambar"""
        processed = cls._preprocess_image(img_bgr)
        hsv_feat = cls._extract_hsv_features(processed["hsv"])
        gray = cv2.cvtColor(processed["enhanced"], cv2.COLOR_BGR2GRAY)
        glcm_feat = cls._extract_glcm_features(gray, processed["mask"])
        ccd_feat = cls._extract_ccd_features(processed["mask"])
        return np.concatenate([hsv_feat, ccd_feat, glcm_feat])

    # ==================== PREDICTION FUNCTIONS ====================

    @classmethod
    async def _predict_with_model(
        cls, img_bgr: np.ndarray, model_type: str
    ) -> ModelPrediction:
        """Melakukan prediksi menggunakan model tertentu (svm atau knn)"""
        # Load models jika belum
        cls._load_models()

        start = time.perf_counter()

        # Ekstraksi fitur (operasi CPU-heavy, jadi kita run di thread pool)
        loop = asyncio.get_event_loop()
        features = await loop.run_in_executor(None, cls._extract_features, img_bgr)
        features = features.reshape(1, -1)

        # Get model artifacts
        artifacts = cls._MODELS[model_type]

        # Scaling
        features_scaled = artifacts["scaler"].transform(features)

        # PCA transform
        features_pca = artifacts["pca"].transform(features_scaled)

        # Prediksi
        prediction = artifacts["model"].predict(features_pca)[0]
        predicted_class = artifacts["label_encoder"].inverse_transform([prediction])[0]

        # Probabilitas (jika model support)
        if hasattr(artifacts["model"], "predict_proba"):
            proba = artifacts["model"].predict_proba(features_pca)[0]
            confidence = float(proba.max())
        else:
            confidence = 1.0

        duration_ms = int((time.perf_counter() - start) * 1000)

        return ModelPrediction(
            model=model_type.upper(),
            label=predicted_class,
            confidence=round(confidence, 3),
            duration_ms=duration_ms,
        )

    @classmethod
    async def predict_knn(cls, img_bgr: np.ndarray) -> ModelPrediction:
        """Prediksi menggunakan model KNN"""
        return await cls._predict_with_model(img_bgr, "knn")

    @classmethod
    async def predict_svm(cls, img_bgr: np.ndarray) -> ModelPrediction:
        """Prediksi menggunakan model SVM"""
        return await cls._predict_with_model(img_bgr, "svm")
