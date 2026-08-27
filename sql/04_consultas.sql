-- ============================================================
--  CONSULTAS SQL — SISTEMA DE GESTIÓN DE EMPRESA DE PINTURA
--  Dialecto: PostgreSQL
--
--  Las consultas están organizadas por nivel de dificultad
--  y no por las tablas utilizadas, de forma que cada problema
--  debe resolverse identificando la información y relaciones
--  necesarias.
-- ============================================================


-- ============================================================
--  NIVEL 1 — BÁSICO
-- ============================================================

--   1. ¿Qué clientes están registrados actualmente?
SELECT *
FROM cliente;


--   2. ¿Cuántos clientes hay registrados?
SELECT COUNT(*) AS total_clientes
FROM cliente;


--   3. ¿Qué clientes tienen presupuestos aceptados?
SELECT DISTINCT c.id_cliente, c.nombre, c.apellidos
FROM cliente c
JOIN presupuesto p ON c.id_cliente = p.id_cliente
WHERE UPPER(TRIM(p.estado)) = 'ACEPTADO';


--   4. ¿Qué servicios ofrece actualmente la empresa y cuál es su precio unitario?
SELECT nombre, precio_unitario_actual
FROM servicio;


--   5. ¿Qué tipos de pintura están disponibles y qué suplemento aplica cada uno?
SELECT nombre, precio_extra_actual
FROM pintura;


--   6. ¿Qué presupuestos han sido rechazados y qué cliente los solicitó?
SELECT p.id_presupuesto, c.nombre, c.apellidos
FROM presupuesto p
JOIN cliente c ON p.id_cliente = c.id_cliente
WHERE UPPER(TRIM(p.estado)) = 'RECHAZADO';


--   7. ¿Qué presupuestos están pendientes de respuesta del cliente?
SELECT id_presupuesto
FROM presupuesto
WHERE estado = 'enviado';


--   8. ¿Cuántas facturas hay en cada estado?
SELECT estado, COUNT(*) AS total
FROM factura
GROUP BY estado;


--   9. ¿Qué facturas están pendientes de pago?
SELECT *
FROM factura
WHERE UPPER(TRIM(estado)) = 'ENVIADA';


--  10. ¿Cuál es la facturación total de la empresa?
SELECT SUM(importe_total) AS facturacion_total
FROM factura
WHERE UPPER(TRIM(estado)) = 'PAGADA';


--  11. ¿Qué obras están actualmente en curso?
SELECT *
FROM obra
WHERE UPPER(TRIM(estado)) = 'EN_CURSO';


--  12. ¿Qué empleados están asignados a cada obra?
SELECT e.nombre, e.apellidos, a.id_obra
FROM empleado e
JOIN asignacion_empleado a ON e.id_empleado = a.id_empleado
ORDER BY a.id_obra, e.apellidos;


--  13. ¿Qué obras fueron canceladas?
SELECT *
FROM obra
WHERE UPPER(TRIM(estado)) = 'CANCELADA';


-- ============================================================
--  NIVEL 2 — INTERMEDIO
-- ============================================================

--  14. ¿Qué clientes han solicitado más de un presupuesto?
SELECT c.id_cliente, c.nombre, c.apellidos
FROM presupuesto p
JOIN cliente c ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellidos
HAVING COUNT(*) > 1;


--  15. ¿Cuál es el servicio más caro actualmente?
SELECT nombre, precio_unitario_actual
FROM servicio
WHERE precio_unitario_actual = (SELECT MAX(precio_unitario_actual) FROM servicio);


--  16. ¿Cuántos presupuestos hay en cada estado?
SELECT estado, COUNT(*) AS total
FROM presupuesto
GROUP BY estado;


--  17. ¿Cuál es el importe total de cada presupuesto?
SELECT p.id_presupuesto, COALESCE(SUM(d.importe_detalle), 0) AS total
FROM presupuesto p
LEFT JOIN detalle_presupuesto d ON p.id_presupuesto = d.id_presupuesto
GROUP BY p.id_presupuesto;


--  18. ¿Cuántas obras hay en cada estado?
SELECT estado, COUNT(*) AS total
FROM obra
GROUP BY estado;


--  19. ¿Qué obras han finalizado y cuánto duraron?
SELECT id_obra, fecha_inicio, fecha_fin,
       (fecha_fin - fecha_inicio) AS dias_duracion
FROM obra
WHERE UPPER(TRIM(estado)) = 'FINALIZADA';


--  20. ¿Qué clientes tienen obras en curso?
SELECT DISTINCT c.id_cliente, c.nombre, c.apellidos
FROM cliente c
JOIN presupuesto p ON c.id_cliente = p.id_cliente
JOIN obra o ON p.id_presupuesto = o.id_presupuesto
WHERE UPPER(TRIM(o.estado)) = 'EN_CURSO';


--  21. ¿Qué empleados han participado en más obras?
SELECT e.id_empleado, e.nombre, e.apellidos,
       COUNT(DISTINCT a.id_obra) AS total_obras
FROM empleado e
JOIN asignacion_empleado a ON e.id_empleado = a.id_empleado
GROUP BY e.id_empleado, e.nombre, e.apellidos
ORDER BY total_obras DESC;


--  22. ¿Qué clientes tienen facturas pendientes de pago?
SELECT c.id_cliente, c.nombre, c.apellidos,
       COUNT(*) AS facturas_por_pagar
FROM factura f
JOIN obra o ON f.id_obra = o.id_obra
JOIN presupuesto p ON o.id_presupuesto = p.id_presupuesto
JOIN cliente c ON c.id_cliente = p.id_cliente
WHERE UPPER(TRIM(f.estado)) = 'ENVIADA'
GROUP BY c.id_cliente, c.nombre, c.apellidos;


--  23. ¿Cuál es la factura de mayor importe?
SELECT id_factura, importe_total
FROM factura
WHERE importe_total = (SELECT MAX(importe_total) FROM factura);


--  24. ¿Cuánto tiempo tardan de media los clientes en pagar las facturas?
WITH tiempo_en_pagar AS (
    SELECT (fecha_pago - fecha_envio) AS dias
    FROM factura
    WHERE UPPER(TRIM(estado)) = 'PAGADA'
)
SELECT AVG(dias) AS media_dias
FROM tiempo_en_pagar;


--  25. ¿Qué servicios se utilizan con mayor frecuencia?
SELECT s.nombre, COUNT(*) AS total_usos
FROM servicio s
JOIN detalle_presupuesto d ON s.id_servicio = d.id_servicio
GROUP BY s.id_servicio, s.nombre
ORDER BY total_usos DESC;


-- ============================================================
--  NIVEL 3 — ALTO
-- ============================================================

--  26. ¿Cuál es el presupuesto de mayor importe?
WITH totales AS (
    SELECT id_presupuesto, SUM(importe_detalle) AS total_importe
    FROM detalle_presupuesto
    GROUP BY id_presupuesto
)
SELECT id_presupuesto, total_importe
FROM totales
WHERE total_importe = (SELECT MAX(total_importe) FROM totales);


--  27. ¿Cuál es el importe medio de los presupuestos aceptados?
WITH total_por_presupuesto AS (
    SELECT p.id_presupuesto, SUM(d.importe_detalle) AS total_presupuesto
    FROM presupuesto p
    JOIN detalle_presupuesto d ON p.id_presupuesto = d.id_presupuesto
    WHERE UPPER(TRIM(p.estado)) = 'ACEPTADO'
    GROUP BY p.id_presupuesto
)
SELECT ROUND(AVG(total_presupuesto), 2) AS importe_medio_aceptados
FROM total_por_presupuesto;


--  28. ¿Qué clientes han generado mayor facturación?
SELECT c.id_cliente, c.nombre, c.apellidos,
       SUM(f.importe_total) AS total_facturado
FROM factura f
JOIN obra o ON f.id_obra = o.id_obra
JOIN presupuesto p ON o.id_presupuesto = p.id_presupuesto
JOIN cliente c ON c.id_cliente = p.id_cliente
WHERE UPPER(TRIM(f.estado)) = 'PAGADA'
GROUP BY c.id_cliente, c.nombre, c.apellidos
ORDER BY total_facturado DESC;


--  29. ¿Qué servicios generan mayor importe económico?
SELECT s.nombre, SUM(d.importe_detalle) AS total_generado
FROM servicio s
JOIN detalle_presupuesto d ON s.id_servicio = d.id_servicio
JOIN presupuesto p ON d.id_presupuesto = p.id_presupuesto
WHERE UPPER(TRIM(p.estado)) = 'ACEPTADO'
GROUP BY s.id_servicio, s.nombre
ORDER BY total_generado DESC;


--  30. ¿Qué porcentaje de los presupuestos con decisión tomada termina siendo aceptado?
SELECT ROUND(
    AVG(CASE WHEN UPPER(TRIM(estado)) = 'ACEPTADO' THEN 100.0 ELSE 0.0 END), 2
) AS porcentaje_aceptacion
FROM presupuesto
WHERE UPPER(TRIM(estado)) IN ('ACEPTADO', 'RECHAZADO');


--  31. ¿Qué porcentaje de los presupuestos con decisión tomada termina siendo rechazado?
SELECT ROUND(
    AVG(CASE WHEN UPPER(TRIM(estado)) = 'RECHAZADO' THEN 100.0 ELSE 0.0 END), 2
) AS porcentaje_rechazo
FROM presupuesto
WHERE UPPER(TRIM(estado)) IN ('ACEPTADO', 'RECHAZADO');


--  32. ¿Qué empleados han participado en obras con mayor importe total?
SELECT DISTINCT e.id_empleado, e.nombre, e.apellidos,
       o.id_obra, f.importe_total
FROM empleado e
JOIN asignacion_empleado a ON e.id_empleado = a.id_empleado
JOIN obra o ON o.id_obra = a.id_obra
JOIN factura f ON o.id_obra = f.id_obra
ORDER BY f.importe_total DESC;


--  33. ¿Qué meses han generado mayor facturación?
SELECT EXTRACT(YEAR  FROM fecha_emision) AS anio,
       EXTRACT(MONTH FROM fecha_emision) AS mes,
       SUM(importe_total) AS total_facturado
FROM factura
WHERE UPPER(TRIM(estado)) = 'PAGADA'
GROUP BY EXTRACT(YEAR  FROM fecha_emision),
         EXTRACT(MONTH FROM fecha_emision)
ORDER BY total_facturado DESC;


-- ============================================================
--  NIVEL 4 — AVANZADO
-- ============================================================

--  34. ¿Qué presupuestos tienen un importe superior al importe medio de todos los presupuestos?
WITH presupuesto_con_importe AS (
    SELECT p.id_presupuesto, p.id_cliente, p.estado,
           SUM(d.importe_detalle) AS importe_total
    FROM presupuesto p
    JOIN detalle_presupuesto d ON p.id_presupuesto = d.id_presupuesto
    GROUP BY p.id_presupuesto, p.id_cliente, p.estado
)
SELECT *
FROM presupuesto_con_importe
WHERE importe_total > (SELECT AVG(importe_total) FROM presupuesto_con_importe)
ORDER BY importe_total DESC;


--  35. ¿Qué servicios tienen un importe total generado superior al importe medio por servicio?
WITH importe_por_servicio AS (
    SELECT s.id_servicio, s.nombre,
           SUM(d.importe_detalle) AS total
    FROM servicio s
    JOIN detalle_presupuesto d ON s.id_servicio = d.id_servicio
    JOIN presupuesto p ON d.id_presupuesto = p.id_presupuesto
    WHERE UPPER(TRIM(p.estado)) = 'ACEPTADO'
    GROUP BY s.id_servicio, s.nombre
)
SELECT *
FROM importe_por_servicio
WHERE total > (SELECT AVG(total) FROM importe_por_servicio);


--  36. ¿Cuál es la obra de mayor importe dentro de cada estado?
WITH importe_por_obra AS (
    SELECT o.id_obra, o.estado,
           SUM(d.importe_detalle) AS importe_total
    FROM obra o
    JOIN presupuesto p ON o.id_presupuesto = p.id_presupuesto
    JOIN detalle_presupuesto d ON p.id_presupuesto = d.id_presupuesto
    GROUP BY o.id_obra, o.estado
),
obras_ranking AS (
    SELECT id_obra, estado, importe_total,
           RANK() OVER (PARTITION BY estado ORDER BY importe_total DESC) AS posicion
    FROM importe_por_obra
)
SELECT id_obra, estado, importe_total
FROM obras_ranking
WHERE posicion = 1;


--  37. ¿Qué empleados han participado en un número de obras superior a la media?
WITH obras_por_empleado AS (
    SELECT e.id_empleado, e.nombre, e.apellidos,
           COUNT(DISTINCT a.id_obra) AS total_obras
    FROM empleado e
    JOIN asignacion_empleado a ON e.id_empleado = a.id_empleado
    GROUP BY e.id_empleado, e.nombre, e.apellidos
)
SELECT id_empleado, nombre, apellidos, total_obras
FROM obras_por_empleado
WHERE total_obras > (SELECT AVG(total_obras) FROM obras_por_empleado)
ORDER BY total_obras DESC;


--  38. ¿Cuál es la evolución mensual de la facturación?
WITH facturacion_mensual AS (
    SELECT EXTRACT(YEAR  FROM fecha_emision) AS anio,
           EXTRACT(MONTH FROM fecha_emision) AS mes,
           SUM(importe_total) AS total_mes
    FROM factura
    WHERE UPPER(TRIM(estado)) = 'PAGADA'
    GROUP BY EXTRACT(YEAR  FROM fecha_emision),
             EXTRACT(MONTH FROM fecha_emision)
)
SELECT anio, mes, total_mes,
       LAG(total_mes) OVER (ORDER BY anio, mes) AS mes_anterior,
       total_mes - LAG(total_mes) OVER (ORDER BY anio, mes) AS diferencia
FROM facturacion_mensual
ORDER BY anio, mes;
