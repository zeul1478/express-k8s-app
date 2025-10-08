# ---- Stage 1: Build dependencies ----
    FROM node:18 AS builder

    WORKDIR /app
    
    # Copy only package files first (better caching)
    COPY package*.json ./
    
    # Install dependencies
    RUN npm install --production
    
    # Copy ONLY the app source code, not config files
    COPY app.js ./
    # Or if you have more source files, create a src directory and copy that
    # COPY src/ ./src/
    
    # ---- Stage 2: Run lightweight container ----
    FROM node:18
    
    WORKDIR /app
    
    # Copy only the built app from builder
    COPY --from=builder /app /app
    
    # Add non-root user for security
    RUN addgroup -S appgroup && adduser -S appuser -G appgroup
    USER appuser
    
    EXPOSE 3000
    
    HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD wget -qO- http://localhost:3000/health || exit 1
    
    CMD ["node", "app.js"]