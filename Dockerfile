FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
RUN pnpm install

COPY . .
RUN pnpm run build

FROM python:3.11-slim AS backend

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --from=builder /app /app

EXPOSE 3000 8000

CMD ["sh", "-c", "pnpm run start & uvicorn api.main:app --host 0.0.0.0 --port 3000"]
