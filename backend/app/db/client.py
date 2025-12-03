# app/db/client.py (Kode yang Diperbaiki)

from supabase import create_client, Client
# Hapus impor ClientOptions jika tidak diperlukan
from app.configs import settings 

# Inisialisasi Klien Supabase
# Cukup panggil create_client dengan URL dan Kunci
supabase: Client = create_client(
    settings.SUPABASE_URL, 
    settings.SUPABASE_KEY
    # TIDAK PERLU ARGUMEN 'options=ClientOptions(...)' jika tidak ada opsi lain
    # yang perlu diatur. Argumen storage_key akan diambil secara otomatis 
    # oleh klien storage itu sendiri jika klien utama sudah benar.
)

# Ambil klien Storage
storage_client = supabase.storage

# Ambil klien Database
db_client = supabase.table

# Fungsi ini dapat dipanggil oleh service layer
def get_supabase_clients():
    return storage_client, db_client