# Base Image
FROM node:20-alpine AS base

# Install essential packages
RUN apk add --no-cache libc6-compat git curl

# Setup pnpm environment
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

### Dependencies Stage ###
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

### Builder Stage ###
FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

### Production Image Runner ###
FROM base AS runner

# Install pnpm and dependencies in the runner stage
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set NODE_ENV to production
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Set up non-root user
RUN addgroup -S nodejs && adduser -S nextjs -G nodejs
WORKDIR /app
RUN mkdir -p /app && chown -R nextjs:nodejs /app

# Copy necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./

USER nextjs

# Ensure the PATH includes node_modules/.bin
ENV PATH="/app/node_modules/.bin:$PATH"

# Expose the port and set environment variables
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Health check using curl
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Run the Next.js application
CMD ["pnpm", "start"]
