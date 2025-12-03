# app/routes/upload.py
from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services import storage
from app.schemas import UploadResult, HealthCheck

router = APIRouter(tags=["Upload & Health"])

@router.get("/health", response_model=HealthCheck)
async def check_health():
    """Memeriksa status API."""
    return {"status": "OK"}

@router.post("/upload", response_model=UploadResult)
async def upload_chili_image(
    file: UploadFile = File(...)
):
    """
    Mengunggah gambar cabai, menyimpannya ke Supabase Storage,
    dan mencatat metadata ke Supabase DB.
    """
    try:
        # Panggil Service Layer
        upload_data = await storage.upload_file_to_supabase(file)

        # Gabungkan hasil untuk respons API
        return UploadResult(
            filename=upload_data['stored_filename'],
            public_url=upload_data['public_url']
        )
    except Exception as e:
        # Menangkap error dari service dan mengembalikan HTTP 500
        raise HTTPException(
            status_code=500, 
            detail=str(e)
        )

# Placeholder untuk Route Prediksi (Akan Diisi Nanti)
@router.post("/predict")
async def run_prediction_placeholder():
    return {"status": "pending", "message": "Logika Prediksi Belum Diimplementasikan."}