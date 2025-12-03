# app/config.py
import os
from dotenv import load_dotenv

# Muat variabel dari .env
load_dotenv()

class Settings:
    """Mengelola semua variabel lingkungan."""
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    SUPABASE_BUCKET: str = os.getenv("SUPABASE_BUCKET", "default-bucket")

# Instance Settings yang akan diimpor
settings = Settings()

# Pengecekan dasar
if not settings.SUPABASE_URL or not settings.SUPABASE_KEY:
    raise ValueError("SUPABASE_URL atau SUPABASE_KEY tidak ditemukan.")