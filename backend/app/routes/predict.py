import asyncio
import random
import time
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
import uuid
from app.db.client import get_supabase_clients
from app.services import storage
from app.schemas import (
    UploadResult,
    HealthCheck,
    ModelPrediction,
    PredictHistory,
    BaseResponse,
)
from app.middlewares.auth import verify_supabase_token
from app.services.predict_service import PredictService

router = APIRouter(tags=["Upload & Health"])

_, db_client = get_supabase_clients()


@router.get("/health", response_model=HealthCheck)
async def check_health():
    """Memeriksa status API."""
    return {"status": "OK"}


# @router.post(
#     "/upload",
#     response_model=UploadResult,
#     dependencies=[Depends(verify_supabase_token)],
# )
# async def upload_chili_image(
#     file: UploadFile = File(...)
# ):
#     """
#     Mengunggah gambar cabai, menyimpannya ke Supabase Storage,
#     dan mencatat metadata ke Supabase DB.
#     """
#     try:
#         # Panggil Service Layer
#         upload_data = await storage.upload_file_to_supabase(file)

#         # Gabungkan hasil untuk respons API
#         return UploadResult(
#             filename=upload_data['stored_filename'],
#             public_url=upload_data['public_url']
#         )
#     except Exception as e:
#         # Menangkap error dari service dan mengembalikan HTTP 500
#         raise HTTPException(
#             status_code=500,
#             detail=str(e)
#         )


@router.post(
    "/predict",
    response_model=BaseResponse[PredictHistory],
    dependencies=[Depends(verify_supabase_token)],
)
async def run_prediction(
    file: UploadFile = File(...), user: dict = Depends(verify_supabase_token)
):
    """Unggah gambar cabai asli lalu simulasi prediksi KNN & SVM."""
    try:
        upload_data = await storage.upload_file_to_supabase(file)

        knn_prediction, svm_prediction = await asyncio.gather(
            PredictService.predict_knn(),
            PredictService.predict_svm(),
        )

        save_to_db = (
            db_client("predict_history")
            .insert(
                {
                    "user_id": user["user_id"],
                    "image_url": upload_data["public_url"],
                    "svm_result": svm_prediction.label,
                    "knn_result": knn_prediction.label,
                    "statistics": {
                        "svm": {
                            "confidence": svm_prediction.confidence,
                            "duration_ms": svm_prediction.duration_ms,
                        },
                        "knn": {
                            "confidence": knn_prediction.confidence,
                            "duration_ms": knn_prediction.duration_ms,
                        },
                    },
                }
            )
            .execute()
        )

        print(save_to_db)

        return BaseResponse[PredictHistory](
            success=True,
            message="Prediksi berhasil dijalankan.",
            data=PredictHistory(**save_to_db.data[0]),
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
