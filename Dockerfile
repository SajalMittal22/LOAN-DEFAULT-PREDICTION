FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python -m pip install \
    --no-cache-dir \
    --default-timeout=600 \
    --retries=15 \
    -r requirements.txt

COPY app/ ./app/
COPY src/ ./src/
COPY models/ ./models/
COPY reports/ ./reports/
COPY data/ ./data/
COPY run_pipeline.py ./

RUN mkdir -p /app/logs /app/mlruns

EXPOSE 8000 8501

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port 8000 & streamlit run app/streamlit_app.py --server.address 0.0.0.0 --server.port ${PORT:-8501}"]