FROM node:20-alpine AS builder

RUN apk add --no-cache python3 py3-pip build-base libffi-dev musl-dev

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN npm install -g pnpm
RUN pnpm install

COPY . .

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

RUN pnpm run build

EXPOSE 3000

CMD ["sh", "-c", "pnpm run start & uvicorn api.main:app --host 0.0.0.0 --port 3000"]
