# ---- Stage 1: Build dependencies ----
    FROM node:18 AS builder

    WORKDIR /app
    
    # Copy package files first (better caching)
    COPY package*.json ./
    
    # Install dependencies
    RUN npm install --production
    
    # Copy ONLY the app source code
    COPY app.js ./
    
    # ---- Stage 2: Run lightweight container ----
    FROM node:18
    
    WORKDIR /app
    
    # Copy only the built app from builder
    COPY --from=builder /app /app
    
    # Add non-root user for security (Alpine Linux syntax)
    RUN addgroup -g 1001 -S appgroup && \
        adduser -S -u 1001 -G appgroup appuser
    
    # Change ownership of the app directory
    RUN chown -R appuser:appgroup /app
    
    USER appuser
    
    EXPOSE 3000
    
    HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD wget -qO- http://localhost:3000/health || exit 1
    
    CMD ["node", "app.js"]