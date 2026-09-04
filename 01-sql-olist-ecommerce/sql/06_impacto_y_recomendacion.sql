-- =============================================================================
-- 06_impacto_y_recomendacion.sql | RETO 4 — De hallazgo a decisión
--
-- Este es el reto que separa un portafolio de junior de uno de analista. En P5
-- descubriste QUÉ pasa. Aquí respondes CUÁNTO CUESTA, DÓNDE ACTUAR y QUÉ SE GANA.
--
-- Un hallazgo sin cifra de impacto no mueve presupuesto.
--
-- Ejecutar:
--   docker exec -i olist_pg psql -U analyst -d olist -f /sql/06_impacto_y_recomendacion.sql
-- =============================================================================


-- -----------------------------------------------------------------------------
-- A.  DIMENSIÓN DEL PROBLEMA
--
-- Pon una cifra de dinero al hallazgo de P5. Calcula sobre fact_pedidos:
--   - nº de pedidos que llegaron tarde
--   - ingreso de esos pedidos, en absoluto y como % del total
--   - ticket medio de los tardíos vs. el de los que llegaron a tiempo
--
-- PISTA: todo en un solo SELECT con count(*) FILTER y sum(...) FILTER.
--
-- QUÉ MIRAR: si el ticket medio de los tardíos es MAYOR, no es casualidad.
--   Piensa qué tipo de envío tarda más y qué implica para el negocio que sean
--   precisamente los pedidos caros los que fallan.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- B.  EL COLCHÓN DE LA PROMESA
--
-- Antes de recomendar "mejorar la logística", comprueba si el problema es la
-- ESTIMACIÓN o la EJECUCIÓN. Calcula la media de:
--   - días prometidos al cliente  (fecha_estimada - fecha_compra)
--   - días reales de entrega      (ya lo tienes: dias_entrega)
--   - el colchón entre ambos, en media y mediana
--
-- QUÉ MIRAR: si el colchón es grande y AUN ASÍ se incumple, la recomendación
--   "sé más conservador con las fechas" no sirve — ya lo son. El problema está
--   en la cola de la distribución, no en el centro. Ese razonamiento es el que
--   hace que tu recomendación sea creíble.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- C.  DÓNDE ACTUAR: rutas concretas
--
-- "Mejorar la logística" no es accionable. "Auditar la ruta X" sí lo es.
--
-- Construye un análisis por CORREDOR (estado del vendedor -> estado del cliente):
--   pedidos, días medios de entrega, % de tardíos, ingreso en riesgo.
--
-- PISTA: necesitas el seller_state, que está en raw.sellers, vía raw.order_items.
--   CUIDADO: un pedido puede tener varios vendedores. Si haces JOIN directo,
--   duplicarás pedidos. Usa (SELECT DISTINCT order_id, seller_id FROM ...) y
--   asume el criterio que decidas — pero DOCUMENTA cuál elegiste y por qué.
--
-- Filtra con HAVING count(*) >= 300 para quedarte con rutas relevantes.
--
-- QUÉ MIRAR (decisión de analista, no de SQL):
--   Vas a encontrar rutas con MUY MAL porcentaje pero poco volumen, y rutas con
--   porcentaje algo peor que la media pero volumen enorme. ¿Cuál priorizas?
--   Ordena por % de tardíos y luego mira la columna de ingreso en riesgo: no
--   siempre coinciden. Justifica tu elección — eso es lo que te preguntarán.
-- -----------------------------------------------------------------------------

-- TODO


-- -----------------------------------------------------------------------------
-- D.  EL PREMIO: escenario contrafactual
--
-- Estima qué se gana si se arregla el problema. Modelo simple y explícito:
--   "Si los pedidos con más de 7 días de retraso se entregaran a tiempo,
--    tendrían el mismo perfil de reseñas que el grupo 'en la fecha'."
--
-- Calcula: pedidos afectados, reseñas negativas actuales, reseñas negativas
--   esperadas bajo el escenario, y la diferencia (las evitables).
--
-- PISTA: un CTE con las cifras actuales del grupo tardío, otro con el % de
--   reseñas malas del grupo "en la fecha", y un SELECT que los cruce.
--   Se pueden cruzar dos CTEs de una fila con  FROM cte_a, cte_b  (producto
--   cartesiano de 1x1 = 1 fila).
--
-- OBLIGATORIO: escribe en el README que esto NO es una estimación causal. Es un
--   dimensionamiento del premio bajo un supuesto explícito. Probar causalidad
--   exigiría un experimento. Decir esto tú antes de que te lo pregunten es
--   exactamente lo que distingue a un analista serio.
-- -----------------------------------------------------------------------------

-- TODO


-- =============================================================================
-- ENTREGABLE DEL RETO 4 — la recomendación
--
-- Escribe en el README un bloque de 5-6 líneas que responda:
--   1. Cuál es el problema, con su cifra en dinero.
--   2. Por qué NO es un problema de estimación de fechas (usa el dato de B).
--   3. Dónde actuar primero, con nombre concreto (el resultado de C).
--   4. Qué se gana (el resultado de D).
--   5. Por qué esto va ANTES que cualquier iniciativa de retención — conéctalo
--      con lo que descubriste en P4 sobre la tasa de recompra.
--
-- El punto 5 es el que convierte el proyecto en un análisis y no en una lista
-- de consultas. Si logras que P4 y P5 se sostengan mutuamente, tienes un
-- portafolio que se defiende solo en una entrevista.
-- =============================================================================
