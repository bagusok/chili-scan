# app/main.py
from fastapi import FastAPI
from app.routes import predict

# Inisialisasi Aplikasi FastAPI
app = FastAPI(
    title="Modular Chili Ripeness Detector API",
    description="API untuk deteksi kematangan cabai dengan FastAPI dan Supabase.",
    version="1.0.0",
    docs_url="/docs",      # Swagger UI akan tersedia di http://127.0.0.1:8000/docs
    redoc_url="/redoc"     # ReDoc akan tersedia di http://127.0.0.1:8000/redoc
)

# Memasukkan semua Routes/Controllers ke dalam aplikasi
app.include_router(predict.router)

if __name__ == "__main__":
    import uvicorn
    # Jalankan server
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)