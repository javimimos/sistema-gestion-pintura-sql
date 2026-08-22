-- ============================================================
--  EMPRESA DE PINTURA — Script de creación de tablas
--  Dialecto: PostgreSQL
-- ============================================================

-- ------------------------------------------------------------
-- CLIENTE
-- ------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente  INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre      VARCHAR(100)    NOT NULL,
    apellidos   VARCHAR(150)    NOT NULL,
    telefono    VARCHAR(20)     NOT NULL,
    email       VARCHAR(150)    NOT NULL,

    CONSTRAINT pk_cliente           PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_telefono  UNIQUE (telefono),
    CONSTRAINT uq_cliente_email     UNIQUE (email)
);


-- ------------------------------------------------------------
-- SERVICIO
-- ------------------------------------------------------------
CREATE TABLE servicio (
    id_servicio            INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre                 VARCHAR(100)   NOT NULL,
    descripcion            TEXT           NULL,
    unidad_medida          VARCHAR(20)    NOT NULL,
    precio_unitario_actual NUMERIC(10,2)  NOT NULL,

    CONSTRAINT pk_servicio        PRIMARY KEY (id_servicio),
    CONSTRAINT uq_servicio_nombre UNIQUE (nombre)
);


-- ------------------------------------------------------------
-- PINTURA
-- ------------------------------------------------------------
CREATE TABLE pintura (
    id_pintura          INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR(100)   NOT NULL,
    descripcion         TEXT           NULL,
    precio_extra_actual NUMERIC(10,2)  NOT NULL,

    CONSTRAINT pk_pintura PRIMARY KEY (id_pintura)
);


-- ------------------------------------------------------------
-- PRESUPUESTO
-- ------------------------------------------------------------
CREATE TABLE presupuesto (
    id_presupuesto  INTEGER GENERATED ALWAYS AS IDENTITY,
    id_cliente      INTEGER        NOT NULL,
    direccion       VARCHAR(255)   NOT NULL,
    fecha_creacion  DATE           NOT NULL DEFAULT CURRENT_DATE,
    fecha_envio     DATE           NULL,
    fecha_respuesta DATE           NULL,
    estado          VARCHAR(30)    NOT NULL DEFAULT 'generado',

    CONSTRAINT pk_presupuesto       PRIMARY KEY (id_presupuesto),
    CONSTRAINT fk_presupuesto_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT chk_presupuesto_fechas
        CHECK (
            (fecha_envio IS NULL OR fecha_envio >= fecha_creacion)
            AND
            (fecha_respuesta IS NULL OR fecha_envio IS NOT NULL)
            AND
            (fecha_respuesta IS NULL OR fecha_respuesta >= fecha_envio)
        ),
    CONSTRAINT chk_presupuesto_estado
        CHECK (estado IN ('generado', 'enviado', 'aceptado', 'rechazado'))
);


-- ------------------------------------------------------------
-- DETALLE_PRESUPUESTO
-- ------------------------------------------------------------
CREATE TABLE detalle_presupuesto (
    id_detalle                  INTEGER GENERATED ALWAYS AS IDENTITY,
    id_presupuesto              INTEGER        NOT NULL,
    id_servicio                 INTEGER        NOT NULL,
    id_pintura                  INTEGER        NULL,
    estancia                    VARCHAR(100)   NOT NULL,
    cantidad                    NUMERIC(10,2)  NOT NULL,
    capas                       INTEGER        NOT NULL DEFAULT 1,
    color                       VARCHAR(50)    NULL,
    precio_servicio_aplicado    NUMERIC(10,2)  NOT NULL,
    suplemento_pintura_aplicado NUMERIC(10,2)  NULL,
    importe_detalle             NUMERIC(10,2)  NOT NULL,

    CONSTRAINT pk_detalle PRIMARY KEY (id_detalle),
    CONSTRAINT chk_detalle_suplemento_pintura
	CHECK (
	    id_pintura IS NOT NULL
	    OR suplemento_pintura_aplicado IS NULL
	);
    CONSTRAINT chk_detalle_cantidad
        CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_capas
        CHECK (capas > 0),
    CONSTRAINT fk_detalle_presupuesto
        FOREIGN KEY (id_presupuesto) REFERENCES presupuesto (id_presupuesto),
    CONSTRAINT fk_detalle_servicio
        FOREIGN KEY (id_servicio)    REFERENCES servicio (id_servicio),
    CONSTRAINT fk_detalle_pintura
        FOREIGN KEY (id_pintura)     REFERENCES pintura (id_pintura)
);


-- ------------------------------------------------------------
-- OBRA
-- ------------------------------------------------------------
CREATE TABLE obra (
    id_obra        INTEGER GENERATED ALWAYS AS IDENTITY,
    id_presupuesto INTEGER      NOT NULL,
    fecha_inicio   DATE         NULL,
    fecha_fin      DATE         NULL,
    estado         VARCHAR(30)  NOT NULL DEFAULT 'sin_iniciar',

    CONSTRAINT pk_obra             PRIMARY KEY (id_obra),
    CONSTRAINT uq_obra_presupuesto UNIQUE (id_presupuesto),
    CONSTRAINT chk_obra_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_inicio IS NULL
            OR fecha_fin >= fecha_inicio
        ),
    CONSTRAINT fk_obra_presupuesto
        FOREIGN KEY (id_presupuesto) REFERENCES presupuesto (id_presupuesto),
    CONSTRAINT chk_obra_estado
        CHECK (estado IN ('sin_iniciar', 'en_curso', 'finalizada', 'cancelada'))
);


-- ------------------------------------------------------------
-- FACTURA
-- ------------------------------------------------------------
CREATE TABLE factura (
    id_factura    INTEGER GENERATED ALWAYS AS IDENTITY,
    id_obra       INTEGER        NOT NULL,
    fecha_emision DATE           NOT NULL DEFAULT CURRENT_DATE,
    fecha_envio   DATE           NULL,
    fecha_pago    DATE           NULL,
    estado        VARCHAR(30)    NOT NULL DEFAULT 'generada',
    importe_total NUMERIC(10,2)  NOT NULL,

    CONSTRAINT pk_factura      PRIMARY KEY (id_factura),
    CONSTRAINT uq_factura_obra UNIQUE (id_obra),
    CONSTRAINT fk_factura_obra
        FOREIGN KEY (id_obra) REFERENCES obra (id_obra),
    CONSTRAINT chk_factura_fechas
        CHECK (
            (fecha_envio IS NULL OR fecha_envio >= fecha_emision)
            AND
            (fecha_pago IS NULL OR fecha_envio IS NOT NULL)
            AND
            (fecha_pago IS NULL OR fecha_pago >= fecha_envio)
        ),
    CONSTRAINT chk_factura_estado
        CHECK (estado IN ('generada', 'enviada', 'pagada', 'cancelada'))
);


-- ------------------------------------------------------------
-- EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE empleado (
    id_empleado INTEGER        GENERATED ALWAYS AS IDENTITY,
    nombre      VARCHAR(100)   NOT NULL,
    apellidos   VARCHAR(150)   NOT NULL,
    telefono    VARCHAR(20)    NOT NULL,
    email       VARCHAR(150)   NOT NULL,

    CONSTRAINT pk_empleado          PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_telefono UNIQUE (telefono),
    CONSTRAINT uq_empleado_email    UNIQUE (email)
);


-- ------------------------------------------------------------
-- ASIGNACION_EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE asignacion_empleado (
    id_asignacion INTEGER  GENERATED ALWAYS AS IDENTITY,
    id_empleado   INTEGER  NOT NULL,
    id_obra       INTEGER  NOT NULL,
    fecha         DATE     NOT NULL,

    CONSTRAINT pk_asignacion PRIMARY KEY (id_asignacion),
    CONSTRAINT fk_asignacion_empleado
        FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
    CONSTRAINT fk_asignacion_obra
        FOREIGN KEY (id_obra)     REFERENCES obra (id_obra)
);


-- ============================================================
--  ÍNDICES
-- ============================================================
CREATE INDEX idx_presupuesto_cliente  ON presupuesto         (id_cliente);
CREATE INDEX idx_detalle_presupuesto  ON detalle_presupuesto (id_presupuesto);
CREATE INDEX idx_detalle_servicio     ON detalle_presupuesto (id_servicio);
CREATE INDEX idx_detalle_pintura      ON detalle_presupuesto (id_pintura);
CREATE INDEX idx_factura_estado       ON factura             (estado);
CREATE INDEX idx_obra_estado          ON obra                (estado);
CREATE INDEX idx_asignacion_obra      ON asignacion_empleado (id_obra);
CREATE INDEX idx_asignacion_empleado  ON asignacion_empleado (id_empleado);
