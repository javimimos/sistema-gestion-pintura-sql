# 5. Consultas y análisis SQL

## 5.1. Introducción

Este documento recoge y describe las consultas SQL desarrolladas para analizar la información almacenada en la base de datos de **Pinturillas SA**.

El conjunto está formado por **38 consultas**, diseñadas con diferentes niveles de dificultad. El objetivo no es únicamente comprobar el correcto funcionamiento de la base de datos, sino también demostrar el uso de diferentes recursos del lenguaje SQL para obtener información operativa y realizar análisis sobre los datos.

Las consultas completas se encuentran en:

```text
sql/04_consultas.sql
```

En este documento se explica el objetivo de cada consulta y las principales técnicas SQL utilizadas.

Las consultas se organizan en cuatro niveles de dificultad, siguiendo una progresión desde operaciones básicas hasta consultas que combinan diferentes técnicas de análisis.

---

## 5.2. Nivel 1 — Básico

Las primeras consultas utilizan operaciones fundamentales de SQL, como `SELECT`, `WHERE`, `JOIN`, `DISTINCT` y funciones de agregación básicas.

### Consulta 1 — Clientes registrados

**Objetivo:** obtener el listado de clientes registrados en el sistema.

**Técnicas utilizadas:**

* `SELECT`
* Consulta directa sobre una tabla.

---

### Consulta 2 — Número de clientes

**Objetivo:** conocer cuántos clientes están registrados en el sistema.

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

### Consulta 4 — Servicios ofrecidos

**Objetivo:** consultar los servicios disponibles junto con su unidad de medida y precio unitario actual.

**Técnicas utilizadas:**

* `SELECT`
* Proyección de columnas.
* `ORDER BY`

---

### Consulta 5 — Tipos de pintura

**Objetivo:** consultar los tipos de pintura disponibles y sus suplementos correspondientes.

**Técnicas utilizadas:**

* `SELECT`
* `ORDER BY`

---

### Consulta 6 — Presupuestos rechazados

**Objetivo:** obtener los presupuestos que han sido rechazados junto con la información del cliente que los solicitó.

**Técnicas utilizadas:**

* `JOIN`
* `WHERE`
* `ORDER BY`

---

### Consulta 7 — Presupuestos pendientes de respuesta

**Objetivo:** identificar los presupuestos que han sido enviados y permanecen pendientes de respuesta.

**Técnicas utilizadas:**

* `WHERE`
* Filtrado por estado.
* `ORDER BY`

---

### Consulta 8 — Facturas por estado

**Objetivo:** conocer cuántas facturas existen en cada estado.

**Técnicas utilizadas:**

* `COUNT()`
* `GROUP BY`
* `ORDER BY`

---

### Consulta 9 — Facturas pendientes de pago

**Objetivo:** identificar las facturas que han sido enviadas pero todavía no han sido pagadas.

**Técnicas utilizadas:**

* `JOIN`
* `WHERE`
* Filtrado por estado.
* `ORDER BY`

---

### Consulta 10 — Facturación total

**Objetivo:** calcular el importe total correspondiente a las facturas pagadas.

**Técnicas utilizadas:**

* `SUM()`
* `WHERE`

---

### Consulta 11 — Obras en curso

**Objetivo:** obtener las obras que se encuentran actualmente en estado `en_curso`.

**Técnicas utilizadas:**

* `WHERE`
* Filtrado por estado.

---

### Consulta 12 — Empleados asignados a las obras

**Objetivo:** mostrar los empleados asignados a cada obra.

**Técnicas utilizadas:**

* `JOIN`
* Relación mediante `ASIGNACION_EMPLEADO`
* `ORDER BY`

---

### Consulta 13 — Obras canceladas

**Objetivo:** obtener las obras cuyo estado actual es `cancelada`.

**Técnicas utilizadas:**

* `WHERE`
* Filtrado por estado.
* `ORDER BY`

---

## 5.3. Nivel 2 — Intermedio

En este nivel se incorporan agrupaciones, funciones de agregación y combinaciones de varias tablas para obtener información más elaborada.

### Consulta 14 — Clientes con más de un presupuesto

**Objetivo:** identificar los clientes que han solicitado más de un presupuesto.

**Técnicas utilizadas:**

* `JOIN`
* `GROUP BY`
* `HAVING`
* `COUNT()`

---

### Consulta 15 — Servicio más caro actualmente

**Objetivo:** determinar cuál es el servicio con mayor precio unitario actual.

**Técnicas utilizadas:**

* `MAX()`
* Subconsulta.
* `WHERE`

---

### Consulta 16 — Presupuestos por estado

**Objetivo:** conocer cuántos presupuestos existen en cada estado.

**Técnicas utilizadas:**

* `COUNT()`
* `GROUP BY`
* `ORDER BY`

---

### Consulta 17 — Importe total de cada presupuesto

**Objetivo:** calcular el importe total de cada presupuesto a partir de sus detalles.

**Técnicas utilizadas:**

* `JOIN`
* `LEFT JOIN`
* `SUM()`
* `COALESCE()`
* `GROUP BY`

El uso de `LEFT JOIN` permite mantener también los presupuestos que no tengan detalles asociados.

---

### Consulta 18 — Obras por estado

**Objetivo:** conocer cuántas obras existen en cada estado.

**Técnicas utilizadas:**

* `COUNT()`
* `GROUP BY`
* `ORDER BY`

---

### Consulta 19 — Duración de las obras finalizadas

**Objetivo:** obtener las obras finalizadas y calcular su duración en días.

**Técnicas utilizadas:**

* Operaciones con fechas.
* Resta de fechas.
* `WHERE`
* `ORDER BY`

---

### Consulta 20 — Clientes con obras en curso

**Objetivo:** identificar los clientes que tienen actualmente una obra en ejecución.

**Técnicas utilizadas:**

* Múltiples `JOIN`
* `DISTINCT`
* `WHERE`

---

### Consulta 21 — Empleados que han participado en más obras

**Objetivo:** conocer qué empleados han participado en un mayor número de obras.

**Técnicas utilizadas:**

* `JOIN`
* `COUNT(DISTINCT ...)`
* `GROUP BY`
* `ORDER BY`

El uso de `DISTINCT` permite evitar contar una misma obra más de una vez para un empleado.

---

### Consulta 22 — Clientes con facturas pendientes de pago

**Objetivo:** identificar los clientes que tienen facturas pendientes de pago y conocer el número de facturas pendientes de cada uno.

**Técnicas utilizadas:**

* Múltiples `JOIN`
* `COUNT()`
* `GROUP BY`
* `WHERE`
* `ORDER BY`

---

### Consulta 23 — Factura de mayor importe

**Objetivo:** determinar cuál es la factura con mayor importe total.

**Técnicas utilizadas:**

* `MAX()`
* Subconsulta.

---

### Consulta 24 — Tiempo medio de pago de las facturas

**Objetivo:** calcular cuántos días tardan de media en pagarse las facturas que constan como pagadas.

**Técnicas utilizadas:**

* Operaciones con fechas.
* `WITH`
* `AVG()`
* Filtrado por estado.

El tiempo de pago se obtiene mediante la diferencia entre la fecha de pago y la fecha de envío de cada factura.

---

### Consulta 25 — Servicios utilizados con mayor frecuencia

**Objetivo:** conocer qué servicios aparecen con mayor frecuencia en los detalles de los presupuestos.

**Técnicas utilizadas:**

* `JOIN`
* `COUNT()`
* `GROUP BY`
* `ORDER BY`

---

## 5.4. Nivel 3 — Avanzado

Estas consultas combinan varias tablas y operaciones de agregación para obtener indicadores económicos y de gestión más elaborados.

### Consulta 26 — Presupuesto de mayor importe

**Objetivo:** determinar cuál es el presupuesto con mayor importe total.

**Técnicas utilizadas:**

* `SUM()`
* `GROUP BY`
* `WITH`
* `MAX()`
* Subconsulta.

Primero se calcula el importe total de cada presupuesto y posteriormente se identifica el valor máximo.

---

### Consulta 27 — Importe medio de los presupuestos aceptados

**Objetivo:** calcular el importe medio de los presupuestos cuyo estado es `aceptado`.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `AVG()`
* `GROUP BY`
* `ROUND()`

Primero se obtiene el importe individual de cada presupuesto y posteriormente se calcula la media de los presupuestos aceptados.

---

### Consulta 28 — Clientes con mayor facturación

**Objetivo:** conocer qué clientes han generado un mayor volumen de facturación mediante sus facturas pagadas.

**Técnicas utilizadas:**

* Múltiples `JOIN`
* `SUM()`
* `GROUP BY`
* `ORDER BY`

---

### Consulta 29 — Servicios con mayor importe económico

**Objetivo:** determinar qué servicios generan un mayor importe económico en los presupuestos.

**Técnicas utilizadas:**

* `JOIN`
* `SUM()`
* `GROUP BY`
* `ORDER BY`

---

### Consulta 30 — Porcentaje de presupuestos aceptados

**Objetivo:** calcular qué porcentaje de los presupuestos con decisión tomada termina siendo aceptado.

**Técnicas utilizadas:**

* `CASE`
* `AVG()`
* `ROUND()`
* `WHERE`

La consulta considera únicamente los presupuestos cuyo estado es `aceptado` o `rechazado`, excluyendo aquellos que permanecen pendientes de decisión.

---

### Consulta 31 — Porcentaje de presupuestos rechazados

**Objetivo:** calcular qué porcentaje de los presupuestos con decisión tomada termina siendo rechazado.

**Técnicas utilizadas:**

* `CASE`
* `AVG()`
* `ROUND()`
* `WHERE`

Al igual que en la consulta anterior, únicamente se consideran los presupuestos que ya tienen una decisión tomada.

---

### Consulta 32 — Empleados que han participado en obras de mayor importe

**Objetivo:** mostrar las obras junto con los empleados que participaron en ellas, ordenadas de mayor a menor importe.

**Técnicas utilizadas:**

* Múltiples `JOIN`
* `DISTINCT`
* `ORDER BY`

Esta consulta permite relacionar la participación de los empleados con el importe económico de las obras en las que han intervenido.

---

### Consulta 33 — Meses con mayor facturación

**Objetivo:** conocer qué meses han generado un mayor volumen de facturación.

**Técnicas utilizadas:**

* `EXTRACT()`
* `SUM()`
* `GROUP BY`
* `ORDER BY`

La consulta agrupa las facturas pagadas por año y mes y las ordena según el importe facturado.

---

## 5.5. Nivel 4 — Análisis avanzado

Las últimas consultas incorporan técnicas de SQL analítico como **Common Table Expressions (`WITH`)** y funciones de ventana.

### Consulta 34 — Presupuestos por encima del importe medio

**Objetivo:** identificar los presupuestos cuyo importe total es superior al importe medio de todos los presupuestos.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `AVG()`
* Subconsulta.
* `GROUP BY`
* `ORDER BY`

Primero se calcula el importe total de cada presupuesto y posteriormente se compara cada resultado con la media global.

---

### Consulta 35 — Servicios por encima del importe medio

**Objetivo:** identificar los servicios cuyo importe total generado está por encima del importe medio entre los servicios analizados.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `AVG()`
* `GROUP BY`
* Subconsulta.

La CTE permite calcular primero el importe total generado por cada servicio y posteriormente comparar esos resultados con la media.

---

### Consulta 36 — Obra de mayor importe dentro de cada estado

**Objetivo:** obtener la obra o las obras de mayor importe dentro de cada estado de obra.

**Técnicas utilizadas:**

* `WITH`
* `SUM()`
* `GROUP BY`
* `RANK()`
* `PARTITION BY`
* `ORDER BY`

La función de ventana `RANK()` permite establecer una posición dentro de cada estado.

Se utiliza `RANK()` en lugar de `ROW_NUMBER()` porque, si dos o más obras tienen el mismo importe máximo dentro de un estado, todas conservan la primera posición.

---

### Consulta 37 — Empleados por encima de la media de participación

**Objetivo:** identificar los empleados que han participado en un número de obras superior a la media de participación.

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

La función de ventana `LAG()` permite obtener la facturación del mes anterior para calcular la diferencia respecto al periodo actual.

Esto permite analizar no solo cuánto se ha facturado en cada mes, sino también si la facturación ha aumentado o disminuido respecto al periodo anterior.

---

## 5.6. Técnicas SQL utilizadas

El conjunto de consultas permite aplicar diferentes elementos del lenguaje SQL:

| Técnica        | Aplicación                                                |
| -------------- | --------------------------------------------------------- |
| `SELECT`       | Recuperación de información                               |
| `WHERE`        | Filtrado de registros                                     |
| `DISTINCT`     | Eliminación de duplicados en los resultados               |
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
| `WITH`         | Creación de Common Table Expressions (CTE)                |
| `RANK()`       | Clasificación mediante funciones de ventana               |
| `LAG()`        | Acceso al registro anterior                               |
| `OVER()`       | Aplicación de funciones de ventana                        |
| `PARTITION BY` | División de los datos en grupos para funciones de ventana |

---

## 5.7. Progresión de dificultad

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

Esta progresión permite demostrar la evolución desde las operaciones fundamentales de SQL hasta técnicas utilizadas para realizar análisis sobre información empresarial.

---

## 5.8. Relación con el objetivo del proyecto

Las consultas cumplen dos funciones principales dentro del proyecto.

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
* Comparaciones entre presupuestos, servicios y empleados.

El conjunto de consultas constituye, por tanto, la capa de **explotación y análisis de datos** de la base de datos desarrollada.

