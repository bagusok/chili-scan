#!/bin/bash
# start.sh

# 1. Mengaktifkan Lingkungan Virtual (asumsi venv ada di root folder)
echo "Mengaktifkan Virtual Environment..."
source venv/bin/activate

if [ $? -ne 0 ]; then
    echo "Error: Gagal mengaktifkan lingkungan virtual. Pastikan venv sudah dibuat."
    exit 1
fi

# 2. Menjalankan Server Uvicorn
echo "Menjalankan Uvicorn server pada http://0.0.0.0:3001 ..."
# Sintaks: uvicorn [path.ke.modul:instance_app] --opsi
uvicorn app.main:app --host 0.0.0.0 --port 3001 --reload

echo "Server dihentikan."

# Catatan: Di Linux/macOS, Anda perlu memberikan izin eksekusi
# pada file ini setelah membuatnya: chmod +x start.sh