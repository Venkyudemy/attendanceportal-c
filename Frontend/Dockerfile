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

# Copy HTTP or HTTPS nginx template based on build arg
COPY nginx.conf.template /tmp/nginx-http.conf.template
COPY nginx.ssl.conf.template /tmp/nginx-https.conf.template

RUN if [ "$ENABLE_SSL" = "true" ]; then \
      mkdir -p /etc/nginx/templates && \
      cp /tmp/nginx-https.conf.template /etc/nginx/templates/default.conf.template; \
    else \
      mkdir -p /etc/nginx/templates && \
      cp /tmp/nginx-http.conf.template /etc/nginx/templates/default.conf.template; \
    fi

EXPOSE 80

# Expose 443 only if SSL is enabled (harmless if not used)
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
