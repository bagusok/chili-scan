:: start.bat
@echo off

:: 1. Mengaktifkan Lingkungan Virtual (asumsi venv ada di root folder)
echo Mengaktifkan Virtual Environment...
call venv\Scripts\activate

:: Cek apakah aktivasi berhasil
if exist venv\Scripts\activate (
    echo Lingkungan Virtual diaktifkan.
) else (
    echo Error: File aktivasi tidak ditemukan. Pastikan venv sudah dibuat.
    pause
    exit /b 1
)

:: 2. Menjalankan Server Uvicorn
echo Menjalankan Uvicorn server...
:: Sintaks: uvicorn [path.ke.modul:instance_app] --opsi
uvicorn app.main:app --host 0.0.0.0 --port 3001 --reload

:: Perintah di bawah ini akan dijalankan hanya jika server berhenti
echo Server dihentikan.

pause