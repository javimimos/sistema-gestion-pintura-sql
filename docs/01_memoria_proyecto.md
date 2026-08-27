# 1. Introducción y descripción del proyecto

## 1.1. Contexto del proyecto

Este proyecto consiste en el diseño e implementación de una base de datos relacional para la gestión de una empresa de pintura.

La base de datos se ha desarrollado utilizando PostgreSQL como sistema gestor de bases de datos relacional y tiene como objetivo representar de forma estructurada las principales operaciones relacionadas con la gestión de clientes, presupuestos, obras, empleados, servicios, pinturas y facturas.

El proyecto se plantea como una simulación de un sistema de gestión empresarial, tomando como referencia el funcionamiento habitual de una empresa dedicada a trabajos de pintura y acondicionamiento de superficies.

## 1.2. Problema que se pretende resolver

La gestión de una empresa de pintura implica manejar información relacionada con diferentes procesos: registro de clientes, elaboración y seguimiento de presupuestos, planificación y ejecución de obras, asignación de empleados y generación y seguimiento de facturas.

Si esta información se gestiona de forma no estructurada, pueden aparecer problemas de duplicidad de datos, inconsistencias y dificultades para consultar la información.

El objetivo de la base de datos es centralizar esta información mediante un modelo relacional que permita almacenar los datos de forma organizada y mantener la integridad y consistencia de las relaciones entre las distintas entidades.

## 1.3. Objetivos

Los principales objetivos del proyecto son:

- Diseñar un modelo de datos relacional adaptado a las necesidades de una empresa de pintura.
- Identificar las principales entidades y relaciones presentes en el sistema.
- Aplicar principios de normalización para reducir redundancias e inconsistencias.
- Implementar la base de datos utilizando PostgreSQL.
- Definir claves primarias, claves foráneas, restricciones y reglas de integridad.
- Automatizar determinadas reglas de negocio mediante funciones y triggers.
- Crear consultas SQL de diferente nivel de dificultad para obtener información operativa y realizar análisis sobre los datos.
- Mantener una estructura de archivos SQL organizada que permita reproducir la creación y configuración de la base de datos.
- Utilizar el proyecto como demostración práctica de conocimientos de diseño de bases de datos y SQL.

## 1.4. Alcance del proyecto

El sistema contempla el ciclo principal de gestión de un trabajo de pintura:

1. Registro del cliente.
2. Elaboración del presupuesto.
3. Envío y decisión del presupuesto.
4. Creación de la obra cuando el presupuesto ha sido aceptado.
5. Asignación de empleados a la obra.
6. Ejecución y finalización de la obra.
7. Generación de la factura.
8. Envío y seguimiento del pago de la factura.

Además, la base de datos incorpora reglas que permiten controlar determinadas transiciones de estado y automatizar el cálculo de importes y fechas.

El proyecto se centra en la gestión de la información necesaria para estos procesos y no pretende constituir un sistema empresarial completo con todas las funcionalidades que podría incorporar una aplicación real.

## 1.5. Limitaciones y simplificaciones

Para mantener un alcance adecuado al objetivo académico del proyecto, se han realizado determinadas simplificaciones respecto a un sistema empresarial real.

Entre ellas se encuentran:

- No se implementa un sistema de gestión de inventario de materiales.
- Los presupuestos no disponen de un sistema de versionado histórico.
- No se contempla la gestión de anexos o modificaciones formales de un presupuesto una vez aceptado.
- No se implementa una gestión completa de modificaciones económicas durante la ejecución de una obra.
- Se considera una única factura asociada a cada obra.
- La gestión de clientes se mantiene en una única entidad, sin separar inicialmente entre particulares y empresas.

Estas simplificaciones permiten centrar el proyecto en el diseño relacional, la integridad de los datos, las reglas de negocio y el uso de SQL, manteniendo al mismo tiempo un modelo suficientemente representativo.

Las posibles ampliaciones del sistema se podrán plantear como líneas futuras de desarrollo.
