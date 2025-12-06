from app.schemas import ModelPrediction
import asyncio
import random
import time


class PredictService:

    _PREDICTION_LABELS = [
        "Matang",
        "Setengah Matang",
        "Belum Matang",
    ]

    @staticmethod
    async def _simulate_model_prediction(model_name: str) -> ModelPrediction:
        """Memberikan hasil prediksi palsu dengan menunggu beberapa saat."""
        start = time.perf_counter()
        await asyncio.sleep(random.uniform(0.7, 1.6))
        duration_ms = int((time.perf_counter() - start) * 1000)

        return ModelPrediction(
            model=model_name,
            label=random.choice(PredictService._PREDICTION_LABELS),
            confidence=round(random.uniform(0.65, 0.98), 3),
            duration_ms=duration_ms,
        )

    @staticmethod
    async def predict_knn() -> ModelPrediction:
        return await PredictService._simulate_model_prediction("KNN")

    @staticmethod
    async def predict_svm() -> ModelPrediction:
        return await PredictService._simulate_model_prediction("SVM")
