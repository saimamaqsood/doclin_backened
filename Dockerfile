FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender-dev \
    poppler-utils tesseract-ocr \
    && rm -rf /var/lib/apt/lists/*
# Add to your Dockerfile (before pip install):
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-urd \
    tesseract-ocr-ara \
    tesseract-ocr-hin \
    tesseract-ocr-chi-sim \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
RUN mkdir -p /app/outputs /app/uploads

# Pre-download EasyOCR English model
RUN python -c "import easyocr; easyocr.Reader(['en'], gpu=False)" || echo "Pre-warm skipped"

EXPOSE 8000

CMD gunicorn main:app --worker-class uvicorn.workers.UvicornWorker --workers 2 --bind 0.0.0.0:${PORT:-8000} --timeout 300