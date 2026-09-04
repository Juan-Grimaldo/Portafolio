# Guía de trabajo

Cuatro retos, en orden. Cada uno deja el terreno listo para el siguiente, así que
no los saltes: las decisiones del Reto 1 son las que hacen que el Reto 3 tenga
sentido.

**Tiempo estimado total: 8-12 horas** repartidas en varias sesiones.

---

## Reto 1 — Auditoría de datos · `sql/03_calidad_datos.sql`

**Objetivo:** encontrar qué está roto antes de calcular nada.

Este dataset esconde **al menos tres trampas** que invalidarían un análisis
ingenuo. Están señaladas en el archivo, pero no resueltas.

Seis apartados: grano de las tablas, completitud, distribución de estados,
cobertura temporal, coherencia entre fuentes, anomalías lógicas.

**Terminas cuando:** puedes responder a estas tres preguntas sin dudar.
- ¿Cuál de las dos columnas de `customers` identifica a la persona, y cómo lo sabes?

RTA: customer_unique_id es la columna que identifica al cliente, la columna customer_id vincula un cliente con un pedido concreto en relación 1:1, es decir por cada orden habra una customer_id independientemente si el clinte es el mismo. De los 99441 registros, 96096 son personas reales. Con el campo customer_unique_id se idenfico que se repetian varios registros con la misma información de cliente, sin embargo  la recompra es indetectable, porque cada persona aparece con exactamente 1 pedido por construcción.

- ¿Qué periodo del dataset es analizable y por qué los extremos no lo son?



- ¿Por qué `review_id` no puede ser clave primaria?

**Técnicas:** `count(*) FILTER`, `count(DISTINCT)`, `date_trunc`, window sobre agregado.

---

## Reto 2 — Capa analítica · `sql/04_modelo_analitico.sql`

**Objetivo:** convertir las decisiones del Reto 1 en tres vistas reutilizables.

Aquí es donde un script suelto se convierte en un modelo de datos. Si mañana
cambias la definición de "pedido válido", cambias una línea y no doce consultas.

Tres vistas: `fact_pedidos` (un registro por pedido), `fact_lineas` (una línea
de pedido), `dim_resenas` (una reseña por pedido, deduplicada).

**Terminas cuando:** la consulta de verificación al final del archivo da del
orden de 96.000 pedidos y 93.000 clientes. Si te salen 99.441 pedidos no
filtraste; si clientes == pedidos, caíste en la primera trampa.

**Técnicas:** vistas, `DISTINCT ON`, `LEFT JOIN` + `COALESCE`, agregación previa
al JOIN para no multiplicar filas.

---

## Reto 3 — Las seis preguntas · `sql/05_analisis_negocio.sql`

**Objetivo:** el análisis en sí. Cada pregunta introduce una técnica nueva.

| # | Pregunta | Técnica |
|---|---|---|
| P1 | Evolución mensual del negocio | `LAG()`, media móvil con `ROWS BETWEEN` |
| P2 | Concentración de catálogo | Acumulado Pareto con `SUM() OVER (ORDER BY)` |
| P3 | Segmentación RFM | `NTILE(5)`, CTEs encadenados |
| P4 | Retención y cohortes | Aritmética de fechas, pivote con `FILTER` |
| P5 | Coste de entregar tarde | Bucketing con `CASE`, agregados condicionales |
| P6 | Concentración de vendedores | `ROW_NUMBER()` + acumulado |

**El hilo argumental importa más que las consultas.** P4 y P5 se sostienen
mutuamente: lo que descubras sobre la recompra cambia el peso de lo que
descubras sobre las entregas. Si encuentras esa conexión, tienes un análisis y
no seis consultas sueltas.

**Terminas cuando:** cada pregunta tiene su párrafo de interpretación en el
README. Una consulta sin interpretación no vale nada en un portafolio.

---

## Reto 4 — Impacto y recomendación · `sql/06_impacto_y_recomendacion.sql`

**Objetivo:** convertir el hallazgo de P5 en una decisión con cifras.

Es el reto que separa un portafolio de junior de uno de analista. Cuatro
apartados: dimensión del problema en dinero, diagnóstico (¿estimación o
ejecución?), dónde actuar (rutas concretas), y el premio (escenario).

**Terminas cuando:** puedes decir en cinco líneas cuál es el problema, cuánto
cuesta, dónde atacarlo primero y qué se gana — y por qué va antes que otras
iniciativas.

---

## Cómo trabajar

**Explora en `psql` antes de escribir el archivo.** Abre una sesión interactiva,
prueba la consulta, ajústala, y solo cuando funcione la pasas al `.sql` con sus
comentarios.

```bash
docker exec -it olist_pg psql -U analyst -d olist
```

Comandos útiles de psql:

| Comando | Qué hace |
|---|---|
| `\dt raw.*` | Listar tablas del esquema |
| `\d raw.orders` | Ver estructura de una tabla |
| `\x` | Salida vertical (útil con muchas columnas) |
| `\timing` | Mostrar tiempo de ejecución |
| `\e` | Abrir la última consulta en un editor |
| `\q` | Salir |

**Guarda las salidas** en `resultados/` — son la evidencia del análisis:

```bash
docker exec -i olist_pg psql -U analyst -d olist -f /sql/05_analisis_negocio.sql \
  > resultados/05_analisis_negocio.txt
```

**Escribe el README a medida que avanzas**, no al final. Las interpretaciones
frescas son mejores que las reconstruidas.

---

## Si te atascas

En [`_soluciones/`](_soluciones/) está una versión resuelta completa del proyecto.

**Úsala como último recurso y por partes.** Consultar la solución de P3 después
de intentarla media hora es aprender; abrirla antes de empezar es perder el
proyecto. Lo que hace valioso este portafolio no es que las consultas existan,
es que puedas defenderlas en una entrevista.

Si prefieres no tener la tentación cerca, borra la carpeta: `rm -rf _soluciones/`

---

## Después de este proyecto

1. **Visualizaciones** — P1, P5 y las rutas del Reto 4 piden gráficos.
2. **Proyecto 2 en Python** — EDA y predicción del review score a partir de las
   variables logísticas. Continuación natural del hallazgo de P5.
3. **Dashboard interactivo** publicando los resultados.
4. **Subir a GitHub** — el repositorio no está inicializado todavía.
