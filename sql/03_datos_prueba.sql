-- ============================================================
--  EMPRESA DE PINTURA — Datos de prueba
--  Dialecto: PostgreSQL
--  Orden de inserción respetando dependencias de FK:
--    1. cliente, servicio, pintura, empleado  (independientes)
--    2. presupuesto
--    3. detalle_presupuesto
--    4. obra, factura, asignacion_empleado
-- ============================================================


-- ============================================================
--  1. TABLAS INDEPENDIENTES
-- ============================================================

-- ------------------------------------------------------------
--  CLIENTE — 10 registros
-- ------------------------------------------------------------
INSERT INTO cliente (id_cliente, nombre, apellidos, telefono, email)
OVERRIDING SYSTEM VALUE VALUES
( 1, 'María',       'García López',        '611234501', 'maria.garcia@gmail.com'),
( 2, 'Antonio',     'Martínez Ruiz',       '622345102', 'antonio.martinez@hotmail.com'),
( 3, 'Carmen',      'Fernández Jiménez',   '633456203', 'carmen.fernandez@gmail.com'),
( 4, 'José',        'López Moreno',        '644567304', 'joselopez@outlook.es'),
( 5, 'Isabel',      'Sánchez Torres',      '655678405', 'isanchez@gmail.com'),
( 6, 'Manuel',      'Romero Díaz',         '666789506', 'manuel.romero@yahoo.es'),
( 7, 'Lucía',       'Pérez González',      '677890607', 'lucia.perez@gmail.com'),
( 8, 'Francisco',   'Gómez Herrera',       '688901708', 'fgomez@empresa.es'),
( 9, 'Ana',         'Muñoz Castillo',      '699012809', 'ana.munoz@gmail.com'),
(10, 'David',       'Navarro Serrano',     '600123910', 'dnavarro@gmail.com');

SELECT setval(pg_get_serial_sequence('cliente', 'id_cliente'), 10);


-- ------------------------------------------------------------
--  SERVICIO — 8 registros
-- ------------------------------------------------------------
INSERT INTO servicio (id_servicio, nombre, descripcion, unidad_medida, precio_unitario_actual)
OVERRIDING SYSTEM VALUE VALUES
(1, 'Pintura de paredes interiores',
    'Pintura plástica en paredes interiores, incluye una mano de imprimación',
    'm²',      6.50),
(2, 'Pintura de techo',
    'Pintura plástica en techos, incluye una mano de imprimación',
    'm²',      8.00),
(3, 'Pintura de fachada exterior',
    'Pintura de exteriores sobre enfoscado, con tratamiento previo',
    'm²',     12.00),
(4, 'Barnizado de madera',
    'Barnizado de puertas, ventanas o suelos de madera',
    'm²',     15.00),
(5, 'Imprimación y aparejo',
    'Mano de imprimación o aparejo sobre superficie antes de pintar',
    'm²',      4.00),
(6, 'Pintura de radiadores',
    'Pintura de radiadores con esmalte especial de alta temperatura',
    'm²', 35.00),
(7, 'Estuco veneciano',
    'Acabado decorativo en estuco veneciano pulido',
    'm²',     22.00),
(8, 'Limpieza y preparación de superficie',
    'Lijado, reparación de grietas y limpieza previa al pintado',
    'm²',      3.00);

SELECT setval(pg_get_serial_sequence('servicio', 'id_servicio'), 8);


-- ------------------------------------------------------------
--  PINTURA — 5 registros
--  precio_extra_actual = suplemento por m² sobre el precio del 
-- servicio de pintura
-- ------------------------------------------------------------
INSERT INTO pintura (id_pintura, nombre, descripcion, precio_extra_actual)
OVERRIDING SYSTEM VALUE VALUES
(1, 'Plástica mate blanca',
    'Pintura plástica estándar, acabado mate, color blanco puro',
    0.00),
(2, 'Satinada premium',
    'Pintura plástica con acabado satinado, mayor lavabilidad y durabilidad',
    1.50),
(3, 'Exterior impermeabilizante',
    'Pintura para fachadas con protección frente a lluvia y humedad',
    2.00),
(4, 'Antihumedad',
    'Pintura especial para zonas húmedas: baños, cocinas y sótanos',
    2.50),
(5, 'Esmalte sintético',
    'Esmalte de alta resistencia para superficies metálicas y madera',
    1.80);

SELECT setval(pg_get_serial_sequence('pintura', 'id_pintura'), 5);


-- ------------------------------------------------------------
--  EMPLEADO — 5 registros
-- ------------------------------------------------------------
INSERT INTO empleado (id_empleado, nombre, apellidos, telefono, email)
OVERRIDING SYSTEM VALUE VALUES
(1, 'Pedro',        'Ruiz Molina',     '611555001', 'pedro.ruiz@pinturas-empresa.es'),
(2, 'Juan Carlos',  'Vega Morales',    '622555002', 'jc.vega@pinturas-empresa.es'),
(3, 'Alejandro',    'Torres Campos',   '633555003', 'a.torres@pinturas-empresa.es'),
(4, 'Roberto',      'Jiménez Luna',    '644555004', 'r.jimenez@pinturas-empresa.es'),
(5, 'Miguel Ángel', 'Ortega Reyes',    '655555005', 'ma.ortega@pinturas-empresa.es');

SELECT setval(pg_get_serial_sequence('empleado', 'id_empleado'), 5);


-- ============================================================
--  2. PRESUPUESTO — 20 registros
-- ============================================================
--  Distribución:
--    aceptado  → 13  (generarán obra)
--    rechazado →  3
--    enviado   →  2  (pendientes de respuesta)
--    generado  →  2  (sin enviar aún)
--
--  CHECK cumplidos:
--    fecha_envio >= fecha_creacion  (cuando no es NULL)
--    fecha_respuesta requiere fecha_envio
--    fecha_respuesta >= fecha_envio (cuando no es NULL)
-- ------------------------------------------------------------
INSERT INTO presupuesto
    (id_presupuesto, id_cliente, direccion,
     fecha_creacion, fecha_envio, fecha_respuesta, estado)
OVERRIDING SYSTEM VALUE VALUES

-- Aceptados (1-13) ─────────────────────────────────────────
( 1,  3, 'Calle Recogidas 12, 2º A, Granada',
    '2024-01-08', '2024-01-10', '2024-01-14', 'aceptado'),
( 2,  1, 'Av. de la Constitución 45, 3º B, Granada',
    '2024-01-15', '2024-01-17', '2024-01-20', 'aceptado'),
( 3,  5, 'Calle Arabial 78, 1º C, Granada',
    '2024-02-01', '2024-02-03', '2024-02-07', 'aceptado'),
( 4,  2, 'Calle San Juan de Dios 5, Bajo A, Granada',
    '2024-02-10', '2024-02-12', '2024-02-15', 'aceptado'),
( 5,  7, 'Camino de Ronda 120, 4º D, Granada',
    '2024-02-20', '2024-02-22', '2024-02-25', 'aceptado'),
( 6,  4, 'Urbanización Sierra Nevada, Chalet 7, Ogíjares',
    '2024-03-05', '2024-03-07', '2024-03-10', 'aceptado'),
( 7,  8, 'Calle Párraga 33, 1º A, Granada',
    '2024-03-15', '2024-03-17', '2024-03-20', 'aceptado'),
( 8,  1, 'Av. de la Constitución 45, 3º B, Granada',
    '2024-04-01', '2024-04-03', '2024-04-06', 'aceptado'),
( 9,  6, 'Calle Arabial 22, Ático, Granada',
    '2024-04-15', '2024-04-17', '2024-04-20', 'aceptado'),
(10,  3, 'Calle Molinos 9, 2º B, Granada',
    '2024-05-01', '2024-05-03', '2024-05-06', 'aceptado'),
(11,  9, 'Calle Calderería Nueva 4, 3º A, Granada',
    '2024-06-01', '2024-06-03', '2024-06-06', 'aceptado'),
(12, 10, 'Urbanización El Fargue, Chalet 3, Granada',
    '2024-07-01', '2024-07-03', '2024-07-06', 'aceptado'),
(13,  2, 'Calle Doctor Olóriz 18, 5º C, Granada',
    '2024-08-01', '2024-08-03', '2024-08-06', 'aceptado'),

-- Rechazados (14-16) ───────────────────────────────────────
(14,  5, 'Calle Pedro Antonio de Alarcón 88, Granada',
    '2024-03-10', '2024-03-12', '2024-03-16', 'rechazado'),
(15,  7, 'Camino de Ronda 120, 4º D, Granada',
    '2024-05-05', '2024-05-07', '2024-05-10', 'rechazado'),
(16,  4, 'Calle Real de Armilla 5, Armilla',
    '2024-09-01', '2024-09-03', '2024-09-08', 'rechazado'),

-- Enviados, sin respuesta (17-18) ──────────────────────────
(17,  6, 'Av. de Andalucía 30, 2º A, Granada',
    '2024-10-01', '2024-10-03', NULL, 'enviado'),
(18, 10, 'Urbanización El Fargue, Chalet 5, Granada',
    '2024-11-01', '2024-11-03', NULL, 'enviado'),

-- Generados, sin enviar (19-20) ────────────────────────────
(19,  8, 'Calle Párraga 33, 1º A, Granada',
    '2024-11-20', NULL, NULL, 'generado'),
(20,  9, 'Calle Calderería Nueva 4, 3º A, Granada',
    '2024-12-01', NULL, NULL, 'generado');

SELECT setval(pg_get_serial_sequence('presupuesto', 'id_presupuesto'), 20);


-- ============================================================
--  3. DETALLE_PRESUPUESTO — 62 registros
-- ============================================================
--  Reglas respetadas:
--    · cantidad > 0, capas > 0
--    · si id_pintura IS NULL → suplemento_pintura_aplicado IS NULL
--    · importe_detalle = cantidad × capas x (precio_servicio_aplicado
--                                    + COALESCE(suplemento, 0))
--
--  Casuística incluida:
--    · servicios sin pintura (imprimación, barnizado, limpieza, estuco)
--    · servicios con pintura estándar (suplemento 0.00)
--    · servicios con pintura de calidad (suplemento > 0)
--    · radiadores con esmalte
--    · zonas húmedas con pintura antihumedad
-- ------------------------------------------------------------
INSERT INTO detalle_presupuesto (
    id_detalle, id_presupuesto, id_servicio, id_pintura,
    estancia, cantidad, capas
) OVERRIDING SYSTEM VALUE VALUES

-- ── Presupuesto 1 · cliente 3 · aceptado ──────────────────
-- Pintura salón + barnizado ventanas de madera
( 1,  1, 1, 1, 'Salón',             45.00, 2),
( 2,  1, 2, 1, 'Salón',             20.00, 1),
( 3,  1, 4, NULL, 'Ventanas madera',  8.00, 1),

-- ── Presupuesto 2 · cliente 1 · aceptado ──────────────────
-- Imprimación + pintura de fachada exterior
( 4,  2, 5, NULL, 'Fachada',        120.00, 1),
( 5,  2, 3,    3, 'Fachada',        120.00, 2),

-- ── Presupuesto 3 · cliente 5 · aceptado ──────────────────
-- Dormitorios en blanco + baño con antihumedad
( 6,  3, 1, 4, 'Baño',             18.00, 2),
( 7,  3, 1, 1, 'Dormitorio 1',     30.00, 2),
( 8,  3, 2, 1, 'Dormitorio 1',     15.00, 1),
( 9,  3, 1, 1, 'Dormitorio 2',     28.00, 2),

-- ── Presupuesto 4 · cliente 2 · aceptado ──────────────────
-- Salón satinado, techo, radiadores + limpieza previa
(10,  4, 1, 2, 'Salón',            50.00, 2),
(11,  4, 2, 1, 'Salón',            22.00, 1),
(12,  4, 6, 5, 'Calefacción',       6.00, 1),
(13,  4, 8, NULL, 'Toda la vivienda',72.00, 1),

-- ── Presupuesto 5 · cliente 7 · aceptado ──────────────────
-- Estuco en salón + dormitorio en blanco + limpieza
(14,  5, 7, NULL, 'Salón',          40.00, 1),
(15,  5, 1, 1,   'Dormitorio principal', 35.00, 2),
(16,  5, 8, NULL, 'Toda la vivienda', 75.00, 1),

-- ── Presupuesto 6 · cliente 4 · aceptado (obra en_curso) ──
-- Fachada exterior grande con limpieza + imprimación
(17,  6, 8, NULL, 'Fachada',        200.00, 1),
(18,  6, 5, NULL, 'Fachada',        200.00, 1),
(19,  6, 3,    3, 'Fachada',        200.00, 2),

-- ── Presupuesto 7 · cliente 8 · aceptado (obra en_curso) ──
-- Vivienda completa: 3 dorm + salón satinado + todos los techos
(20,  7, 1, 1, 'Dormitorio 1',     32.00, 2),
(21,  7, 1, 1, 'Dormitorio 2',     30.00, 2),
(22,  7, 1, 1, 'Dormitorio 3',     28.00, 2),
(23,  7, 1, 2, 'Salón',            48.00, 2),
(24,  7, 2, 1, 'Toda la vivienda', 80.00, 1),

-- ── Presupuesto 8 · cliente 1 · aceptado (obra en_curso) ──
-- Solo salón: techo + paredes satinadas
(25,  8, 2, 1, 'Salón',            25.00, 1),
(26,  8, 1, 2, 'Salón',            44.00, 2),

-- ── Presupuesto 9 · cliente 6 · aceptado (obra en_curso) ──
-- Barnizado suelo + dormitorio + limpieza previa
(27,  9, 4, NULL, 'Salón',          35.00, 1),
(28,  9, 1, 1,   'Dormitorio',      26.00, 2),
(29,  9, 8, NULL, 'Toda la vivienda',61.00, 1),

-- ── Presupuesto 10 · cliente 3 · aceptado (sin_iniciar) ───
-- Fachada + entrada satinada
(30, 10, 5, NULL, 'Fachada',        150.00, 1),
(31, 10, 3,    3, 'Fachada',        150.00, 2),
(32, 10, 1,    2, 'Entrada',         20.00, 2),

-- ── Presupuesto 11 · cliente 9 · aceptado (sin_iniciar) ───
-- Dormitorio + baño antihumedad
(33, 11, 1, 1, 'Dormitorio',        30.00, 2),
(34, 11, 1, 4, 'Baño',              18.00, 2),
(35, 11, 2, 1, 'Dormitorio y baño', 20.00, 1),

-- ── Presupuesto 12 · cliente 10 · aceptado (cancelada) ────
-- Chalet: fachada grande + interior completo
(36, 12, 5, NULL, 'Fachada',        300.00, 1),
(37, 12, 3,    3, 'Fachada',        300.00, 2),
(38, 12, 1,    2, 'Salón',           55.00, 2),
(39, 12, 1,    1, 'Dormitorio 1',    32.00, 2),
(40, 12, 1,    1, 'Dormitorio 2',    30.00, 2),
(41, 12, 2,    1, 'Interior completo',90.00, 1),

-- ── Presupuesto 13 · cliente 2 · aceptado (sin_iniciar) ───
-- Dos dormitorios en blanco
(42, 13, 1, 1, 'Dormitorio 1',      28.00, 2),
(43, 13, 1, 1, 'Dormitorio 2',      25.00, 2),
(44, 13, 2, 1, 'Dormitorios',       30.00, 1),

-- ── Presupuesto 14 · cliente 5 · rechazado ────────────────
(45, 14, 5, NULL, 'Fachada',        180.00, 1),
(46, 14, 3,    3, 'Fachada',        180.00, 2),

-- ── Presupuesto 15 · cliente 7 · rechazado ────────────────
(47, 15, 7, NULL, 'Salón',           45.00, 1),
(48, 15, 8, NULL, 'Salón',           45.00, 1),

-- ── Presupuesto 16 · cliente 4 · rechazado ────────────────
(49, 16, 1, 2, 'Interior vivienda',  60.00, 2),
(50, 16, 2, 1, 'Interior vivienda',  30.00, 1),

-- ── Presupuesto 17 · cliente 6 · enviado ──────────────────
(51, 17, 1, 2, 'Salón',              50.00, 2),
(52, 17, 1, 1, 'Dormitorio',         35.00, 2),
(53, 17, 2, 1, 'Toda la vivienda',   40.00, 1),
(54, 17, 6, 5, 'Calefacción',         8.00, 1),

-- ── Presupuesto 18 · cliente 10 · enviado ─────────────────
(55, 18, 5, NULL, 'Fachada',         250.00, 1),
(56, 18, 3,    3, 'Fachada',         250.00, 2),

-- ── Presupuesto 19 · cliente 8 · generado ─────────────────
(57, 19, 1, 1, 'Dormitorio',         28.00, 2),
(58, 19, 2, 1, 'Dormitorio',         14.00, 1),

-- ── Presupuesto 20 · cliente 9 · generado ─────────────────
(59, 20, 1, 2, 'Salón',              44.00, 2),
(60, 20, 1, 4, 'Cocina',             20.00, 2),
(61, 20, 2, 1, 'Salón',              20.00, 1),
(62, 20, 8, NULL, 'Toda la vivienda', 84.00, 1);

SELECT setval(pg_get_serial_sequence('detalle_presupuesto', 'id_detalle'), 62);


-- ============================================================
--  4a. OBRA — 13 registros (solo de presupuestos aceptados)
-- ============================================================
--  Distribución de estados:
--    finalizada  → 5  (obras 1-5)
--    en_curso    → 4  (obras 6-9)
--    sin_iniciar → 3  (obras 10, 11, 13)
--    cancelada   → 1  (obra 12)
--
--  CHECK cumplido: fecha_fin >= fecha_inicio cuando ambas presentes
-- ------------------------------------------------------------
INSERT INTO obra (id_obra, id_presupuesto, fecha_inicio, fecha_fin, estado)
OVERRIDING SYSTEM VALUE VALUES
-- Finalizadas
( 1,  1, '2024-01-20', '2024-02-08',  'finalizada'),
( 2,  2, '2024-01-28', '2024-02-22',  'finalizada'),
( 3,  3, '2024-02-15', '2024-03-12',  'finalizada'),
( 4,  4, '2024-02-25', '2024-03-22',  'finalizada'),
( 5,  5, '2024-03-05', '2024-04-03',  'finalizada'),
-- En curso
( 6,  6, '2024-03-18',  NULL,          'en_curso'),
( 7,  7, '2024-03-28',  NULL,          'en_curso'),
( 8,  8, '2024-04-15',  NULL,          'en_curso'),
( 9,  9, '2024-04-28',  NULL,          'en_curso'),
-- Sin iniciar
(10, 10,  NULL,          NULL,          'sin_iniciar'),
(11, 11,  NULL,          NULL,          'sin_iniciar'),
(13, 13,  NULL,          NULL,          'sin_iniciar'),
-- Cancelada (se inició pero se canceló sin fecha_fin)
(12, 12, '2024-07-15',  NULL,          'cancelada');

SELECT setval(pg_get_serial_sequence('obra', 'id_obra'), 13);


-- ============================================================
--  4b. FACTURA — 5 registros (una por obra finalizada)
-- ============================================================
--  Distribución de estados:
--    pagada   → 3  (obras pagadas)
--    enviada  → 1  (obra finalizada, pendiente de cobro)
--    generada  → 1  (obra finalizada, factura creada)
--
--  importe_total = suma de importe_detalle de los detalles
--                  del presupuesto asociado a la obra
--
--  CHECK cumplidos:
--    fecha_envio >= fecha_emision
--    fecha_pago requiere fecha_envio y fecha_pago >= fecha_envio
-- ------------------------------------------------------------
INSERT INTO factura
    (id_factura, id_obra, fecha_emision, fecha_envio, fecha_pago,
     estado, importe_total)
OVERRIDING SYSTEM VALUE VALUES
--                                        emision       envio         pago
(1,  1, '2024-02-09', '2024-02-12', '2024-02-29', 'pagada',    572.50),
(2,  2, '2024-02-23', '2024-02-26', '2024-03-15', 'pagada',   2160.00),
(3,  3, '2024-03-13', '2024-03-15',  NULL,          'enviada',   659.00),
(4,  4, '2024-03-23', '2024-03-26', '2024-04-10', 'pagada',   1012.80),
(5,  5, '2024-04-04', NULL,  NULL,          'generada',  1332.50);

SELECT setval(pg_get_serial_sequence('factura', 'id_factura'), 5);


-- ============================================================
--  4c. ASIGNACION_EMPLEADO — 27 registros
-- ============================================================
--  Casuística incluida:
--    · obras con 1 empleado (obras pequeñas)
--    · obras con 2 empleados (la mayoría)
--    · obras con 3 empleados (fachadas grandes, viviendas completas)
--    · un mismo empleado trabaja en varias obras a lo largo del año
--    · la obra cancelada (12) tenía empleados asignados
-- ------------------------------------------------------------
INSERT INTO asignacion_empleado (id_asignacion, id_empleado, id_obra, fecha)
OVERRIDING SYSTEM VALUE VALUES
-- Obra 1 — finalizada (2 empleados)
( 1, 1,  1, '2024-01-19'),
( 2, 2,  1, '2024-01-19'),
-- Obra 2 — finalizada (2 empleados)
( 3, 3,  2, '2024-01-27'),
( 4, 4,  2, '2024-01-27'),
-- Obra 3 — finalizada (2 empleados)
( 5, 1,  3, '2024-02-14'),
( 6, 3,  3, '2024-02-14'),
-- Obra 4 — finalizada (2 empleados)
( 7, 2,  4, '2024-02-24'),
( 8, 5,  4, '2024-02-24'),
-- Obra 5 — finalizada (3 empleados · estuco requería más manos)
( 9, 1,  5, '2024-03-04'),
(10, 4,  5, '2024-03-04'),
(11, 5,  5, '2024-03-04'),
-- Obra 6 — en_curso (2 empleados · fachada grande)
(12, 2,  6, '2024-03-17'),
(13, 3,  6, '2024-03-17'),
-- Obra 7 — en_curso (2 empleados · vivienda completa)
(14, 1,  7, '2024-03-27'),
(15, 4,  7, '2024-03-27'),
-- Obra 8 — en_curso (2 empleados)
(16, 3,  8, '2024-04-14'),
(17, 5,  8, '2024-04-14'),
-- Obra 9 — en_curso (3 empleados · barnizado + pintura)
(18, 1,  9, '2024-04-27'),
(19, 2,  9, '2024-04-27'),
(20, 4,  9, '2024-04-27'),
-- Obra 10 — sin_iniciar (1 empleado asignado de antemano)
(21, 3, 10, '2024-05-07'),
-- Obra 11 — sin_iniciar (1 empleado asignado de antemano)
(22, 5, 11, '2024-06-07'),
-- Obra 12 — cancelada (2 empleados que ya habían sido asignados)
(23, 2, 12, '2024-07-14'),
(24, 4, 12, '2024-07-14'),
-- Obra 13 — sin_iniciar (3 empleados planificados)
(25, 1, 13, '2024-08-07'),
(26, 3, 13, '2024-08-07'),
(27, 5, 13, '2024-08-07');

SELECT setval(pg_get_serial_sequence('asignacion_empleado', 'id_asignacion'), 27);


-- ============================================================
--  RESUMEN DEL DATASET
-- ============================================================
--  cliente             :  10 registros
--  servicio            :   8 registros
--  pintura             :   5 registros
--  empleado            :   5 registros
--  presupuesto         :  20 registros (13 acept. / 3 rech. / 2 env. / 2 gen.)
--  detalle_presupuesto :  62 registros
--  obra                :  13 registros (5 final. / 4 curso / 3 sin_ini. / 1 cancel.)
--  factura             :   5 registros (3 pagada / 1 enviada / 1 generada)
--  asignacion_empleado :  27 registros
-- ============================================================
