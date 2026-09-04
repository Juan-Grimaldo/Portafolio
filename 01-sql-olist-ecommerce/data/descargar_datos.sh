#!/usr/bin/env bash
# Descarga el Brazilian E-Commerce Public Dataset by Olist (~120 MB).
# Ejecutar desde esta carpeta:  bash descargar_datos.sh
set -euo pipefail

BASE="https://raw.githubusercontent.com/alexcj10/olist-ecommerce-analytics/main/data"
ARCHIVOS=(
  olist_customers_dataset
  olist_geolocation_dataset
  olist_order_items_dataset
  olist_order_payments_dataset
  olist_order_reviews_dataset
  olist_orders_dataset
  olist_products_dataset
  olist_sellers_dataset
  product_category_name_translation
)

for f in "${ARCHIVOS[@]}"; do
  printf '%-45s' "$f.csv"
  curl -sfL --max-time 180 -o "$f.csv" "$BASE/$f.csv"
  printf 'OK (%s)\n' "$(du -h "$f.csv" | cut -f1)"
done

echo "Listo. Siguiente paso: cd ../docker && docker compose up -d"
