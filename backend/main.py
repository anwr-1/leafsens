"""
LeafSense Backend – FastAPI
AI-powered plant disease detection via EfficientNetV2-S
"""

import io
from contextlib import asynccontextmanager
from pathlib import Path
from typing import List

import torch
import torch.nn.functional as F
import torchvision.transforms as T
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from pydantic import BaseModel
from torchvision.models import efficientnet_v2_s

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# Resolved relative to this file so it works on any machine / OS
MODEL_PATH: Path = Path(__file__).parent / "best_model.pt"

INPUT_SIZE  = 224
NORM_MEAN   = [0.46689, 0.48948, 0.41100]
NORM_STD    = [0.19335, 0.16824, 0.21204]
NUM_CLASSES = 38

MAX_UPLOAD_BYTES = 10 * 1024 * 1024  # 10 MB

ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp"}

# Magic bytes for JPEG, PNG, and WebP – used to validate uploads regardless
# of whatever MIME type the client sends.
MAGIC_BYTES = {
    b"\xff\xd8\xff": "image/jpeg",
    b"\x89PNG":      "image/png",
    b"RIFF":         "image/webp",   # confirmed below with offset 8
}

CLASS_NAMES: List[str] = [
    "Apple___Apple_scab",
    "Apple___Black_rot",
    "Apple___Cedar_apple_rust",
    "Apple___healthy",
    "Blueberry___healthy",
    "Cherry_(including_sour)___Powdery_mildew",
    "Cherry_(including_sour)___healthy",
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot",
    "Corn_(maize)___Common_rust_",
    "Corn_(maize)___Northern_Leaf_Blight",
    "Corn_(maize)___healthy",
    "Grape___Black_rot",
    "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Grape___healthy",
    "Orange___Haunglongbing_(Citrus_greening)",
    "Peach___Bacterial_spot",
    "Peach___healthy",
    "Pepper,_bell___Bacterial_spot",
    "Pepper,_bell___healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    "Raspberry___healthy",
    "Soybean___healthy",
    "Squash___Powdery_mildew",
    "Strawberry___Leaf_scorch",
    "Strawberry___healthy",
    "Tomato___Bacterial_spot",
    "Tomato___Early_blight",
    "Tomato___Late_blight",
    "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites Two-spotted_spider_mite",
    "Tomato___Target_Spot",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
    "Tomato___Tomato_mosaic_virus",
    "Tomato___healthy",
]

# ---------------------------------------------------------------------------
# Preprocessing pipeline (built once at startup)
# ---------------------------------------------------------------------------

preprocess = T.Compose([
    T.Resize((INPUT_SIZE, INPUT_SIZE), antialias=True),
    T.ToTensor(),
    T.Normalize(mean=NORM_MEAN, std=NORM_STD),
])

# ---------------------------------------------------------------------------
# Global model holder (loaded once at startup)
# ---------------------------------------------------------------------------

_model: torch.nn.Module | None = None
_device: torch.device = torch.device("cpu")


def load_model() -> torch.nn.Module:
    """Load EfficientNetV2-S and replace the classifier head for 38 classes."""
    if not MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Model file not found at {MODEL_PATH}. "
            "Place best_model.pt in the backend/ folder and restart."
        )

    model = efficientnet_v2_s(weights=None)
    in_features = model.classifier[1].in_features
    model.classifier[1] = torch.nn.Linear(in_features, NUM_CLASSES)

    # weights_only=True is the safe default from PyTorch ≥ 2.0
    state = torch.load(MODEL_PATH, map_location=_device, weights_only=True)
    # Handle both raw state-dict and {'model_state_dict': …} checkpoints
    if isinstance(state, dict) and "model_state_dict" in state:
        state = state["model_state_dict"]

    model.load_state_dict(state)
    model.to(_device)
    model.eval()
    return model


# ---------------------------------------------------------------------------
# Lifespan: startup / shutdown
# ---------------------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    global _model
    try:
        _model = load_model()
        print("✅  Model loaded successfully.")
    except FileNotFoundError as exc:
        print(f"⚠️  {exc}")
        print("    The /predict endpoint will return 503 until the model is available.")
        _model = None
    yield
    _model = None


# ---------------------------------------------------------------------------
# FastAPI app
# ---------------------------------------------------------------------------

app = FastAPI(
    title="LeafSense API",
    description="AI-powered plant disease detection",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # Flutter emulator + physical device
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Pydantic schemas
# ---------------------------------------------------------------------------

class Top3Item(BaseModel):
    class_name: str
    confidence: float


class PredictResponse(BaseModel):
    plant: str
    disease: str
    is_healthy: bool
    confidence: float
    raw_class: str
    top3: List[Top3Item]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _is_valid_image(data: bytes) -> bool:
    """Return True if the raw bytes look like a supported image format."""
    if data[:3] == b"\xff\xd8\xff":
        return True  # JPEG
    if data[:4] == b"\x89PNG":
        return True  # PNG
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return True  # WebP
    return False


def parse_class_name(raw: str) -> tuple[str, str]:
    """
    'Tomato___Early_blight'       → plant='Tomato',      disease='Early blight'
    'Apple___healthy'             → plant='Apple',        disease='Healthy'
    'Pepper,_bell___Bacterial_spot' → plant='Pepper bell', disease='Bacterial spot'
    """
    parts = raw.split("___", 1)
    # Remove trailing/leading underscores, replace underscores with spaces,
    # strip the comma that separates "Pepper, bell" in the dataset label.
    plant   = parts[0].replace("_", " ").replace(",", "").strip()
    disease = parts[1].replace("_", " ").strip() if len(parts) > 1 else "Unknown"
    return plant, disease


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": _model is not None}


@app.post("/predict", response_model=PredictResponse)
async def predict(file: UploadFile = File(...)):
    # 1. Model must be loaded
    if _model is None:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Place best_model.pt in the backend/ folder and restart.",
        )

    # 2. Enforce file-size limit before reading the whole body
    raw_bytes = await file.read(MAX_UPLOAD_BYTES + 1)
    if len(raw_bytes) > MAX_UPLOAD_BYTES:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Maximum allowed size is {MAX_UPLOAD_BYTES // (1024 * 1024)} MB.",
        )

    # 3. Validate via magic bytes (more reliable than content_type header)
    if not _is_valid_image(raw_bytes):
        raise HTTPException(
            status_code=415,
            detail="Unsupported file format. Upload a JPEG, PNG, or WebP image.",
        )

    # 4. Decode image
    try:
        img = Image.open(io.BytesIO(raw_bytes)).convert("RGB")
    except Exception:
        raise HTTPException(status_code=400, detail="Could not decode image. Ensure the file is a valid image.")

    # 5. Preprocess → tensor
    tensor = preprocess(img).unsqueeze(0).to(_device)  # (1, 3, 224, 224)

    # 6. Inference
    with torch.no_grad():
        logits = _model(tensor)               # (1, 38)
        probs  = F.softmax(logits, dim=1)[0]  # (38,)

    # 7. Top-3 results
    top3_vals, top3_idx = torch.topk(probs, 3)
    top3 = [
        Top3Item(
            class_name=CLASS_NAMES[idx.item()],
            confidence=round(val.item(), 4),
        )
        for val, idx in zip(top3_vals, top3_idx)
    ]

    # 8. Build response from top prediction
    raw_class      = CLASS_NAMES[top3_idx[0].item()]
    best_conf      = round(top3_vals[0].item(), 4)
    plant, disease = parse_class_name(raw_class)
    is_healthy     = "healthy" in disease.lower()

    return PredictResponse(
        plant=plant,
        disease=disease,
        is_healthy=is_healthy,
        confidence=best_conf,
        raw_class=raw_class,
        top3=top3,
    )