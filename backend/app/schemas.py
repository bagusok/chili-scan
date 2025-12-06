# app/schemas.py
from typing import Generic, TypeVar, Optional, List

from pydantic import BaseModel


class UploadResult(BaseModel):
    """Skema untuk hasil output setelah upload berhasil."""

    filename: str
    public_url: str


class HealthCheck(BaseModel):
    status: str


class ModelPrediction(BaseModel):
    """Representasi sederhana hasil prediksi per model."""

    model: str
    label: str
    confidence: float
    duration_ms: int


T = TypeVar("T")


class BaseResponse(BaseModel, Generic[T]):
    success: bool
    message: str
    data: Optional[T] = None


class ModelStats(BaseModel):
    confidence: float
    duration_ms: int


class PredictionStatistics(BaseModel):
    knn: ModelStats
    svm: ModelStats


class PredictHistory(BaseModel):
    id: str
    user_id: str
    image_url: str
    svm_result: str
    knn_result: str
    statistics: PredictionStatistics
    created_at: str
