# app/services/storage.py
import uuid
import os
from fastapi import UploadFile
from app.db.client import get_supabase_clients
from app.configs import settings  # Ganti app.configs menjadi app.config

storage_client, db_client = get_supabase_clients()


async def upload_file_to_supabase(file: UploadFile):
    """
    Mengunggah file ke Supabase Storage, mengganti nama file menjadi UUID,
    dan menyimpan metadata di Supabase DB.
    """

    # Baca seluruh konten file (ini menghasilkan tipe 'bytes')
    file_content: bytes = await file.read()

    # 1. GENERASI NAMA FILE BARU (UUID)
    # ---
    # Pisahkan nama file asli dari ekstensinya
    original_filename, file_extension = os.path.splitext(file.filename)

    # Buat UUID unik baru
    new_uuid = uuid.uuid4()

    # Gabungkan UUID dengan ekstensi asli
    new_filename = f"{new_uuid}{file_extension}"

    # Tentukan path file di Supabase Storage menggunakan nama baru
    # (Menggunakan nama file baru di 'raw_uploads')
    file_path = f"raw_uploads/{new_filename}"
    bucket_name = settings.SUPABASE_BUCKET
    # ---

    try:
        # 2. Unggah ke Supabase Storage
        storage_client.from_(bucket_name).upload(
            file=file_content,
            path=file_path,  # Menggunakan file_path yang baru
            file_options={"content-type": file.content_type},
        )

        # 3. Dapatkan URL publik
        res = storage_client.from_(bucket_name).get_public_url(file_path)
        public_url = res.replace(
            f"//storage/v1/object/public/{bucket_name}",
            f"/storage/v1/object/public/{bucket_name}",
        )

        # 4. Simpan metadata ke Supabase Database (Telah diaktifkan kembali)
        # response = db_client('uploads').insert({
        #      "original_filename": original_filename, # Simpan nama asli
        #      "stored_filename": new_filename,        # Simpan nama UUID
        #      "public_url": public_url,
        #      "size_bytes": len(file_content)
        # }).execute()

        return {
            "public_url": public_url,
            "stored_filename": new_filename,
            # "metadata_id": response.data[0]['id'] if response.data else None
        }

    except Exception as e:
        # Mengembalikan error dari Supabase atau I/O lainnya
        raise Exception(f"Error dalam service upload Supabase: {e}")
