FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV PORT=7860
EXPOSE 7860
CMD gunicorn app:app --timeout 180 --workers 2 --threads 4 --bind 0.0.0.0:${PORT}
