# Use Python 3.12 slim image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies for OpenCV and other libraries
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories for uploads and detections if they don't exist
RUN mkdir -p static/uploads static/detections weights

# Download YOLO model weights to the correct location
RUN apt-get update && apt-get install -y wget && \
    wget -q https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8s.pt -O weights/yolov8s.pt && \
    echo "✓ YOLOv8s weights downloaded to weights/yolov8s.pt" && \
    rm -rf /var/lib/apt/lists/*

# Expose port (Railway will set PORT env variable)
EXPOSE 8080

# Set environment variable for Python unbuffered output
ENV PYTHONUNBUFFERED=1

# Start command using gunicorn
CMD gunicorn --bind 0.0.0.0:${PORT:-8080} --workers 2 --timeout 120 app_dashboard:app
