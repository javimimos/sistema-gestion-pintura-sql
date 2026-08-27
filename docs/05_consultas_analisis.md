# 5. Consultas y análisis SQL

## 5.1. Introducción

Este documento recoge y describe las consultas SQL desarrolladas para analizar la información almacenada en la base de datos de **Pinturillas SA**.

El conjunto está formado por **38 consultas**, diseñadas con diferentes niveles de dificultad. El objetivo no es únicamente comprobar que la base de datos funciona correctamente, sino también demostrar el uso de diferentes recursos del lenguaje SQL para obtener información operativa y realizar análisis sobre los datos.

Las consultas completas se encuentran en:

```text
sql/04_consultas.sql
```

En este documento se explica el objetivo de cada consulta y las principales técnicas SQL utilizadas.

Las consultas se organizan por **nivel de dificultad**, en lugar de agruparlas exclusivamente por las tablas que utilizan. De esta forma, se muestra una progresión desde operaciones básicas hasta consultas que combinan varias técnicas de análisis.

---

## 5.2. Nivel 1 — Consultas básicas

Las primeras consultas utilizan operaciones fundamentales de SQL, como `SELECT`, `WHERE`, `JOIN`, `DISTINCT`, subconsultas sencillas y funciones de agregación básicas.

### Consulta 1 — Clientes registrados

**Objetivo:** obtener el listado de clientes registrados actualmente en el sistema.

**Técnicas utilizadas:**

* `SELECT`
* Consulta directa sobre una tabla.

---

### Consulta 2 — Número de clientes

**Objetivo:** conocer cuántos clientes están registrados.

**Técnicas utilizadas:**

* `COUNT()`
* Funciones de agregación.

---

### Consulta 3 — Clientes con presupuestos aceptados

**Objetivo:** identificar los clientes que tienen al menos un presupuesto aceptado.

**Técnicas utilizadas:**

* `JOIN`
* `DISTINCT`
* `WHERE`

---

### Consulta 4 — Clientes con más de un presupuesto

**Objetivo:** identificar los clientes que han solicitado más de un presupuesto.

**Técnicas utilizadas:**

* `JOIN`
* `GROUP BY`
* `HAVING`
* `COUNT()`

---

### Consulta 5 — Catálogo de servicios

**Objetivo:** consultar los servicios disponibles y su precio unitario actual.

**Técnicas utilizadas:**

* `SELECT`
* Proyección de columnas.

---

### Consulta 6 — Servicio más caro

**Objetivo:** determinar cuál es el servicio con mayor precio unitario.

**Técnicas utilizadas:**

* `MAX()`
* Subconsulta.
* Comparación con el valor máximo.

---

### Consulta 7 — Tipos de pintura

**Objetivo:** consultar los tipos de pintura disponibles y su suplemento actual.

**Técnicas utilizadas:**

* `SELECT`

---

### Consulta 8 — Presupuestos por estado

**Objetivo:** conocer cuántos presupuestos existen en cada estado.

**Técnicas utilizadas:**

* `COUNT()`
* `GROUP BY`

---

### Consulta 9 — Presupuestos rechazados

**Objetivo:** obtener los presupuestos rechazados junto con el cliente que los solicitó.

**Técnicas utilizadas:**

* `JOIN`
* `WHERE`

---

### Consulta 10 — Presupuestos pendientes de respuesta

**Objetivo:** identificar los presupuestos que han sido enviados y todavía están pendientes de respuesta.

**Técnicas utilizadas:**

* `WHERE`
* Filtrado por estado.

---

## 5.3. Nivel 2 — Agregaciones y combinaciones

En este nivel se incorporan consultas que requieren realizar cálculos sobre grupos de registros y combinar información procedente de varias tablas.

### Consulta 11 — Importe total de cada presupuesto

**Objetivo:** calcular el importe total de cada presupuesto a partir de sus detalles.

**Técnicas utilizadas:**

* `JOIN`
* `LEFT JOIN`
* `SUM()`
* `COALESCE()`
* `GROUP BY`

El uso de `LEFT JOIN` permite mantener también los presupuestos que no tengan detalles asociados.

---

### Consulta 12 — Presupuesto de mayor importe

**Objetivo:** determinar cuál es el presupuesto con mayor importe total.

**Técnicas utilizadas:**

* `SUM()`
* `GROUP BY`
* `WITH`
* `MAX()`
* Subconsulta.

---

### Consulta 13 — Importe medio de los presupuestos aceptados

**Objetivo:** calcular el importe medio de los presupuestos cuyo estado es `aceptado`.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `AVG()`
* `GROUP BY`
* `ROUND()`

Primero se obtiene el importe individual de cada presupuesto y posteriormente se calcula la media de esos importes.

---

### Consulta 14 — Obras por estado

**Objetivo:** conocer cuántas obras existen en cada estado.

**Técnicas utilizadas:**

* `COUNT()`
* `GROUP BY`

---

### Consulta 15 — Obras en curso

**Objetivo:** identificar las obras cuyo estado actual es `en_curso`.

**Técnicas utilizadas:**

* `WHERE`

---

### Consulta 16 — Duración de las obras finalizadas

**Objetivo:** obtener las obras finalizadas y calcular su duración en días.

**Técnicas utilizadas:**

* Operaciones con fechas.
* Resta de fechas.
* `WHERE`

---

### Consulta 17 — Clientes con obras en curso

**Objetivo:** identificar qué clientes tienen actualmente una obra en ejecución.

**Técnicas utilizadas:**

* `JOIN`
* `DISTINCT`
* `WHERE`

La información debe recorrer la relación entre `CLIENTE`, `PRESUPUESTO` y `OBRA`.

---

### Consulta 18 — Empleados asignados a las obras

**Objetivo:** mostrar los empleados que participan en cada obra.

**Técnicas utilizadas:**

* `JOIN`
* Relación mediante `ASIGNACION_EMPLEADO`
* `ORDER BY`

---

## 5.4. Nivel 3 — Análisis y agregaciones avanzadas

Estas consultas combinan varias tablas y operaciones de agrupación para obtener indicadores útiles para la gestión de la empresa.

### Consulta 19 — Empleados con mayor participación

**Objetivo:** determinar qué empleados han participado en un mayor número de obras.

**Técnicas utilizadas:**

* `JOIN`
* `COUNT(DISTINCT ...)`
* `GROUP BY`
* `ORDER BY`

El uso de `DISTINCT` evita contar varias veces una misma obra en caso de existir más de un registro de asignación.

---

### Consulta 20 — Obras canceladas

**Objetivo:** obtener las obras cuyo estado es `cancelada`.

**Técnicas utilizadas:**

* `WHERE`

---

### Consulta 21 — Facturas por estado

**Objetivo:** conocer cuántas facturas existen en cada estado.

**Técnicas utilizadas:**

* `COUNT()`
* `GROUP BY`

---

### Consulta 22 — Facturas pendientes de pago

**Objetivo:** identificar las facturas que han sido enviadas pero todavía no constan como pagadas.

**Técnicas utilizadas:**

* `WHERE`
* Filtrado por estado.

---

### Consulta 23 — Clientes con facturas pendientes

**Objetivo:** identificar los clientes que tienen facturas pendientes de pago y conocer cuántas tienen.

**Técnicas utilizadas:**

* Múltiples `JOIN`
* `COUNT()`
* `GROUP BY`
* `WHERE`

---

### Consulta 24 — Facturación total

**Objetivo:** calcular la facturación total correspondiente a las facturas pagadas.

**Técnicas utilizadas:**

* `SUM()`
* `WHERE`

---

### Consulta 25 — Factura de mayor importe

**Objetivo:** determinar cuál es la factura con mayor importe.

**Técnicas utilizadas:**

* `MAX()`
* Subconsulta.

---

### Consulta 26 — Tiempo medio de pago

**Objetivo:** calcular cuántos días tardan de media los clientes en pagar las facturas pagadas.

**Técnicas utilizadas:**

* Operaciones con fechas.
* `WITH`
* `AVG()`
* Filtrado por estado.

El tiempo se obtiene mediante la diferencia entre `fecha_pago` y `fecha_envio`.

---

### Consulta 27 — Facturación por cliente

**Objetivo:** conocer la facturación generada por cada cliente.

**Técnicas utilizadas:**

* Múltiples `JOIN`
* `SUM()`
* `GROUP BY`
* `ORDER BY`

---

### Consulta 28 — Servicios con mayor importe económico

**Objetivo:** determinar qué servicios generan un mayor importe económico en los presupuestos aceptados.

**Técnicas utilizadas:**

* `JOIN`
* `SUM()`
* `GROUP BY`
* `ORDER BY`

---

### Consulta 29 — Servicios utilizados con mayor frecuencia

**Objetivo:** conocer qué servicios aparecen con mayor frecuencia en los detalles de los presupuestos.

**Técnicas utilizadas:**

* `JOIN`
* `COUNT()`
* `GROUP BY`
* `ORDER BY`

---

## 5.5. Nivel 4 — Análisis empresarial avanzado

Este nivel introduce consultas destinadas a obtener indicadores empresariales y comparar diferentes magnitudes.

### Consulta 30 — Porcentaje de aceptación de presupuestos

**Objetivo:** calcular qué porcentaje de los presupuestos enviados termina siendo aceptado.

**Técnicas utilizadas:**

* `CASE`
* `AVG()`
* `ROUND()`
* Filtrado mediante `WHERE`

---

### Consulta 31 — Porcentaje de rechazo de presupuestos

**Objetivo:** calcular qué porcentaje de los presupuestos enviados termina siendo rechazado.

**Técnicas utilizadas:**

* `CASE`
* `AVG()`
* `ROUND()`
* Filtrado mediante `WHERE`

---

### Consulta 32 — Empleados y obras de mayor importe

**Objetivo:** identificar los empleados que han participado en obras con mayor importe total.

**Técnicas utilizadas:**

* Múltiples `JOIN`
* `DISTINCT`
* Ordenación por importe.

Esta consulta relaciona empleados, asignaciones, obras y facturas para conocer la relación entre participación de empleados e importe económico de las obras.

---

### Consulta 33 — Facturación por mes

**Objetivo:** conocer qué meses han generado un mayor volumen de facturación.

**Técnicas utilizadas:**

* `EXTRACT()`
* `SUM()`
* `GROUP BY`
* `ORDER BY`

La consulta agrupa las facturas pagadas por año y mes.

---

## 5.6. Nivel 5 — Consultas avanzadas

Las últimas consultas incorporan técnicas de SQL analítico como **CTE (`WITH`)**, funciones de ventana y comparaciones contra valores agregados.

### Consulta 34 — Presupuestos por encima del importe medio

**Objetivo:** identificar los presupuestos cuyo importe total es superior al importe medio de todos los presupuestos.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `AVG()`
* Subconsulta.
* Comparación contra un valor agregado.
* `ORDER BY`

Primero se calcula el importe de cada presupuesto y posteriormente se compara cada resultado con la media global.

---

### Consulta 35 — Servicios por encima del importe medio

**Objetivo:** identificar los servicios cuyo importe total generado está por encima del importe medio entre los servicios analizados.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `AVG()`
* `GROUP BY`
* Subconsulta.

La CTE permite obtener primero el importe total generado por cada servicio y utilizar posteriormente esos resultados para calcular la media.

---

### Consulta 36 — Obra de mayor importe dentro de cada estado

**Objetivo:** obtener la obra de mayor importe para cada estado de obra.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `GROUP BY`
* `RANK()`
* `PARTITION BY`
* `ORDER BY`

La función de ventana `RANK()` permite establecer una posición dentro de cada estado.

Se utiliza `RANK()` en lugar de `ROW_NUMBER()` porque, si dos o más obras tienen el mismo importe máximo dentro de un estado, todas deben conservar la primera posición.

---

### Consulta 37 — Empleados por encima de la media de participación

**Objetivo:** identificar los empleados que han participado en un número de obras superior a la media.

**Técnicas utilizadas:**

* `WITH`
* `COUNT(DISTINCT ...)`
* `AVG()`
* Subconsulta.
* `GROUP BY`
* `ORDER BY`

Primero se calcula el número de obras en las que ha participado cada empleado y posteriormente se compara cada resultado con la media.

---

### Consulta 38 — Evolución mensual de la facturación

**Objetivo:** analizar la evolución de la facturación a lo largo del tiempo y comparar cada mes con el anterior.

**Técnicas utilizadas:**

* `WITH`
* `EXTRACT()`
* `SUM()`
* `GROUP BY`
* `LAG()`
* `OVER()`
* `ORDER BY`

La función de ventana `LAG()` permite obtener la facturación del mes anterior para calcular la diferencia entre ambos periodos.

Esto permite analizar no solo cuánto se ha facturado en cada mes, sino también si la facturación ha aumentado o disminuido respecto al periodo anterior.

---

## 5.7. Técnicas SQL utilizadas

El conjunto de consultas permite aplicar diferentes elementos del lenguaje SQL:

| Técnica        | Aplicación                                                |
| -------------- | --------------------------------------------------------- |
| `SELECT`       | Recuperación de información                               |
| `WHERE`        | Filtrado de registros                                     |
| `DISTINCT`     | Eliminación de duplicados en resultados                   |
| `JOIN`         | Combinación de información entre tablas                   |
| `LEFT JOIN`    | Conservación de registros sin correspondencia             |
| `GROUP BY`     | Agrupación de registros                                   |
| `HAVING`       | Filtrado de grupos                                        |
| `COUNT()`      | Conteo de registros                                       |
| `SUM()`        | Cálculo de importes acumulados                            |
| `AVG()`        | Cálculo de medias                                         |
| `MAX()`        | Obtención de valores máximos                              |
| `CASE`         | Evaluación condicional                                    |
| `COALESCE()`   | Gestión de valores `NULL`                                 |
| `ROUND()`      | Redondeo de resultados                                    |
| `EXTRACT()`    | Extracción de componentes de fechas                       |
| `WITH`         | Creación de CTE                                           |
| `RANK()`       | Clasificación mediante funciones de ventana               |
| `LAG()`        | Acceso al registro anterior                               |
| `OVER()`       | Aplicación de funciones de ventana                        |
| `PARTITION BY` | División de los datos en grupos para funciones de ventana |

---

## 5.8. Progresión de dificultad

Las consultas se han diseñado siguiendo una progresión de complejidad:

```text
Consultas básicas
       ↓
Filtros y JOINs
       ↓
Agregaciones y GROUP BY
       ↓
Múltiples tablas y cálculos
       ↓
Subconsultas y CTE
       ↓
Funciones de ventana
       ↓
Análisis temporal y comparativo
```

Esta progresión permite demostrar la evolución desde las operaciones fundamentales de SQL hasta técnicas utilizadas habitualmente en análisis de datos relacionales.

---

## 5.9. Relación con el objetivo del proyecto

Las consultas cumplen dos funciones dentro del proyecto.

Por una parte, permiten **comprobar que el modelo de datos responde correctamente a las necesidades planteadas**, verificando que la información almacenada puede recuperarse y relacionarse de forma coherente.

Por otra, permiten demostrar la aplicación práctica de diferentes conceptos de SQL para transformar los datos almacenados en información útil para la gestión de la empresa.

Entre los análisis realizados se incluyen:

* Gestión y seguimiento de clientes.
* Situación de los presupuestos.
* Análisis económico de presupuestos.
* Seguimiento de obras.
* Participación de empleados.
* Estado de las facturas.
* Facturación total y por cliente.
* Rendimiento económico de los servicios.
* Porcentaje de aceptación y rechazo de presupuestos.
* Evolución temporal de la facturación.
* Comparaciones estadísticas entre presupuestos, servicios y empleados.

El conjunto de consultas constituye, por tanto, la capa de **explotación y análisis de datos** de la base de datos desarrollada.
