# Olist — Análisis de un marketplace brasileño con SQL

> **Estado: en desarrollo.** Este README se irá reescribiendo con los hallazgos
> según avancen los retos. Ver [GUIA.md](GUIA.md) para el plan de trabajo.

Análisis end-to-end sobre datos reales de **Olist**, el mayor marketplace de Brasil:
99.441 pedidos, 1,4 millones de filas, 9 tablas relacionadas.

**Stack:** PostgreSQL 16 · Docker · SQL analítico

---

## Los datos

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
— pedidos reales anonimizados de septiembre 2016 a octubre 2018.

| Tabla | Filas | Contenido |
|---|---:|---|
| `orders` | 99.441 | Cabecera y ciclo de vida del pedido |
| `order_items` | 112.650 | Detalle: producto, vendedor, precio, flete |
| `order_payments` | 103.886 | Pagos (varios por pedido) |
| `order_reviews` | 99.224 | Valoración 1-5 y comentario |
| `customers` | 99.441 | Cliente y localización |
| `products` | 32.951 | Catálogo y dimensiones físicas |
| `sellers` | 3.095 | Vendedores del marketplace |
| `geolocation` | 1.000.163 | Coordenadas por código postal |
| `product_category_translation` | 71 | Diccionario PT → EN |

---

## Puesta en marcha

```bash
# 1. Descargar los datos (~120 MB, no van en Git)
cd data && bash descargar_datos.sh

# 2. Levantar PostgreSQL 16 (puerto 5433)
cd ../docker && docker compose up -d

# 3. Crear el esquema y cargar los CSV
docker exec -i olist_pg psql -U analyst -d olist -f /sql/01_schema.sql
docker exec -i olist_pg psql -U analyst -d olist -f /sql/02_carga.sql
```

Sesión interactiva para explorar:

```bash
docker exec -it olist_pg psql -U analyst -d olist
```

---

## Estructura

| Archivo | Estado |
|---|---|
| [`sql/01_schema.sql`](sql/01_schema.sql) | Listo — DDL del esquema `raw` |
| [`sql/02_carga.sql`](sql/02_carga.sql) | Listo — carga CSV, claves, FKs e índices |
| [`sql/03_calidad_datos.sql`](sql/03_calidad_datos.sql) | Reto 1 — auditoría |
| [`sql/04_modelo_analitico.sql`](sql/04_modelo_analitico.sql) | Reto 2 — capa `analytics` |
| [`sql/05_analisis_negocio.sql`](sql/05_analisis_negocio.sql) | Reto 3 — las seis preguntas |
| [`sql/06_impacto_y_recomendacion.sql`](sql/06_impacto_y_recomendacion.sql) | Reto 4 — impacto y recomendación |

---

## Resumen ejecutivo

<!-- Escribir al terminar los cuatro retos.
     Tres párrafos como máximo: el hallazgo principal con su cifra, por qué
     importa, y qué recomiendas hacer. Es lo único que leerá mucha gente. -->

_Pendiente._

## Auditoría de datos

<!-- Reto 1. Un párrafo por problema encontrado:
     titular en negrita, la cifra, qué habría pasado si no lo detectas,
     y qué decidiste hacer. Incluye también lo que está limpio. -->

_Pendiente._

## Hallazgos

<!-- Reto 3. Un bloque por pregunta. Tabla + interpretación.
     La interpretación es lo que cuenta: no describas la tabla, di qué
     significa para el negocio. -->

_Pendiente._

## Recomendación

<!-- Reto 4. Los cinco puntos del entregable. -->

_Pendiente._

## Limitaciones

<!-- Qué NO puede afirmar este análisis. Mínimo: la censura a la derecha en
     las cohortes y el carácter no causal del escenario del Reto 4. -->

_Pendiente._

## Técnicas SQL aplicadas

<!-- Se va rellenando según avanzas. Sirve de índice para el reclutador. -->

_Pendiente._
