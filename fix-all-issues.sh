#!/bin/bash
cd /opt/lpi-abata-prod

echo "=== FIXING ALL ISSUES ==="

echo "1. Stopping services..."
docker-compose down

echo "2. Fixing nginx config..."
cat > nginx-prod.conf << 'NGINXEOF'
server {
    listen 80;
    server_name _;
    
    root /usr/share/nginx/html;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend-prod:5001/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINXEOF

echo "3. Simplifying healthcheck..."
cat > docker-compose.yml << 'DOCKEREOF'
version: '3.8'

services:
  frontend-prod:
    build: ./frontend-prod
    volumes:
      - ./nginx-prod.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - lpi-npm-network
    container_name: lpi_abata_frontend_prod

  backend-prod:
    build: ./backend-prod
    ports:
      - "5002:5001"
    environment:
      - DB_HOST=database-prod
      - DB_USER=lpi_user
      - DB_PASSWORD=AbataSecure123!
      - DB_NAME=lpi_production_db
      - DB_PORT=5432
      - PORT=5001
    networks:
      - lpi-npm-network
    container_name: lpi_abata_backend_prod
    healthcheck:
      test: ["CMD", "sh", "-c", "timeout 5 bash -c 'cat < /dev/null > /dev/tcp/localhost/5001'"]
      interval: 30s
      timeout: 10s
      retries: 3

  database-prod:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=lpi_production_db
      - POSTGRES_USER=lpi_user
      - POSTGRES_PASSWORD=AbataSecure123!
    volumes:
      - postgres_lpi_prod_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - lpi-npm-network
    container_name: lpi_abata_database_prod
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U lpi_user"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_lpi_prod_data:

networks:
  lpi-npm-network:
    external: true
DOCKEREOF

echo "4. Rebuilding and starting..."
docker-compose up -d --build

echo "5. Waiting for services..."
sleep 20

echo "6. Final test..."
echo "Backend direct:"
curl -s http://localhost:5002/health | jq '.status'

echo "API direct:"
curl -s http://localhost:5002/api/menu | jq '.count'

echo "Through Nginx (with Host header):"
curl -s -H "Host: lpi.abata.sch.id" http://localhost/ | grep -o "<title>[^<]*</title>" || echo "No title found"

echo "API through Nginx:"
curl -s -H "Host: lpi.abata.sch.id" http://localhost/api/menu | head -c 100
echo "..."

echo "=== DONE ==="
