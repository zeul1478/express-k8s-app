# ---- Stage 1: Build dependencies ----
    FROM node:18-alpine AS builder

    WORKDIR /app

    
    
    # Copy package.json and package-lock.json first
    COPY package*.json ./
    
    # Install dependencies
    RUN npm install --production
    
    # Copy the rest of the app
    COPY . .
    
    # ---- Stage 2: Run lightweight container ----
    FROM node:18-alpine
    
    WORKDIR /app
    
    # Copy only the built app from builder
    COPY --from=builder /app /app
    
    # Add non-root user for security
    RUN addgroup -S appgroup && adduser -S appuser -G appgroup
    USER appuser
    
    EXPOSE 3000

    # Health check: ping /health every 30s, timeout after 10s, fail after 3 tries
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD wget -qO- http://localhost:3000/health || exit 1

    
    CMD ["node", "app.js"]
    