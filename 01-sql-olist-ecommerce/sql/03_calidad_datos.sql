-- =============================================================================
-- 03_calidad_datos.sql | RETO 1 — Auditoría del dataset
--
-- Un análisis que no audita sus datos primero produce conclusiones bonitas y
-- falsas. Antes de calcular nada, hay que saber qué está roto.
--
-- Este dataset tiene AL MENOS TRES TRAMPAS que invalidarían un análisis hecho
-- de forma ingenua. Tu trabajo aquí es encontrarlas.
--
-- Ejecutar:
--   docker exec -i olist_pg psql -U analyst -d olist -f /sql/03_calidad_datos.sql
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1.1  GRANO DE LAS TABLAS
--
-- Pregunta: ¿son únicas las claves que damos por únicas?
--
-- Comprueba, para cada una: nº de filas vs. nº de valores distintos.
--   - raw.orders.order_id
--   - raw.order_reviews.review_id
--   - raw.customers.customer_id
--   - raw.customers.customer_unique_id      <-- mira esta con MUCHA atención
--
-- PISTA: count(*) vs count(DISTINCT col) en la misma consulta.
--        Para verlas todas juntas, une los resultados con UNION ALL.
--
-- ¿POR QUÉ IMPORTA? La tabla `customers` tiene DOS columnas de identificador.
-- Si son distintas, una de ellas no significa lo que parece. Averigua cuál es
-- el cliente-persona y cuál es otra cosa. Esta decisión cambia por completo
-- cualquier métrica de clientes que calcules después.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- 1.2  COMPLETITUD
--
-- Pregunta: ¿qué porcentaje de NULLs tienen los campos que vas a usar?
--
-- Mide en raw.orders:  order_approved_at, order_delivered_customer_date,
--                      order_delivered_carrier_date
-- Mide en raw.products: product_category_name, product_weight_g
--
-- PISTA: count(*) FILTER (WHERE col IS NULL) es más legible que sum(CASE...).
--        Multiplica por 100.0 (no por 100) o la división entera te dará 0.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- 1.3  DISTRIBUCIÓN DE ESTADOS
--
-- Pregunta: ¿qué fracción de los pedidos es venta realmente consumada?
--
-- Cuenta pedidos por order_status, con su porcentaje sobre el total.
--
-- PISTA: para el porcentaje sin repetir la consulta, usa una window function:
--        100.0 * count(*) / sum(count(*)) OVER ()
--        (sí, se puede agregar sobre un agregado — es una window sobre el
--         resultado del GROUP BY)
--
-- DECISIÓN QUE DEBES TOMAR: ¿qué estados entran en el análisis de ingresos?
-- Anota tu respuesta y el porqué; la aplicarás en el Reto 2.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- 1.4  COBERTURA TEMPORAL   <-- TRAMPA
--
-- Pregunta: ¿todos los meses del dataset son comparables entre sí?
--
-- Cuenta pedidos por mes (date_trunc) y mira los PRIMEROS y los ÚLTIMOS meses
-- de la serie, no solo el total.
--
-- PISTA: date_trunc('month', ts)::date agrupa por mes.
--        Haz dos consultas: ORDER BY mes ASC LIMIT 5, y DESC LIMIT 5.
--
-- ¿QUÉ BUSCAS? Meses con un número de pedidos absurdamente bajo comparado con
-- sus vecinos. Si los dejas dentro, tu gráfico de evolución mostrará un
-- crecimiento espectacular que no es negocio: es cobertura de datos.
--
-- DECISIÓN QUE DEBES TOMAR: define el periodo analizable. Anótalo.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- 1.5  COHERENCIA ENTRE FUENTES
--
-- Pregunta: el valor de un pedido, ¿lo saco de order_items o de order_payments?
--
-- Compara por pedido:  sum(price + freight_value)  vs  sum(payment_value)
-- ¿En cuántos pedidos coinciden? ¿Cuál es la desviación media y la máxima?
--
-- PISTA: dos CTEs (uno por tabla, agregando por order_id) y luego un JOIN.
--        Para "coinciden", cuidado con los decimales: usa abs(a-b) < 0.01.
--
-- Si cuadran casi siempre, puedes elegir cualquiera con confianza. Si no,
-- tienes que investigar por qué antes de seguir.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- 1.6  ANOMALÍAS LÓGICAS
--
-- Pregunta: ¿hay fechas imposibles?
--
-- Cuenta pedidos donde:
--   - la entrega es anterior a la compra
--   - la aprobación es anterior a la compra
--   - el status es 'delivered' pero no hay fecha de entrega
--
-- PISTA: count(*) FILTER (WHERE ...) tres veces en un solo SELECT.
-- -----------------------------------------------------------------------------

-- TODO


-- =============================================================================
-- ENTREGABLE DEL RETO 1
--
-- Al terminar, escribe en el README del proyecto (sección "Auditoría") un
-- párrafo por cada problema encontrado, con este formato:
--
--   **Titular del problema.** Qué encontraste, con la cifra. Qué habría pasado
--   si no lo detectas. Qué decides hacer al respecto.
--
-- Y también lo que está LIMPIO: es igual de informativo y da credibilidad.
-- Comprueba si las 6 foreign keys del script 02 se aplicaron sin rechazos.
--
-- NÚMEROS DE CONTROL (para verificar que vas bien, no para copiar):
--   - Las tres trampas están en 1.1, 1.4 y 1.1 otra vez (hay dos en el grano).
--   - En 1.3 un estado concentra más del 95% de los pedidos.
--   - En 1.5 la coincidencia supera el 99%.
-- =============================================================================
