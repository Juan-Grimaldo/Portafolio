# Cómo conectarse y ejecutar consultas

## Datos de conexión

| Parámetro | Valor |
|---|---|
| Host | `localhost` |
| Puerto | **`5433`** ← no el 5432 por defecto |
| Base de datos | `olist` |
| Usuario | `analyst` |
| Contraseña | `analyst` |

Cadena de conexión:

```
postgresql://analyst:analyst@localhost:5433/olist
```

> El contenedor usa el 5432 internamente, pero se publica en el **5433** para no
> chocar con un PostgreSQL que tengas instalado en Windows.

---

## Opción A — VS Code (recomendada)

Escribes en el `.sql`, seleccionas un bloque, lo ejecutas y ves la tabla en un
panel al lado. Es el flujo natural para estos retos.

```bash
code --install-extension ms-ossdata.vscode-pgsql
```

Después: icono de PostgreSQL en la barra lateral → **Add Connection** → mete los
datos de arriba.

Uso: abre `sql/03_calidad_datos.sql`, escribe tu consulta, selecciónala y pulsa
`Ctrl+Shift+E` (o clic derecho → *Run Query*). Sin selección ejecuta el archivo
entero, así que **selecciona siempre el bloque** mientras trabajas.

Alternativa clásica si prefieres: `code --install-extension mtxr.sqltools` junto
con `mtxr.sqltools-driver-pg`.

---

## Opción B — psql en el contenedor (cero instalación)

Ya funciona, no requiere instalar nada:

```bash
docker exec -it olist_pg psql -U analyst -d olist
```

Ideal para exploración rápida y para inspeccionar estructuras.

| Comando | Qué hace |
|---|---|
| `\dt raw.*` | Listar tablas del esquema |
| `\d raw.orders` | Estructura de una tabla |
| `\x` | Salida vertical (con muchas columnas) |
| `\timing` | Mostrar tiempo de ejecución |
| `\e` | Editar la última consulta en un editor |
| `\i /sql/03_calidad_datos.sql` | Ejecutar un archivo |
| `\q` | Salir |

Ejecutar un archivo completo y guardar la salida:

```bash
docker exec -i olist_pg psql -U analyst -d olist -f /sql/05_analisis_negocio.sql \
  > resultados/05_analisis_negocio.txt
```

> **En Git Bash**, si te da error de ruta (`C:/Program Files/Git/sql/...`),
> ejecuta antes `export MSYS_NO_PATHCONV=1`. Git Bash traduce las rutas que
> empiezan por `/` a rutas de Windows, y aquí son rutas de dentro del contenedor.
> En PowerShell no pasa.

---

## Opción C — DBeaver (GUI completa)

Útil si quieres ver diagramas del modelo, explorar tablas visualmente o exportar
resultados a CSV/Excel con un clic.

Descarga: <https://dbeaver.io/download/> (Community Edition, gratuita)

`Nueva conexión` → PostgreSQL → los datos de la tabla de arriba.

---

## Recomendación

**A + B combinadas.** Explora en `psql` mientras pruebas ideas (es más rápido
para un `count(*)` suelto), y usa VS Code para escribir la consulta definitiva
con sus comentarios en el `.sql`.

DBeaver merece la pena si en algún momento quieres exportar tablas para hacer
gráficos.

---

## Gestión del contenedor

```bash
cd docker

docker compose ps       # ¿está corriendo?
docker compose up -d    # arrancar
docker compose stop     # parar (los datos se conservan)
docker compose down     # parar y borrar el contenedor (los datos se conservan
                        # en el volumen pgdata)
docker compose down -v  # CUIDADO: borra también los datos, habría que recargar
```

Si Docker Desktop está cerrado, el contenedor no responde: ábrelo y luego
`docker compose up -d`.
