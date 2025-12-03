# 🌶️ Chili Scan Monorepo

End-to-end platform for chili ripeness assessment. The backend FastAPI service ingests images and talks to Supabase, while the Flutter mobile app provides a scanning-first UX for farmers and agribusiness operators.

## Repository Layout

```
chili-scan/
├─ backend/            # FastAPI API + Supabase integrations
└─ chili_scan_app/     # Flutter mobile app (Android, iOS, web)
```

## Highlighted Capabilities

- **Image upload API** – `/upload` stores images in Supabase storage and returns a public URL for downstream processing.
- **Supabase-backed storage** – Simple service wrapper keeps credentials out of route handlers and enforces consistent bucket usage.
- **Mobile-first scanner** – Flutter UI offers quick camera/gallery intake, history, account flow, and CTA-rich dashboard.
- **Riverpod architecture** – `flutter_riverpod` providers isolate state & business logic from presentation.

## Tech Stack

| Layer   | Stack & Tooling                                                          |
| ------- | ------------------------------------------------------------------------ |
| Backend | Python 3.11+, FastAPI, Uvicorn, Pydantic, python-dotenv, Supabase client |
| Mobile  | Flutter 3.10+, Dart 3, Riverpod 3, `go_router`, `dio`, Google Fonts      |

## Prerequisites

- Python **3.10+** and `pip`
- Flutter SDK **3.38+** (`flutter doctor` should be clean)
- Supabase project credentials: URL, service role key, and storage bucket name
- (Optional) Android/iOS tooling for device builds

## Quick Start

### 1. Backend API

```powershell
cd backend
python -m venv venv
venv\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
copy .env.example .env  # fill SUPABASE_* values
uvicorn app.main:app --host 127.0.0.1 --port 3001 --reload
```

Shortcuts:

- Windows: `start.bat`
- Linux/macOS: `chmod +x start.sh && ./start.sh`

Verify:

- `http://localhost:3001/health` → `{ "status": "OK" }`
- `http://localhost:3001/docs` for Swagger UI

### 2. Flutter App

```bash
cd chili_scan_app
flutter pub get
flutter run
```

Run tests with `flutter test`. Use `flutter run -d chrome` for web preview or pass an emulator/device ID.

## Environment Variables (Backend)

| Variable          | Description                                    |
| ----------------- | ---------------------------------------------- |
| `SUPABASE_URL`    | Base URL of the Supabase project               |
| `SUPABASE_KEY`    | Service role API key (needed for storage + DB) |
| `SUPABASE_BUCKET` | Storage bucket where uploads are saved         |

The API refuses to start without `SUPABASE_URL` and `SUPABASE_KEY`.

## Data & Models

- Place raw assets in `backend/data/raw/` and processed derivatives in `backend/data/processed/`.
- Persist trained weights or serialized models under `backend/models/`.
- Keep exploratory notebooks inside `backend/notebooks/` for reproducible research.

## Contribution Flow

1. Create a feature branch from `main`.
2. Update dependencies (`requirements.txt`, `pubspec.yaml`) only after local testing.
3. Keep routes thin; put Supabase/file logic in `app/services/`.
4. Prefer reusable widgets/providers inside the Flutter app to keep pages lean.
5. Submit PRs with:
   - Backend: `uvicorn` logs/screenshots + any notebook references.
   - Flutter: screenshots or screen recordings for UI tweaks.

## Roadmap Ideas

- Hook `/predict` into a trained ripeness model once available.
- Stream upload progress into the app for better UX on slow networks.
- Add CI to lint backend (ruff/mypy) and run `flutter test` on each PR.

Happy building! ✨
