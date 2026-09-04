-- =============================================================================
-- 01_schema.sql | Olist Brazilian E-Commerce
-- Crea el esquema `raw` con las 9 tablas del dataset original.
--
-- Decisiones de modelado:
--   * Sin constraints en la creación: primero cargamos, luego validamos.
--     Cargar con FKs activas fallaría por filas huérfanas legítimas del dataset.
--   * TIMESTAMP sin zona horaria: el dataset viene en hora local de Brasil (BRT)
--     y no trae offset. Documentarlo vale más que inventar una conversión.
--   * NUMERIC (no FLOAT) para dinero: precisión exacta en sumas y márgenes.
-- =============================================================================

DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA raw;

-- Clientes. Ojo: customer_id es único POR PEDIDO.
-- El identificador real de la persona es customer_unique_id.
CREATE TABLE raw.customers (
    customer_id              TEXT,
    customer_unique_id       TEXT,
    customer_zip_code_prefix TEXT,
    customer_city            TEXT,
    customer_state           CHAR(2)
);

-- Geolocalización por prefijo de código postal. Varias filas por prefijo.
CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat             NUMERIC(12,8),
    geolocation_lng             NUMERIC(12,8),
    geolocation_city            TEXT,
    geolocation_state           CHAR(2)
);

-- Cabecera del pedido: un registro por pedido, con el ciclo de vida completo.
CREATE TABLE raw.orders (
    order_id                      TEXT,
    customer_id                   TEXT,
    order_status                  TEXT,
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Detalle del pedido. Grano: (order_id, order_item_id).
-- price y freight_value son POR UNIDAD de línea, no del pedido completo.
CREATE TABLE raw.order_items (
    order_id            TEXT,
    order_item_id       INTEGER,
    product_id          TEXT,
    seller_id           TEXT,
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10,2),
    freight_value       NUMERIC(10,2)
);

-- Pagos. Un pedido puede tener varios (ej. dos tarjetas + voucher).
CREATE TABLE raw.order_payments (
    order_id             TEXT,
    payment_sequential   INTEGER,
    payment_type         TEXT,
    payment_installments INTEGER,
    payment_value        NUMERIC(10,2)
);

-- Reseñas. review_id NO es único en el origen (hay duplicados reales).
CREATE TABLE raw.order_reviews (
    review_id               TEXT,
    order_id                TEXT,
    review_score            SMALLINT,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- Productos. Los campos dimensionales traen NULLs; "lenght" es un typo del origen
-- que conservamos para no romper la trazabilidad con el CSV fuente.
CREATE TABLE raw.products (
    product_id                 TEXT,
    product_category_name      TEXT,
    product_name_lenght        INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           INTEGER,
    product_length_cm          INTEGER,
    product_height_cm          INTEGER,
    product_width_cm           INTEGER
);

CREATE TABLE raw.sellers (
    seller_id                TEXT,
    seller_zip_code_prefix   TEXT,
    seller_city              TEXT,
    seller_state             CHAR(2)
);

-- Diccionario de categorías: portugués -> inglés.
CREATE TABLE raw.product_category_translation (
    product_category_name         TEXT,
    product_category_name_english TEXT
);
