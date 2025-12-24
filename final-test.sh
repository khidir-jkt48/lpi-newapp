#!/bin/bash
echo "=== FINAL TEST PRODUCTION SETUP ==="

echo "1. Container status:"
docker-compose ps

echo ""
echo "2. Database data:"
docker-compose exec database-prod psql -U lpi_user -d lpi_production_db -c "SELECT id, nama, category FROM menu_prod;"

echo ""
echo "3. Backend API:"
curl -s http://localhost:5002/api/menu | jq '.data[] | {id, nama, category}'

echo ""
echo "4. Nginx Proxy Test:"
curl -H "Host: lpi.abata.sch.id" -s http://localhost/ | grep -o "<title>.*</title>" | head -1

echo ""
echo "5. API melalui Nginx:"
curl -H "Host: lpi.abata.sch.id" -s http://localhost/api/menu | jq '.source, .count'

echo ""
echo "✅ SEMUA TEST SELESAI!"
