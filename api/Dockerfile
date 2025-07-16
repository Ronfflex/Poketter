FROM oven/bun:latest as builder

ENV PORT=${PORT}
ENV DATABASE_URL=${DATABASE_URL}
ENV JWT_SECRET=${JWT_SECRET}

WORKDIR /app

# Installer OpenSSL et les dépendances nécessaires
RUN apt-get update -y && apt-get install -y \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY package.json bun.lockb ./
RUN bun install

COPY . .
RUN bun run build

FROM oven/bun:latest

WORKDIR /app

# Installer OpenSSL dans l'image de production
RUN apt-get update -y && apt-get install -y \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/package.json ./
COPY --from=builder /app/bun.lockb ./
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/dist ./dist

RUN bun install --production --frozen-lockfile

EXPOSE ${PORT}

# Générer le client Prisma et démarrer l'application
ENTRYPOINT ["sh", "-c", "bun prisma generate && bun prisma migrate deploy && bun run dist/index.js"]