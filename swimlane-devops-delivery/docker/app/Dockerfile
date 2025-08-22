# Multi-stage build for the Node.js app
FROM node:18-alpine AS deps
WORKDIR /app
COPY src/devops-practical/package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY src/devops-practical/ .
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- http://localhost:3000/ || exit 1
CMD ["npm","start"]
