# Use a more stable version of Python
FROM python:3.11-bullseye

# Set work directory
WORKDIR /app

# Install dependencies for psycopg2 and other required packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install the correct version of pip
RUN python -m pip install --no-cache-dir pip==22.0.4

# Copy dependencies list and install dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Expose the application port
EXPOSE 8000

# Run migrations before starting the application
RUN python3 /app/manage.py migrate

# Set working directory inside pygoat
WORKDIR /app/pygoat/

# Start the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
