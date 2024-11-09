# Use the official Python image as the base image
FROM python:3.11-slim AS backend

# Install Node.js and required build tools
RUN apt update && apt install -y nodejs npm build-essential

# Set the working directory
WORKDIR /app

# Copy Python dependencies
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy Node.js dependencies
COPY package.json pnpm-lock.yaml ./

# Install pnpm and Node.js dependencies
RUN npm install -g pnpm
RUN pnpm install

# Copy all project files to the container
COPY . .

# Build the Next.js application
RUN pnpm run build

# Expose ports for Next.js and FastAPI
EXPOSE 3000
EXPOSE 8000

# Start both FastAPI and Next.js applications
CMD ["sh", "-c", "uvicorn api.index:app --host 0.0.0.0 --port 8000 & pnpm run start"]
