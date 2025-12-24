#!/bin/bash
echo "=== Migrasi Data ke Production Database ==="

# Export data dari development database
docker exec lpi_abata_database pg_dump -U lpi_user -d menu_app --data-only --table=menu > /tmp/dev_data.sql

# Import ke production database
docker exec -i lpi_abata_database_prod psql -U lpi_user -d lpi_production_db < /tmp/dev_data.sql

echo "✅ Migrasi selesai!"
echo "Rows in production:"
docker exec lpi_abata_database_prod psql -U lpi_user -d lpi_production_db -c "SELECT COUNT(*) FROM menu;"
