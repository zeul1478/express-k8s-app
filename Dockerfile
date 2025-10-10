FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY app.js ./
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "app.js"]
