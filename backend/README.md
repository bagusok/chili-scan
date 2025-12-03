# Chili Scan Backend

FastAPI service powering the chili-ripeness detection workflow. The API exposes upload, health check, and (future) prediction routes, and integrates with Supabase for storage and persistence. This README describes how to run and contribute to the backend on Windows, Linux, and macOS.

## Stack & Capabilities

- **FastAPI + Uvicorn** for an async REST API with built-in OpenAPI docs
- **Supabase** bucket + database used by the storage service layer
- **Python 3.11+ virtual environment** with reproducible dependencies (`requirements.txt`)
- **Start scripts** (`start.bat`, `start.sh`) for one-command local bootstrapping

## Project Layout

```
backend/
├── app/
│   ├── main.py                # FastAPI entrypoint
│   ├── configs.py             # dotenv-based settings loader
│   ├── schemas.py             # Pydantic response models
│   ├── routes/predict.py      # /health, /upload, /predict stubs
│   ├── services/storage.py    # Uploads to Supabase storage bucket
│   └── db/client.py           # Supabase client factory
├── data/                      # Place raw/processed assets here
├── models/                    # Serialized models or weights
├── notebooks/                 # Experiments and analysis
├── requirements.txt           # Python dependency lock
├── start.bat                  # Windows bootstrap script
└── start.sh                   # Linux/macOS bootstrap script
```

## Prerequisites

- Python **3.10 or newer**
- Git
- Access to Supabase credentials (URL, service role key, bucket name)
- (Optional) `make` or task runners if you prefer custom commands

## Environment Variables

Create a `.env` in the backend root (you can copy `.env.example`). Fill in:

| Variable          | Description                                    |
| ----------------- | ---------------------------------------------- |
| `SUPABASE_URL`    | Base URL of your Supabase project              |
| `SUPABASE_KEY`    | Service role API key (needed for storage + DB) |
| `SUPABASE_BUCKET` | Storage bucket where uploads are saved         |

The API refuses to start if `SUPABASE_URL` or `SUPABASE_KEY` is missing, so double-check before running.

## Setup & Run

The flow is identical on every platform: create a virtual env, install dependencies, configure `.env`, then launch Uvicorn. Commands differ slightly per OS.

### Windows

```powershell
cd backend
python -m venv venv
venv\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
copy .env.example .env  # then edit .env with Supabase values
```

Start the API (pick one):

- `start.bat` (activates `venv` and runs `uvicorn app.main:app --host 0.0.0.0 --port 3001 --reload`)
- Or run manually: `uvicorn app.main:app --host 127.0.0.1 --port 3001 --reload`

### Linux

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cp .env.example .env  # edit with Supabase credentials
```

Run the included script or the raw command:

- `chmod +x start.sh && ./start.sh`
- `uvicorn app.main:app --host 0.0.0.0 --port 3001 --reload`

### macOS

Same as Linux. If you installed Python via Homebrew, use `python3` and ensure the Xcode command line tools are present.

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cp .env.example .env
```

Then either `./start.sh` or `uvicorn app.main:app --host 0.0.0.0 --port 3001 --reload`.

### Verify the deployment

Once Uvicorn prints `Application startup complete`, open:

- `http://localhost:3001/health` → should return `{ "status": "OK" }`
- `http://localhost:3001/docs` → interactive Swagger UI
- `http://localhost:3001/redoc` → ReDoc documentation

## API Surface

| Method | Path       | Description                                                           |
| ------ | ---------- | --------------------------------------------------------------------- |
| `GET`  | `/health`  | Lightweight health probe                                              |
| `POST` | `/upload`  | Accepts an image file, uploads to Supabase bucket, returns public URL |
| `POST` | `/predict` | Placeholder route to be implemented                                   |

`POST /upload` expects `multipart/form-data` with a `file` field. The storage service renames the file to a UUID before uploading.

## Development Tips

- Keep services and routes thin—use the `app/services` layer for Supabase calls so that later prediction logic can reuse it.
- If you add new dependencies, lock them in `requirements.txt` after testing locally.
- Place datasets in `data/raw` or `data/processed` to keep Git history manageable. Use `.gitignore` if needed.
- Add new routes under `app/routes` and include them in `app/main.py` via `app.include_router`.

## Troubleshooting

- **Missing Supabase credentials**: Ensure `.env` is loaded and paths are correct; `python-dotenv` reads from the backend root.
- **Permission issues on Linux/macOS**: Run `chmod +x start.sh` once, or execute the raw Uvicorn command.
- **Port already in use**: Change `--port 3001` to an available port, but update client apps accordingly.
- **Large file uploads**: Uvicorn defaults may need tweaking; consider setting `--limit-concurrency` or using background tasks.

Happy building!
