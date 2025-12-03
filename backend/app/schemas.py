# app/schemas.py
from pydantic import BaseModel

class UploadResult(BaseModel):
    """Skema untuk hasil output setelah upload berhasil."""
    filename: str
    public_url: str
    
class HealthCheck(BaseModel):
    status: str