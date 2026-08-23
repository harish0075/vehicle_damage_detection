FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

# Needed by pdf2image/pytesseract dependencies in the project.
RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils tesseract-ocr libgl1 && \
    rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt

COPY backend backend
COPY runs/detect/train14/weights/best.pt runs/detect/train14/weights/best.pt

EXPOSE 8000
CMD sh -c "cd /app/backend && uvicorn app:app --host 0.0.0.0 --port ${PORT}"
