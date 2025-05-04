EJERCICIOS BASE DE DATOS

EJERCICIO 1

- Crear una base de datos con el nombre tarea_ucm

CREATE DATABASE TAREA_UCM;

- Crear un esquema de base de datos con el nombre operaciones_ucm

CREATE SCHEMA TAREA_UCM.OPERACIONES_UCM;

- Crear las tres tablas correspondientes a los 3 archivos: orders, refunds y merchants.

(Orders)

CREATE TABLE "TAREA_UCM"."OPERACIONES_UCM"."ORDERS"
(order_id varchar(50),
created_at TIMESTAMP,
status varchar(50),
amount float,
refunded_at TIMESTAMP,
merchant_at varchar(50),
country varchar(50)
);

(Refunds)

CREATE TABLE "TAREA_UCM"."OPERACIONES_UCM"."REFUNDS"
(order_id varchar(50),
refunded_at TIMESTAMP,
amount float)
;

(Merchants)

CREATE TABLE "TAREA_UCM"."OPERACIONES_UCM"."MERCHANTS"
(merchant_id varchar(50),
name varchar(50));

EJERCICIO 2

1) Realizamos una consulta donde obtengamos por país y estado de operación, el total de
operaciones y su importe promedio. La consulta debe cumplir las siguientes condiciones:
a. Operaciones posteriores al 01-07-2015.
b. Operaciones realizadas en Francia, Portugal y España.
c. Operaciones con un valor mayor de 100 € y menor de 1500€.

Ordenamos los resultados por el promedio del importe de manera descendente.

SELECT  COUNTRY, STATUS, 
ROUND (AVG(AMOUNT)) AS IMPORTE_PROMEDIO,
COUNT(ORDER_ID) AS OPERACIONES
FROM "TAREA_UCM"."OPERACIONES_UCM"."ORDERS"
WHERE COUNTRY IN ('Francia','Italia','España')
AND (AMOUNT >=100 <=1500)
AND CREATED_AT >  '2015-07-17 00:00:00.000'
GROUP BY COUNTRY,STATUS
ORDER BY IMPORTE_PROMEDIO DESC
;


2) Realizamos una consulta donde obtengamos los 3 países con el mayor número de
operaciones, el total de operaciones, la operación con un valor máximo y la operación con
el valor mínimo para cada país. La consulta debe cumplir las siguientes condiciones:
a. Excluimos aquellas operaciones con el estado “Delinquent” y “Cancelled”.
b. Operaciones con un valor mayor de 100 €.

SELECT TOP 3 country,  
COUNT(ORDER_ID) AS OPERACIONES,MAX(AMOUNT) AS CANTIDAD_MAX, MIN(AMOUNT) AS CANTIDAD_MIN
FROM "TAREA_UCM"."OPERACIONES_UCM"."ORDERS"
WHERE STATUS NOT IN ('Delinquent','Cancelled')
AND AMOUNT >  '100'
GROUP BY 1
ORDER BY OPERACIONES DESC
;

EJERCICIO 3

1) Realizamos una consulta donde obtengamos, por país y comercio, el total de operaciones,
su valor promedio y el total de devoluciones. La consulta debe cumplir las siguientes
condiciones:
a. Se debe mostrar el nombre y el id del comercio.
b. Comercios con más de 10 ventas.
c. Comercios de Marruecos, Italia, España y Portugal.
d. Creamos un campo que identifique si el comercio acepta o no devoluciones. Si no
acepta (total de devoluciones es igual a cero) el campo debe contener el valor
“No” y si sí lo acepta (total de devoluciones es mayor que cero) el campo debe
contener el valor “Sí”. Llamaremos al campo “acepta_devoluciones”.
Ordenamos los resultados por el total de operaciones de manera ascendente.

SELECT 
O.COUNTRY AS PAIS,
M.NAME AS COMERCIO,
M.MERCHANT_ID,
COUNT(O.ORDER_ID) AS TOTAL_DE_OPERACIONES,
AVG (O.AMOUNT) AS VALOR_PROMEDIO,
COUNT (R.ORDER_ID) AS TOTAL_DEVOLUCIONES,
CASE 
WHEN TOTAL_DEVOLUCIONES = 0 THEN 'NO'
     ELSE 'SI'
     END AS ACEPTA_DEVOLUCIONES
FROM "TAREA_UCM"."OPERACIONES_UCM"."ORDERS" AS O
INNER JOIN "TAREA_UCM"."OPERACIONES_UCM"."MERCHANTS" AS M
    ON O.MERCHANT_AT = M.MERCHANT_ID
LEFT JOIN "TAREA_UCM"."OPERACIONES_UCM"."REFUNDS" AS R 
    ON O.ORDER_ID = R.ORDER_ID
WHERE (O.COUNTRY IN ('España','Portugal','Marruecos','Italia'))
GROUP BY O.COUNTRY,M.NAME ,M.MERCHANT_ID
HAVING TOTAL_DE_OPERACIONES >=10
ORDER BY TOTAL_DE_OPERACIONES ASC
;

2) Realizamos una consulta donde vamos a traer todos los campos de las tablas operaciones y
comercios. De la tabla devoluciones vamos a traer el conteo de devoluciones por operación
y la suma del valor de las devoluciones.
Una vez tengamos la consulta anterior, creamos una vista con el nombre orders_view
dentro del esquema tarea_ucm con esta consulta.
Nota: La tabla refunds contiene más de una devolución por operación por lo que para hacer
el cruce es muy importante que agrupemos las devoluciones.

(Primera parte)
SELECT DISTINCT 
O.ORDER_ID, O.CREATED_AT, O.STATUS, O.AMOUNT, O.REFUNDED_AT, 
M.MERCHANT_ID, O.COUNTRY, R.NUMERO_DEVOLUCIONES, R.SUMA_DEVOLUCIONES, M.NAME
FROM (
SELECT ORDER_ID,
COUNT (ORDER_ID) AS NUMERO_DEVOLUCIONES, 
SUM (AMOUNT) AS SUMA_DEVOLUCIONES
FROM "TAREA_UCM"."OPERACIONES_UCM"."REFUNDS" AS R
GROUP BY 1) AS R
FULL  JOIN "TAREA_UCM"."OPERACIONES_UCM"."ORDERS" O 
    ON R.ORDER_ID = O.ORDER_ID
FULL  JOIN "TAREA_UCM"."OPERACIONES_UCM"."MERCHANTS" M 
    ON M.MERCHANT_ID = O.MERCHANT_AT
;

(Segunda parte)
CREATE VIEW "TAREA_UCM"."OPERACIONES_UCM"."ORDERS_VIEW"
AS 
SELECT DISTINCT 
O.ORDER_ID, O.CREATED_AT, O.STATUS, O.AMOUNT, O.REFUNDED_AT, 
M.MERCHANT_ID, O.COUNTRY, R.NUMERO_DEVOLUCIONES, R.SUMA_DEVOLUCIONES, M.NAME
FROM (
SELECT ORDER_ID,
COUNT (ORDER_ID) AS NUMERO_DEVOLUCIONES, 
SUM (AMOUNT) AS SUMA_DEVOLUCIONES
FROM "TAREA_UCM"."OPERACIONES_UCM"."REFUNDS" AS R
GROUP BY 1) AS R
FULL  JOIN "TAREA_UCM"."OPERACIONES_UCM"."ORDERS" O 
    ON R.ORDER_ID = O.ORDER_ID
FULL  JOIN "TAREA_UCM"."OPERACIONES_UCM"."MERCHANTS" M 
    ON M.MERCHANT_ID = O.MERCHANT_AT





