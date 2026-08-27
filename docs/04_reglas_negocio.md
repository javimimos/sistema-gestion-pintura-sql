# 4. Reglas de negocio

## 4.1. Introducción

La base de datos incorpora una serie de reglas de negocio destinadas a garantizar que las operaciones realizadas sobre el sistema sean coherentes con el funcionamiento definido para la empresa.

Estas reglas controlan principalmente las transiciones de estado de presupuestos, obras y facturas, las relaciones entre las distintas fases del proceso y determinados cálculos y automatizaciones.

Las reglas se implementan mediante restricciones de la base de datos y, cuando requieren lógica más compleja, mediante funciones y triggers de PostgreSQL.

---

## 4.2. Reglas relacionadas con los presupuestos

### 4.2.1. Estados del presupuesto

Un presupuesto puede encontrarse en los siguientes estados:

- `generado`
- `enviado`
- `aceptado`
- `rechazado`

El estado representa la situación actual del presupuesto dentro del proceso comercial.

### 4.2.2. Envío y respuesta del presupuesto

Cuando un presupuesto pasa al estado `enviado`, se registra automáticamente la fecha de envío.

Cuando un presupuesto pasa a `aceptado` o `rechazado`, se registra automáticamente la fecha de respuesta.

Estas fechas son gestionadas mediante el trigger `trg_actualizar_fechas_presupuesto`.

### 4.2.3. Aceptación o rechazo

Un presupuesto generado debe ser enviado antes de poder ser aceptado o rechazado.

Además, un presupuesto aceptado solamente puede pasar a rechazado cuando la obra asociada todavía no ha comenzado.

Si existe una obra en estado `sin_iniciar`, esta se cancela automáticamente cuando el presupuesto pasa de `aceptado` a `rechazado`.

Si la obra ya está en curso o finalizada, el cambio se rechaza para evitar inconsistencias en el ciclo de trabajo.

Estas reglas se controlan mediante el trigger `trg_validar_estado_presupuesto`.

---

## 4.3. Reglas relacionadas con las obras

### 4.3.1. Creación de una obra

Una obra solamente puede crearse cuando existe un presupuesto asociado en estado `aceptado`.

Esta condición se comprueba mediante el trigger `trg_validar_presupuesto_obra`.

### 4.3.2. Estados de la obra

Una obra puede encontrarse en los siguientes estados:

- `sin_iniciar`
- `en_curso`
- `finalizada`
- `cancelada`

Las transiciones entre estos estados están controladas para impedir cambios que no sean coherentes con el flujo definido.

### 4.3.3. Transiciones de estado

Las transiciones permitidas son:

- `sin_iniciar` → `sin_iniciar`, `en_curso` o `cancelada`.
- `en_curso` → `en_curso`, `sin_iniciar`, `finalizada` o `cancelada`.
- `finalizada` → `finalizada`, `en_curso` o `cancelada`.
- `cancelada` → `sin_iniciar`, `en_curso`, `finalizada` o `cancelada`.

Las transiciones no contempladas generan un error y son rechazadas por la base de datos.

Esta lógica se implementa mediante `trg_validar_estado_obra`.

### 4.3.4. Fechas de la obra

Las fechas de inicio y finalización se actualizan automáticamente según el estado de la obra.

- Al pasar a `en_curso`, se establece `fecha_inicio` si todavía no existe y se elimina `fecha_fin`.
- Al pasar a `finalizada`, se establece `fecha_inicio` si todavía no existe y `fecha_fin` si todavía no existe.
- Al pasar a `sin_iniciar`, se eliminan ambas fechas.

Esta lógica se implementa mediante `trg_actualizar_fechas_obra`.

---

## 4.4. Reglas relacionadas con las facturas

### 4.4.1. Creación de una factura

Una factura solamente puede crearse cuando la obra asociada se encuentra en estado `finalizada`.

Esta condición se comprueba mediante `trg_validar_obra_factura`.

### 4.4.2. Estados de la factura

Una factura puede encontrarse en los siguientes estados:

- `generada`
- `enviada`
- `pagada`
- `cancelada`

Las transiciones permitidas son:

- `generada` → `generada`, `enviada` o `cancelada`.
- `enviada` → `enviada`, `pagada` o `cancelada`.
- `pagada` → `pagada` o `cancelada`.
- `cancelada` → cualquier estado.

Estas transiciones son controladas mediante `trg_validar_estado_factura`.

### 4.4.3. Fechas de la factura

Las fechas de envío y pago se gestionan automáticamente según el estado de la factura.

- `generada`: no tiene fecha de envío ni de pago.
- `enviada`: se establece `fecha_envio` si todavía no existe y se elimina `fecha_pago`.
- `pagada`: se establece `fecha_envio` si todavía no existe y `fecha_pago` si todavía no existe.
- `cancelada`: se eliminan las fechas de envío y pago.

Esta lógica se implementa mediante `trg_actualizar_fechas_factura`.

### 4.4.4. Importe de la factura

El importe total de una factura se calcula automáticamente a partir de la suma de los importes de los detalles del presupuesto asociado a la obra.

Esta operación se realiza mediante `trg_calcular_importe_factura`.

---

## 4.5. Reglas relacionadas con los detalles de presupuesto

Cuando se crea un detalle de presupuesto, se obtiene el precio actual del servicio y, cuando corresponde, el suplemento de la pintura seleccionada.

Estos valores se almacenan como precios aplicados al detalle.

De esta forma, los cambios posteriores en los precios actuales de servicios o pinturas no modifican los importes de presupuestos ya elaborados.

El importe del detalle se calcula automáticamente a partir de:

- La cantidad.
- El número de capas.
- El precio del servicio aplicado.
- El suplemento de pintura aplicado, cuando exista.

Esta lógica se implementa mediante `trg_calcular_detalle_presupuesto`.

---

## 4.6. Resumen de las reglas implementadas

Las principales reglas de negocio implementadas en la base de datos son:

| Regla | Mecanismo |
|---|---|
| Un presupuesto debe enviarse antes de aceptarse o rechazarse | Trigger |
| Se registran automáticamente las fechas del presupuesto | Trigger |
| Una obra requiere un presupuesto aceptado | Trigger |
| Se controlan las transiciones de estado de una obra | Trigger |
| Se actualizan automáticamente las fechas de la obra | Trigger |
| Una factura requiere una obra finalizada | Trigger |
| Se controlan las transiciones de estado de una factura | Trigger |
| Se actualizan automáticamente las fechas de la factura | Trigger |
| Se calcula automáticamente el importe del detalle | Trigger |
| Se calcula automáticamente el importe de la factura | Trigger |

---

## 4.7. Correspondencia entre reglas y triggers

| Trigger | Tabla | Función | Finalidad |
|---|---|---|---|
| `trg_calcular_detalle_presupuesto` | `DETALLE_PRESUPUESTO` | `calcular_detalle_presupuesto()` | Calcula precios aplicados e importe |
| `trg_actualizar_fechas_presupuesto` | `PRESUPUESTO` | `actualizar_fechas_presupuesto()` | Gestiona fechas de envío y respuesta |
| `trg_validar_estado_presupuesto` | `PRESUPUESTO` | `validar_estado_presupuesto()` | Controla cambios de estado |
| `trg_actualizar_fechas_obra` | `OBRA` | `actualizar_fechas_obra()` | Gestiona fechas de inicio y finalización |
| `trg_validar_estado_obra` | `OBRA` | `validar_estado_obra()` | Controla transiciones de estado |
| `trg_validar_presupuesto_obra` | `OBRA` | `validar_presupuesto_obra()` | Comprueba que el presupuesto esté aceptado |
| `trg_actualizar_fechas_factura` | `FACTURA` | `actualizar_fechas_factura()` | Gestiona fechas de envío y pago |
| `trg_calcular_importe_factura` | `FACTURA` | `calcular_importe_factura()` | Calcula el importe total |
| `trg_validar_estado_factura` | `FACTURA` | `validar_estado_factura()` | Controla transiciones de estado |
| `trg_validar_obra_factura` | `FACTURA` | `validar_obra_factura()` | Comprueba que la obra esté finalizada |
