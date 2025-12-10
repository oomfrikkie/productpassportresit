#!/bin/bash
set -e

echo "🚀 Starting full system..."

# 1. Install packages if needed
echo "📦 Installing dependencies..."
npm install

# 2. Build TypeScript
echo "🏗 Building TypeScript..."
npm run build || echo "⚠️ Build failed or missing script, continuing anyway..."

# 3. Start containers
echo "🐋 Starting Docker stack..."
docker compose up -d --build

# 4. Wait
echo "⏳ Waiting for services to boot..."
sleep 3

# 5. Detect tracking container name dynamically
TRACKING_CONTAINER=$(docker ps --format "{{.Names}}" | grep "tracking" | head -n 1)

if [ -z "$TRACKING_CONTAINER" ]; then
  echo "❌ No tracking service container found!"
else
  echo "📡 Tracking service logs from: $TRACKING_CONTAINER"
  docker logs -f "$TRACKING_CONTAINER" &
fi

# 6. Start API
echo "🌐 Starting API server..."
npm run api
