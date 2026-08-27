# 3. Implementación de la base de datos

## 3.1. Sistema gestor de bases de datos

La base de datos se ha implementado utilizando PostgreSQL como sistema gestor de bases de datos relacional.

Se ha elegido PostgreSQL por ser un sistema gestor de código abierto, ampliamente utilizado y con soporte para las funcionalidades necesarias para el proyecto, incluyendo restricciones de integridad, consultas SQL avanzadas, funciones y triggers mediante PL/pgSQL.

Durante el desarrollo y las pruebas se ha utilizado pgAdmin 4 como herramienta de administración y consulta de la base de datos.

---

## 3.2. Estructura de la base de datos

La implementación se ha realizado a partir del modelo relacional definido previamente.

Cada entidad del modelo se corresponde con una tabla de la base de datos, mientras que las relaciones entre entidades se implementan principalmente mediante claves foráneas y, en el caso de la relación muchos a muchos entre empleados y obras, mediante la tabla intermedia `ASIGNACION_EMPLEADO`.

Las tablas principales implementadas son:

- `CLIENTE`
- `SERVICIO`
- `PINTURA`
- `EMPLEADO`
- `PRESUPUESTO`
- `DETALLE_PRESUPUESTO`
- `OBRA`
- `ASIGNACION_EMPLEADO`
- `FACTURA`

La estructura completa de las tablas y sus restricciones se encuentra definida en los archivos SQL del proyecto.

---

## 3.3. Tipos de datos

Se han seleccionado los tipos de datos de acuerdo con la naturaleza de la información almacenada.

Para los identificadores se utilizan tipos enteros junto con columnas generadas automáticamente mediante `IDENTITY`.

Los datos de texto utilizan principalmente `VARCHAR`, estableciendo una longitud máxima cuando resulta apropiado, mientras que los campos que pueden contener texto de longitud variable utilizan `TEXT`.

Las cantidades económicas se almacenan mediante `NUMERIC`, evitando el uso de tipos de coma flotante para los importes monetarios.

Las fechas se almacenan mediante el tipo `DATE`, ya que para el alcance del proyecto no es necesario registrar la hora exacta de los acontecimientos.

---

## 3.4. Claves primarias

Cada entidad dispone de una clave primaria que permite identificar de forma única cada registro.

Las claves primarias se utilizan en las relaciones con otras tablas mediante claves foráneas.

Los identificadores de las principales entidades se generan automáticamente, evitando que sea necesario introducir manualmente el valor del identificador al insertar un nuevo registro.

En `ASIGNACION_EMPLEADO`, la identificación de una asignación se basa en la combinación de empleado y obra, evitando registrar dos veces la misma asignación.

---

## 3.5. Claves foráneas e integridad referencial

Las relaciones entre las tablas se implementan mediante claves foráneas.

Estas restricciones garantizan que los registros relacionados existan y evitan referencias hacia registros inexistentes.

Entre las principales relaciones implementadas se encuentran:

- `PRESUPUESTO` → `CLIENTE`
- `DETALLE_PRESUPUESTO` → `PRESUPUESTO`
- `DETALLE_PRESUPUESTO` → `SERVICIO`
- `DETALLE_PRESUPUESTO` → `PINTURA`
- `OBRA` → `PRESUPUESTO`
- `ASIGNACION_EMPLEADO` → `EMPLEADO`
- `ASIGNACION_EMPLEADO` → `OBRA`
- `FACTURA` → `OBRA`

De esta forma, la base de datos mantiene la coherencia entre los diferentes elementos del sistema.

---

## 3.6. Restricciones de integridad

Además de las claves primarias y foráneas, se han utilizado diferentes restricciones para controlar la validez de los datos.

### NOT NULL

Se utiliza `NOT NULL` en aquellos atributos que son necesarios para que un registro tenga sentido dentro del sistema.

Por ejemplo, un cliente debe disponer de nombre, teléfono y correo electrónico, mientras que determinados datos de un detalle de presupuesto son obligatorios para poder calcular su importe.

### UNIQUE

Se utilizan restricciones `UNIQUE` cuando un valor no debe repetirse dentro de una tabla.

En `CLIENTE`, por ejemplo, el teléfono y el correo electrónico se mantienen como valores únicos para evitar duplicar los datos de contacto de un mismo cliente.

También se aplican restricciones de unicidad en aquellos atributos que identifican de forma lógica determinados elementos, como el nombre de los servicios.

### CHECK

Las restricciones `CHECK` se utilizan para impedir valores que no sean válidos desde el punto de vista del modelo.

Entre ellas se incluyen las restricciones relacionadas con cantidades y número de capas de los detalles de presupuesto.

Estas restricciones permiten detectar determinados errores en el momento de insertar o modificar los datos.

---

## 3.7. Valores por defecto

Se han definido valores por defecto para determinados atributos cuyo valor puede establecerse automáticamente.

Entre ellos se encuentran principalmente:

- Fechas de creación o emisión, utilizando la fecha actual cuando corresponde.
- Estados iniciales de presupuestos, obras y facturas.

El uso de valores por defecto permite simplificar la inserción de datos y mantener unos valores iniciales coherentes.

Las reglas que requieren una lógica más compleja no se resuelven mediante valores por defecto, sino mediante funciones y triggers, descritos en la sección correspondiente.

---

## 3.8. Gestión de precios e importes

Uno de los aspectos relevantes de la implementación es la diferencia entre los precios actuales y los precios aplicados a un presupuesto.

Las tablas `SERVICIO` y `PINTURA` mantienen sus precios actuales mediante los atributos correspondientes.

Cuando se crea un detalle de presupuesto, los precios actuales se obtienen y se almacenan en:

- `precio_servicio_aplicado`
- `suplemento_pintura_aplicado`

A partir de estos valores se calcula `importe_detalle`.

De esta forma, un cambio posterior en el precio actual de un servicio o una pintura no modifica el importe de un presupuesto que ya había sido elaborado.

El cálculo de estos valores se automatiza mediante la función `calcular_detalle_presupuesto()` y su trigger asociado.

---

## 3.9. Organización de los archivos SQL

El código SQL del proyecto se ha separado en diferentes archivos según su función.

La estructura permite distinguir entre:

- Definición del esquema de la base de datos.
- Funciones y triggers.
- Datos utilizados para las pruebas.
- Consultas SQL.

Esta separación facilita la comprensión del proyecto y permite ejecutar cada parte de forma independiente durante el desarrollo.

El archivo de consultas contiene problemas organizados por nivel de dificultad, desde consultas básicas hasta consultas que utilizan técnicas más avanzadas como expresiones comunes de tabla (CTE) y funciones de ventana.

---

## 3.10. Herramientas utilizadas durante el desarrollo

Las principales herramientas utilizadas para la implementación y comprobación de la base de datos son:

- **PostgreSQL**: sistema gestor de bases de datos.
- **pgAdmin 4**: administración de la base de datos, ejecución de consultas y comprobación de resultados.
- **Visual Studio Code**: edición y organización de los archivos SQL y de documentación.
- **Git**: control de versiones del proyecto.

---

## 3.11. Reproducibilidad del proyecto

La estructura del proyecto está organizada para que la base de datos pueda reconstruirse a partir de los archivos SQL incluidos en el repositorio.

El proceso general consiste en:

1. Crear una base de datos PostgreSQL.
2. Ejecutar el script de creación del esquema.
3. Ejecutar el script de funciones y triggers.
4. Insertar los datos de prueba.
5. Ejecutar las consultas SQL para comprobar el funcionamiento del sistema.

De esta forma, el proyecto puede ser reproducido en otro entorno PostgreSQL sin depender de la configuración específica utilizada durante el desarrollo.
