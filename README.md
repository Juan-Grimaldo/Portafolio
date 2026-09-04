# Portafolio de Análisis de Datos

Proyectos de análisis end-to-end sobre datasets reales: desde el modelado y la
auditoría de calidad hasta recomendaciones de negocio con impacto cuantificado.

---

## Proyectos

### 1. [Olist — Análisis de un marketplace brasileño](01-sql-olist-ecommerce/) · SQL

**En desarrollo.** Análisis de 99.441 pedidos reales (1,4 M de filas, 9 tablas)
del mayor marketplace de Brasil, en PostgreSQL: auditoría de calidad, capa
analítica, seis preguntas de negocio y una recomendación con impacto cuantificado.

`PostgreSQL 16` · `Docker` · window functions · CTEs · RFM · análisis de cohortes

---

## Enfoque

Cada proyecto sigue la misma estructura, porque el orden importa:

1. **Auditoría antes que análisis.** Qué está roto en los datos y cómo condiciona
   las conclusiones. Un análisis sin este paso produce resultados bonitos y falsos.
2. **Reglas de negocio centralizadas.** Los filtros y definiciones viven en una
   capa de vistas, no repetidos en cada consulta.
3. **Preguntas de negocio, no demos técnicas.** La técnica aparece donde la
   pregunta la exige.
4. **Impacto cuantificado.** Un hallazgo sin cifra no mueve decisiones.
5. **Limitaciones explícitas.** Lo que el análisis *no* puede afirmar.

---

## Cómo navegar

Cada carpeta de proyecto es autocontenida e incluye su propio README con el
resumen ejecutivo, la metodología y los resultados. El código es reproducible:
los entornos se levantan con Docker y los datos se descargan con un script.
