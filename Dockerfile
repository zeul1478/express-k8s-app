# Use Node.js base image
FROM node:18

WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy app source
COPY app.js ./

# Use node user (already exists in the image) instead of creating new user
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "app.js"]