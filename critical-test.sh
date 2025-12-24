#!/bin/bash
echo "=== CRITICAL TEST ==="

echo "1. Is backend actually working?"
curl -s http://localhost:5002/health | jq -r '"Status: " + .status + ", DB: " + .database'

echo ""
echo "2. Is API returning JSON?"
RESPONSE=$(curl -s http://localhost:5002/api/menu)
if echo "$RESPONSE" | jq . >/dev/null 2>&1; then
    echo "✅ API returns valid JSON"
    echo "   Count: $(echo "$RESPONSE" | jq '.data | length') items"
else
    echo "❌ API returns invalid JSON"
    echo "   First 100 chars: ${RESPONSE:0:100}"
fi

echo ""
echo "3. Can NPM reach frontend?"
docker exec nginx-proxy-manager-app-1 curl -s http://lpi_abata_frontend_prod:80/ | grep -o "<title>[^<]*</title>" 2>/dev/null || echo "❌ NPM cannot reach frontend"

echo ""
echo "4. Is NPM proxy configured correctly?"
echo "   Check at: http://$(hostname -I | awk '{print $1}'):81"
echo "   Domain: lpi.abata.sch.id → lpi_abata_frontend_prod:80"
