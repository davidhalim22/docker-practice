# ---------- Dependencies ----------
FROM node:20-alpine AS deps

WORKDIR /app

COPY package*.json ./

RUN npm ci

# ---------- Builder ----------
FROM node:20-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# ---------- Runner ----------
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

COPY package*.json ./

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

RUN addgroup -S nextjs && adduser -S nextjs -G nextjs

USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s \
  CMD wget -qO- http://localhost:3000 || exit 1

CMD ["npm", "start"]