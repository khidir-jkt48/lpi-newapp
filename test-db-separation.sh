#!/bin/bash
echo "=== Database Separation Test ==="

echo "1. Insert test data ke development database:"
docker exec lpi_abata_database psql -U lpi_user -d menu_app -c "
  INSERT INTO menu (nama, link) VALUES ('DEV ONLY', '#dev');
  SELECT nama FROM menu WHERE nama LIKE '%DEV%' OR nama LIKE '%PROD%';
"

echo ""
echo "2. Insert test data ke production database:"
docker exec lpi_abata_database_prod psql -U lpi_user -d lpi_production_db -c "
  INSERT INTO menu_prod (nama, link, category) VALUES ('PROD ONLY', '#prod', 'test');
  SELECT nama, category FROM menu_prod WHERE nama LIKE '%DEV%' OR nama LIKE '%PROD%';
"

echo ""
echo "3. Verifikasi melalui API:"
echo "   Development API:"
curl -s http://localhost:5001/api/menu | jq '.data[] | select(.nama | contains("DEV")) | .nama'

echo "   Production API:"
curl -s http://localhost:5002/api/menu | jq '.data[] | select(.nama | contains("PROD")) | .nama'
