FROM oven/bun:latest as builder

ENV PORT=${PORT}
ENV DATABASE_URL=${DATABASE_URL}
ENV JWT_SECRET=${JWT_SECRET}

WORKDIR /app

COPY . .
RUN bun install
RUN bun run build

FROM oven/bun:latest

WORKDIR /app

COPY --from=builder /app/package.json /app/bun.lockb /app/prisma /app/dist ./

RUN bun install --production --frozen-lockfile

EXPOSE ${PORT}

ENTRYPOINT bun prisma migrate deploy && bun run index.js