#!/bin/bash

echo "🔧 Quick Nginx Fix for Production"
echo

echo "[INFO] Stopping frontend container..."
docker-compose -f docker-compose.prod.yml stop frontend

echo "[INFO] Rebuilding frontend with fixed Nginx config..."
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo "[INFO] Starting frontend container..."
docker-compose -f docker-compose.prod.yml up -d frontend

echo "[INFO] Waiting for frontend to start..."
sleep 10

echo "[INFO] Testing frontend health..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "[SUCCESS] ✅ Frontend is working!"
    echo "[SUCCESS] ✅ Nginx configuration fixed!"
else
    echo "[ERROR] ❌ Frontend still having issues"
    echo "[INFO] Checking logs..."
    docker-compose -f docker-compose.prod.yml logs frontend
fi

echo
echo "[INFO] Container status:"
docker-compose -f docker-compose.prod.yml ps

echo
echo "[SUCCESS] Quick fix completed!"
