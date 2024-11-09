FROM node:20-alpine

RUN apk add --no-cache python3 py3-pip

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN npm install -g pnpm
RUN pnpm install

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN pnpm run build

EXPOSE 3000

CMD ["sh", "-c", "uvicorn api.index:app --host 0.0.0.0 --port 8000 & pnpm run start"]
