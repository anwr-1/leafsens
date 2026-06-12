# LeafSense MVP - Implementation Plan

## Backend: FastAPI (Python)
- main.py: loads EfficientNetV2-S model once at startup, POST /predict, GET /health
- requirements.txt: fastapi, uvicorn, python-multipart, torch, torchvision, Pillow

## Frontend: React + Vite + Tailwind CSS
- UploadZone.jsx: drag-and-drop + camera capture
- ResultCard.jsx: disease result + treatment
- ConfidenceBar.jsx: colored confidence bar
- treatments.js: hardcoded treatment lookup
- App.jsx: 3-state machine (upload, loading, result)

## Structure
leafsense/
├── backend/
│   ├── main.py
│   └── requirements.txt
├── frontend/
│   ├── src/App.jsx + components/ + data/
│   ├── index.html
│   ├── package.json
│   └── tailwind.config.js
└── README.md
