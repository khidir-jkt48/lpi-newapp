#!/bin/bash
echo "=== Quick Test Production Setup ==="

cd /opt/lpi-abata-prod

echo "1. Starting services..."
docker-compose up -d
sleep 20

echo ""
echo "2. Checking containers..."
docker-compose ps

echo ""
echo "3. Testing database..."
docker-compose exec database-prod pg_isready -U lpi_user -d lpi_production_db && echo "✅ Database ready" || echo "❌ Database not ready"

echo ""
echo "4. Testing backend health..."
curl -s http://localhost:5002/health | jq '.'

echo ""
echo "5. Testing API..."
curl -s http://localhost:5002/api/menu | jq '.source'

echo ""
echo "6. Direct database query..."
docker-compose exec database-prod psql -U lpi_user -d lpi_production_db -c "SELECT COUNT(*) as total FROM menu_prod;"
