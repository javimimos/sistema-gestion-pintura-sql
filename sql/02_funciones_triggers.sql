-- ============================================================
--  FUNCIONES Y TRIGGERS
--  Dialecto: PostgreSQL
-- ============================================================

-- ============================================================
--  1. DETALLE_PRESUPUESTO
-- ============================================================

-- ------------------------------------------------------------
--  CALCULAR DETALLE DEL PRESUPUESTO
--
--  Obtiene el precio actual del servicio y, si existe,
--  el suplemento de la pintura.
--
--  Los precios obtenidos quedan almacenados como precios
--  aplicados al presupuesto, permitiendo conservar el precio
--  histórico aunque posteriormente cambien los precios actuales.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION calcular_detalle_presupuesto()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    precio_servicio NUMERIC(10,2);
    precio_pintura  NUMERIC(10,2);
BEGIN

    -- Obtener el precio actual del servicio
    SELECT precio_unitario_actual
    INTO precio_servicio
    FROM servicio
    WHERE id_servicio = NEW.id_servicio;

    -- Guardar el precio del servicio aplicado
    NEW.precio_servicio_aplicado := precio_servicio;


    -- Obtener el suplemento de pintura si se ha seleccionado una
    IF NEW.id_pintura IS NOT NULL THEN

        SELECT precio_extra_actual
        INTO precio_pintura
        FROM pintura
        WHERE id_pintura = NEW.id_pintura;

        NEW.suplemento_pintura_aplicado := precio_pintura;

    ELSE

        NEW.suplemento_pintura_aplicado := NULL;

    END IF;


    -- Calcular el importe del detalle
    NEW.importe_detalle :=
        NEW.cantidad * NEW.capas *
        (
            NEW.precio_servicio_aplicado
            + COALESCE(NEW.suplemento_pintura_aplicado, 0)
        );

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_calcular_detalle_presupuesto
ON detalle_presupuesto;

CREATE TRIGGER trg_calcular_detalle_presupuesto
BEFORE INSERT ON detalle_presupuesto
FOR EACH ROW
EXECUTE FUNCTION calcular_detalle_presupuesto();



-- ============================================================
--  2. PRESUPUESTO
-- ============================================================

-- ------------------------------------------------------------
--  ACTUALIZAR FECHAS DEL PRESUPUESTO
--
--  INSERT:
--    · Si se crea como enviado y no tiene fecha_envio,
--      se asigna CURRENT_DATE.
--    · Si se crea como aceptado/rechazado y no tiene
--      fecha_respuesta, se asigna CURRENT_DATE.
--
--  UPDATE:
--    · generado -> enviado     → fecha_envio
--    · enviado  -> aceptado    → fecha_respuesta
--    · enviado  -> rechazado   → fecha_respuesta
--
--  Se utiliza TG_OP para evitar acceder a OLD durante INSERT.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION actualizar_fechas_presupuesto()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    -- ========================================
    -- INSERT
    -- ========================================

    IF TG_OP = 'INSERT' THEN

        IF NEW.estado = 'enviado'
           AND NEW.fecha_envio IS NULL THEN

            NEW.fecha_envio := CURRENT_DATE;

        END IF;


        IF NEW.estado IN ('aceptado', 'rechazado')
           AND NEW.fecha_respuesta IS NULL THEN

            NEW.fecha_respuesta := CURRENT_DATE;

        END IF;


    -- ========================================
    -- UPDATE
    -- ========================================

    ELSIF TG_OP = 'UPDATE' THEN

        -- Cuando se envía el presupuesto
        IF NEW.estado = 'enviado'
           AND OLD.estado <> 'enviado'
           AND NEW.fecha_envio IS NULL THEN

            NEW.fecha_envio := CURRENT_DATE;

        END IF;


        -- Cuando el cliente acepta o rechaza
        IF NEW.estado IN ('aceptado', 'rechazado')
           AND OLD.estado NOT IN ('aceptado', 'rechazado')
           AND NEW.fecha_respuesta IS NULL THEN

            NEW.fecha_respuesta := CURRENT_DATE;

        END IF;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_actualizar_fechas_presupuesto
ON presupuesto;

CREATE TRIGGER trg_actualizar_fechas_presupuesto
BEFORE INSERT OR UPDATE ON presupuesto
FOR EACH ROW
EXECUTE FUNCTION actualizar_fechas_presupuesto();



-- ------------------------------------------------------------
--  VALIDAR ESTADO DEL PRESUPUESTO
--
--  Un presupuesto generado debe enviarse antes de poder
--  ser aceptado o rechazado.
--
--  Si un presupuesto aceptado pasa a rechazado:
--    · Si no existe obra → permitido.
--    · Si la obra está sin iniciar → se cancela.
--    · Si la obra ya comenzó o está finalizada → no permitido.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION validar_estado_presupuesto()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    estado_obra VARCHAR(30);
BEGIN

    -- Un presupuesto generado debe enviarse antes
    -- de poder ser aceptado o rechazado.
    IF OLD.estado = 'generado'
       AND NEW.estado IN ('aceptado', 'rechazado') THEN

        RAISE EXCEPTION
            'Un presupuesto generado debe enviarse antes de ser aceptado o rechazado.';

    END IF;


    -- Caso especial: aceptado -> rechazado
    IF OLD.estado = 'aceptado'
       AND NEW.estado = 'rechazado' THEN

        SELECT estado
        INTO estado_obra
        FROM obra
        WHERE id_presupuesto = NEW.id_presupuesto;


        -- Si la obra ya ha comenzado o está finalizada,
        -- no se puede rechazar el presupuesto.
        IF estado_obra IS NOT NULL
           AND estado_obra NOT IN ('sin_iniciar', 'cancelada') THEN

            RAISE EXCEPTION
                'No se puede rechazar el presupuesto % porque la obra ya ha comenzado.',
                NEW.id_presupuesto;

        END IF;


        -- Si la obra todavía no ha comenzado,
        -- se conserva pero se marca como cancelada.
        IF estado_obra = 'sin_iniciar' THEN

            UPDATE obra
            SET estado = 'cancelada'
            WHERE id_presupuesto = NEW.id_presupuesto;

        END IF;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_validar_estado_presupuesto
ON presupuesto;

CREATE TRIGGER trg_validar_estado_presupuesto
BEFORE UPDATE ON presupuesto
FOR EACH ROW
EXECUTE FUNCTION validar_estado_presupuesto();



-- ============================================================
--  3. OBRA
-- ============================================================

-- ------------------------------------------------------------
--  ACTUALIZAR FECHAS DE LA OBRA
--
--  EN_CURSO:
--    · fecha_inicio se establece si todavía es NULL.
--    · fecha_fin se elimina.
--
--  FINALIZADA:
--    · fecha_inicio se establece si todavía es NULL.
--    · fecha_fin se establece si todavía es NULL.
--
--  SIN_INICIAR:
--    · se eliminan ambas fechas.
--
--  Una obra cancelada conserva sus fechas existentes.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION actualizar_fechas_obra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.estado = 'en_curso' THEN

        IF NEW.fecha_inicio IS NULL THEN
            NEW.fecha_inicio := CURRENT_DATE;
        END IF;

        NEW.fecha_fin := NULL;


    ELSIF NEW.estado = 'finalizada' THEN

        IF NEW.fecha_inicio IS NULL THEN
            NEW.fecha_inicio := CURRENT_DATE;
        END IF;

        IF NEW.fecha_fin IS NULL THEN
            NEW.fecha_fin := CURRENT_DATE;
        END IF;


    ELSIF NEW.estado = 'sin_iniciar' THEN

        NEW.fecha_inicio := NULL;
        NEW.fecha_fin := NULL;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_actualizar_fechas_obra
ON obra;

CREATE TRIGGER trg_actualizar_fechas_obra
BEFORE INSERT OR UPDATE ON obra
FOR EACH ROW
EXECUTE FUNCTION actualizar_fechas_obra();



-- ------------------------------------------------------------
--  VALIDAR ESTADO DE LA OBRA
--
--  Define las transiciones de estado permitidas.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION validar_estado_obra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF OLD.estado = 'sin_iniciar'
       AND NEW.estado NOT IN
           ('sin_iniciar', 'en_curso', 'cancelada') THEN

        RAISE EXCEPTION
            'Transición de estado no permitida: % -> %',
            OLD.estado, NEW.estado;


    ELSIF OLD.estado = 'en_curso'
          AND NEW.estado NOT IN
              ('en_curso', 'sin_iniciar', 'finalizada', 'cancelada') THEN

        RAISE EXCEPTION
            'Transición de estado no permitida: % -> %',
            OLD.estado, NEW.estado;


    ELSIF OLD.estado = 'finalizada'
          AND NEW.estado NOT IN
              ('finalizada', 'en_curso', 'cancelada') THEN

        RAISE EXCEPTION
            'Transición de estado no permitida: % -> %',
            OLD.estado, NEW.estado;


    ELSIF OLD.estado = 'cancelada'
          AND NEW.estado NOT IN
              ('sin_iniciar', 'en_curso', 'finalizada', 'cancelada') THEN

        RAISE EXCEPTION
            'Transición de estado no permitida: % -> %',
            OLD.estado, NEW.estado;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_validar_estado_obra
ON obra;

CREATE TRIGGER trg_validar_estado_obra
BEFORE UPDATE ON obra
FOR EACH ROW
EXECUTE FUNCTION validar_estado_obra();



-- ------------------------------------------------------------
--  GESTIONAR FACTURA AL REABRIR UNA OBRA
--
--  Si una obra finalizada vuelve a estar en curso:
--
--    · Si no existe factura → se permite.
--    · Si la factura está generada o cancelada → se elimina.
--    · Si la factura está enviada o pagada → no se permite
--      reabrir la obra.
--
--  Esto evita que una obra vuelva a estar en curso mientras
--  existe una factura que ya ha sido enviada o cobrada.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION gestionar_factura_reapertura_obra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    estado_factura VARCHAR(30);
BEGIN

    -- Solo actuamos cuando una obra finalizada
    -- vuelve a estar en curso.
    IF OLD.estado = 'finalizada'
       AND NEW.estado = 'en_curso' THEN

        -- Comprobar si existe una factura para la obra.
        SELECT estado
        INTO estado_factura
        FROM factura
        WHERE id_obra = NEW.id_obra;


        -- Si existe una factura enviada o pagada,
        -- no se puede reabrir la obra.
        IF estado_factura IN ('enviada', 'pagada') THEN

            RAISE EXCEPTION
                'No se puede reabrir la obra % porque su factura está %.',
                NEW.id_obra,
                estado_factura;

        END IF;


        -- Si la factura está generada o cancelada,
        -- se elimina porque la obra ya no está finalizada.
        IF estado_factura IN ('generada', 'cancelada') THEN

            DELETE FROM factura
            WHERE id_obra = NEW.id_obra;

        END IF;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_gestionar_factura_reapertura_obra
ON obra;

CREATE TRIGGER trg_gestionar_factura_reapertura_obra
AFTER UPDATE OF estado ON obra
FOR EACH ROW
EXECUTE FUNCTION gestionar_factura_reapertura_obra();



-- ------------------------------------------------------------
--  VALIDAR PRESUPUESTO DE LA OBRA
--
--  Una obra solamente puede crearse si su presupuesto
--  está aceptado.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION validar_presupuesto_obra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    estado_presupuesto VARCHAR(30);
BEGIN

    SELECT estado
    INTO estado_presupuesto
    FROM presupuesto
    WHERE id_presupuesto = NEW.id_presupuesto;


    IF estado_presupuesto <> 'aceptado' THEN

        RAISE EXCEPTION
            'No se puede crear la obra: el presupuesto % no está aceptado.',
            NEW.id_presupuesto;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_validar_presupuesto_obra
ON obra;

CREATE TRIGGER trg_validar_presupuesto_obra
BEFORE INSERT ON obra
FOR EACH ROW
EXECUTE FUNCTION validar_presupuesto_obra();



-- ============================================================
--  4. FACTURA
-- ============================================================

-- ------------------------------------------------------------
--  ACTUALIZAR FECHAS DE LA FACTURA
--
--  GENERADA:
--    · No tiene fecha de envío ni de pago.
--
--  ENVIADA:
--    · Si no existe fecha de envío, se establece CURRENT_DATE.
--    · No tiene fecha de pago.
--
--  PAGADA:
--    · Si no existe fecha de envío, se establece CURRENT_DATE.
--    · Si no existe fecha de pago, se establece CURRENT_DATE.
--
--  CANCELADA:
--    · Se eliminan las fechas de envío y pago.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION actualizar_fechas_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.estado = 'generada' THEN

        NEW.fecha_envio := NULL;
        NEW.fecha_pago := NULL;


    ELSIF NEW.estado = 'enviada' THEN

        IF NEW.fecha_envio IS NULL THEN
            NEW.fecha_envio := CURRENT_DATE;
        END IF;

        NEW.fecha_pago := NULL;


    ELSIF NEW.estado = 'pagada' THEN

        IF NEW.fecha_envio IS NULL THEN
            NEW.fecha_envio := CURRENT_DATE;
        END IF;

        IF NEW.fecha_pago IS NULL THEN
            NEW.fecha_pago := CURRENT_DATE;
        END IF;


    ELSIF NEW.estado = 'cancelada' THEN

        NEW.fecha_envio := NULL;
        NEW.fecha_pago := NULL;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_actualizar_fechas_factura
ON factura;

CREATE TRIGGER trg_actualizar_fechas_factura
BEFORE INSERT OR UPDATE ON factura
FOR EACH ROW
EXECUTE FUNCTION actualizar_fechas_factura();



-- ------------------------------------------------------------
--  CALCULAR IMPORTE DE LA FACTURA
--
--  El importe total de una factura corresponde a la suma
--  de los importes de todos los detalles del presupuesto
--  asociado a la obra.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION calcular_importe_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total NUMERIC(10,2);
BEGIN

    SELECT COALESCE(SUM(d.importe_detalle), 0)
    INTO total
    FROM obra
    JOIN detalle_presupuesto d
        ON obra.id_presupuesto = d.id_presupuesto
    WHERE obra.id_obra = NEW.id_obra;


    NEW.importe_total := total;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_calcular_importe_factura
ON factura;

CREATE TRIGGER trg_calcular_importe_factura
BEFORE INSERT ON factura
FOR EACH ROW
EXECUTE FUNCTION calcular_importe_factura();



-- ------------------------------------------------------------
--  VALIDAR ESTADO DE LA FACTURA
--
--  GENERADA  → ENVIADA / CANCELADA
--  ENVIADA   → PAGADA / CANCELADA
--  PAGADA    → CANCELADA
--  CANCELADA → cualquier estado
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION validar_estado_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    -- GENERADA solo puede pasar a ENVIADA o CANCELADA
    IF OLD.estado = 'generada'
       AND NEW.estado NOT IN
           ('generada', 'enviada', 'cancelada') THEN

        RAISE EXCEPTION
            'Transición de estado no permitida: % -> %',
            OLD.estado, NEW.estado;

    END IF;


    -- ENVIADA solo puede pasar a PAGADA o CANCELADA
    IF OLD.estado = 'enviada'
       AND NEW.estado NOT IN
           ('enviada', 'pagada', 'cancelada') THEN

        RAISE EXCEPTION
            'Transición de estado no permitida: % -> %',
            OLD.estado, NEW.estado;

    END IF;


    -- PAGADA solo puede permanecer PAGADA
    -- o pasar a CANCELADA
    IF OLD.estado = 'pagada'
       AND NEW.estado NOT IN
           ('pagada', 'cancelada') THEN

        RAISE EXCEPTION
            'Transición de estado no permitida: % -> %',
            OLD.estado, NEW.estado;

    END IF;


    -- CANCELADA puede volver a cualquier estado.

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_validar_estado_factura
ON factura;

CREATE TRIGGER trg_validar_estado_factura
BEFORE UPDATE ON factura
FOR EACH ROW
EXECUTE FUNCTION validar_estado_factura();



-- ------------------------------------------------------------
--  VALIDAR OBRA DE LA FACTURA
--
--  Una factura solamente puede crearse cuando la obra
--  asociada está finalizada.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION validar_obra_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    estado_obra VARCHAR(30);
BEGIN

    SELECT estado
    INTO estado_obra
    FROM obra
    WHERE id_obra = NEW.id_obra;


    IF estado_obra <> 'finalizada' THEN

        RAISE EXCEPTION
            'No se puede crear la factura: la obra % no está finalizada.',
            NEW.id_obra;

    END IF;

    RETURN NEW;

END;
$$;


DROP TRIGGER IF EXISTS trg_validar_obra_factura
ON factura;

CREATE TRIGGER trg_validar_obra_factura
BEFORE INSERT ON factura
FOR EACH ROW
EXECUTE FUNCTION validar_obra_factura();

