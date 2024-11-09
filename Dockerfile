FROM python:3.11-slim AS backend

RUN apt update && apt install -y nodejs npm build-essential

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN npm install -g pnpm
RUN pnpm install

COPY . .

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN pnpm run build

EXPOSE 3000

CMD ["sh", "-c", "pnpm run start & uvicorn api.index:app --host 0.0.0.0 --port 3000"]
