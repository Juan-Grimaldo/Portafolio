-- =============================================================================
-- 02_carga.sql | Carga de los CSV a raw.*  y constraints post-carga
-- Ejecutar DESPUÉS de 01_schema.sql. Los CSV se montan en /data dentro del
-- contenedor (ver docker/docker-compose.yml).
-- =============================================================================

\copy raw.customers                   FROM '/data/olist_customers_dataset.csv'            WITH (FORMAT csv, HEADER true);
\copy raw.geolocation                 FROM '/data/olist_geolocation_dataset.csv'          WITH (FORMAT csv, HEADER true);
\copy raw.orders                      FROM '/data/olist_orders_dataset.csv'               WITH (FORMAT csv, HEADER true);
\copy raw.order_items                 FROM '/data/olist_order_items_dataset.csv'          WITH (FORMAT csv, HEADER true);
\copy raw.order_payments              FROM '/data/olist_order_payments_dataset.csv'       WITH (FORMAT csv, HEADER true);
\copy raw.order_reviews               FROM '/data/olist_order_reviews_dataset.csv'        WITH (FORMAT csv, HEADER true);
\copy raw.products                    FROM '/data/olist_products_dataset.csv'             WITH (FORMAT csv, HEADER true);
\copy raw.sellers                     FROM '/data/olist_sellers_dataset.csv'              WITH (FORMAT csv, HEADER true);
\copy raw.product_category_translation FROM '/data/product_category_name_translation.csv'  WITH (FORMAT csv, HEADER true);

-- -----------------------------------------------------------------------------
-- Constraints que el dataset SÍ cumple (verificadas en 03_calidad_datos.sql).
-- Añadirlas ahora documenta el modelo y deja que el planificador las aproveche.
-- -----------------------------------------------------------------------------
ALTER TABLE raw.customers   ADD PRIMARY KEY (customer_id);
ALTER TABLE raw.orders      ADD PRIMARY KEY (order_id);
ALTER TABLE raw.order_items ADD PRIMARY KEY (order_id, order_item_id);
ALTER TABLE raw.order_payments ADD PRIMARY KEY (order_id, payment_sequential);
ALTER TABLE raw.products    ADD PRIMARY KEY (product_id);
ALTER TABLE raw.sellers     ADD PRIMARY KEY (seller_id);
ALTER TABLE raw.product_category_translation ADD PRIMARY KEY (product_category_name);

-- raw.order_reviews queda SIN PK a propósito: review_id se repite en el origen.
-- raw.geolocation queda SIN PK: hay varias coordenadas por prefijo postal.

ALTER TABLE raw.orders      ADD FOREIGN KEY (customer_id) REFERENCES raw.customers(customer_id);
ALTER TABLE raw.order_items ADD FOREIGN KEY (order_id)    REFERENCES raw.orders(order_id);
ALTER TABLE raw.order_items ADD FOREIGN KEY (product_id)  REFERENCES raw.products(product_id);
ALTER TABLE raw.order_items ADD FOREIGN KEY (seller_id)   REFERENCES raw.sellers(seller_id);
ALTER TABLE raw.order_payments ADD FOREIGN KEY (order_id) REFERENCES raw.orders(order_id);
ALTER TABLE raw.order_reviews  ADD FOREIGN KEY (order_id) REFERENCES raw.orders(order_id);

-- -----------------------------------------------------------------------------
-- Índices para los patrones de acceso del análisis
-- -----------------------------------------------------------------------------
CREATE INDEX idx_orders_purchase_ts   ON raw.orders (order_purchase_timestamp);
CREATE INDEX idx_orders_status        ON raw.orders (order_status);
CREATE INDEX idx_customers_unique_id  ON raw.customers (customer_unique_id);
CREATE INDEX idx_order_items_product  ON raw.order_items (product_id);
CREATE INDEX idx_order_items_seller   ON raw.order_items (seller_id);
CREATE INDEX idx_reviews_order        ON raw.order_reviews (order_id);
CREATE INDEX idx_geoloc_zip           ON raw.geolocation (geolocation_zip_code_prefix);

ANALYZE;

-- Recuento de control
SELECT 'customers'   AS tabla, count(*) FROM raw.customers
UNION ALL SELECT 'geolocation',   count(*) FROM raw.geolocation
UNION ALL SELECT 'orders',        count(*) FROM raw.orders
UNION ALL SELECT 'order_items',   count(*) FROM raw.order_items
UNION ALL SELECT 'order_payments',count(*) FROM raw.order_payments
UNION ALL SELECT 'order_reviews', count(*) FROM raw.order_reviews
UNION ALL SELECT 'products',      count(*) FROM raw.products
UNION ALL SELECT 'sellers',       count(*) FROM raw.sellers
UNION ALL SELECT 'categorias',    count(*) FROM raw.product_category_translation
ORDER BY 1;
