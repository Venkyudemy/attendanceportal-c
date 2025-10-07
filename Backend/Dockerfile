# ---- Backend Dockerfile (Node.js + Express) ----
FROM node:18-alpine

WORKDIR /app

# Install dependencies for better caching
COPY package*.json ./
RUN npm ci --legacy-peer-deps --only=production

# Install curl for health checks
RUN apk add --no-cache curl

# Copy source code
COPY . .

# Set timezone for consistent date handling
ENV TZ=Asia/Kolkata

# Create directories for uploads and scripts
RUN mkdir -p scripts uploads/employees

# Set proper permissions for uploads directory
RUN chmod 755 uploads uploads/employees

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
  CMD curl -f http://localhost:5000/api/health || exit 1

EXPOSE 5000

CMD ["npm", "start"]
