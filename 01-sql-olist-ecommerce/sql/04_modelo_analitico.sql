-- =============================================================================
-- 04_modelo_analitico.sql | RETO 2 — La capa `analytics`
--
-- Las decisiones que tomaste en el Reto 1 se aplican UNA vez aquí, no repetidas
-- en cada consulta. Esta es la diferencia entre un script suelto y un modelo de
-- datos: si mañana cambias la definición de "pedido válido", cambias una línea.
--
-- Ejecutar:
--   docker exec -i olist_pg psql -U analyst -d olist -f /sql/04_modelo_analitico.sql
-- =============================================================================

DROP SCHEMA IF EXISTS analytics CASCADE;
CREATE SCHEMA analytics;


-- -----------------------------------------------------------------------------
-- 2.1  VISTA  analytics.fact_pedidos    (grano: un registro por pedido)
--
-- Debe aplicar tus tres decisiones del Reto 1:
--   a) filtrar por el estado que representa venta consumada
--   b) filtrar al periodo temporal analizable
--   c) usar el identificador de cliente CORRECTO (el de la trampa de 1.1)
--
-- Columnas que necesitarás en los retos siguientes:
--   order_id, cliente_id, estado (customer_state), ciudad,
--   fecha_compra, mes_compra (date_trunc a mes),
--   fecha_entrega, fecha_estimada,
--   n_items, ingreso, flete, ticket_total,
--   dias_entrega     -> días entre compra y entrega real
--   dias_vs_promesa  -> días entre entrega real y fecha estimada
--                       (POSITIVO = llegó tarde. Piensa bien el orden de la resta,
--                        te va a confundir al interpretar el Reto 3.)
--
-- PISTA sobre el ingreso: raw.order_items tiene VARIAS filas por pedido. Si haces
--   JOIN directo con orders y sumas, multiplicarás filas. Agrega order_items en
--   un subquery/CTE con GROUP BY order_id ANTES de unirlo.
--
-- PISTA sobre precio vs flete: mantenlos en columnas separadas. Sumar el flete al
--   ingreso mezcla facturación con venta comercial; que la decisión sea tuya
--   después, no una que ya viene cocida en la vista.
--
-- PISTA de sintaxis: EXTRACT(DAY FROM ts_a - ts_b)::int te da los días entre dos
--   timestamps.
--
-- CUIDADO: hay pedidos marcados 'delivered' sin fecha de entrega (lo viste en 1.6).
--   Si no los excluyes, dias_entrega será NULL y descuadrará los conteos.
-- -----------------------------------------------------------------------------

-- TODO
-- CREATE VIEW analytics.fact_pedidos AS
-- ...


-- -----------------------------------------------------------------------------
-- 2.2  VISTA  analytics.fact_lineas    (grano: una línea de pedido)
--
-- Para analizar por producto y categoría. Parte de raw.order_items y añade:
--   - la categoría en inglés (raw.product_category_translation)
--   - las columnas de contexto del pedido: cliente_id, mes_compra, estado
--
-- PISTA: haz JOIN con analytics.fact_pedidos (no con raw.orders) para heredar
--   automáticamente los filtros que ya definiste. Reutilizar la vista anterior
--   es justamente el punto de tener una capa analítica.
--
-- CUIDADO: en 1.2 viste que un ~2% de productos no tiene categoría, y no todas
--   las categorías están en el diccionario de traducción. Con INNER JOIN pierdes
--   esas filas en silencio. Usa LEFT JOIN + COALESCE(..., 'sin_categoria').
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- 2.3  VISTA  analytics.dim_resenas    (grano: UNA fila por pedido)
--
-- raw.order_reviews tiene duplicados (lo viste en 1.1). Necesitas quedarte con
-- una sola reseña por pedido: la MÁS RECIENTE, que es la valoración vigente.
--
-- PISTA: Postgres tiene DISTINCT ON, que hace esto en tres líneas:
--     SELECT DISTINCT ON (order_id) order_id, review_score, ...
--     FROM raw.order_reviews
--     ORDER BY order_id, review_answer_timestamp DESC;
--   La regla: las columnas del DISTINCT ON deben ir primero en el ORDER BY.
--
--   Alternativa estándar (útil si algún día trabajas en otro motor):
--     ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY ... DESC) y filtrar = 1.
--   Merece la pena que escribas las dos y compares.
-- -----------------------------------------------------------------------------

-- TODO


-- =============================================================================
-- VERIFICACIÓN DEL RETO 2
--
-- Descomenta y ejecuta. Si tus vistas están bien construidas:
--
--   SELECT count(*)                        AS pedidos,
--          count(DISTINCT cliente_id)      AS clientes,
--          round(sum(ingreso))             AS ingreso_total,
--          min(mes_compra), max(mes_compra)
--   FROM analytics.fact_pedidos;
--
-- Deberías obtener del orden de 96.000 pedidos y 93.000 clientes, con un
-- ingreso total sobre 13 millones. Si te salen 99.441 pedidos, no filtraste.
-- Si clientes == pedidos, caíste en la trampa del identificador.
--
--   SELECT count(*) FROM analytics.dim_resenas;   -- debe ser < 99.224
-- =============================================================================
