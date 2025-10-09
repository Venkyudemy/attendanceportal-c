# Stage 1: Build React app
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci --legacy-peer-deps

COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:1.25-alpine AS production

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

COPY --from=build /app/build .

ARG ENABLE_SSL=false

# Copy env-config.js from public directory to nginx root
COPY public/env-config.js .
RUN cp env-config.js env.js

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create uploads directory and set permissions
RUN mkdir -p /usr/share/nginx/html/uploads && \
    chmod -R 755 /usr/share/nginx/html/uploads

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
