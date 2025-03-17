# Base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy files
COPY src/ /app/
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Define entry point
CMD ["python", "main.py"]
