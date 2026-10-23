DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

-- Tabla de clientes
CREATE TABLE clientes (
    id            SERIAL PRIMARY KEY,
    nombre        VARCHAR(100),
    ciudad        VARCHAR(50),
    fecha_registro DATE
);

-- Tabla de productos
CREATE TABLE productos (
    id        SERIAL PRIMARY KEY,
    nombre    VARCHAR(100),
    categoria VARCHAR(50),
    precio    INTEGER
);

-- Tabla de ventas
CREATE TABLE ventas (
    id          SERIAL PRIMARY KEY,
    cliente_id  INTEGER REFERENCES clientes(id),
    producto_id INTEGER REFERENCES productos(id),
    cantidad    INTEGER,
    fecha       DATE
);

INSERT INTO clientes (nombre, ciudad, fecha_registro) VALUES
('Ana Torres',     'Concepción', '2025-03-10'),
('Benjamín Soto',  'Santiago',   '2025-06-22'),
('Carla Núñez',    'Concepción', '2026-01-15'),
('Diego Fuentes',  'Valparaíso', '2025-11-03'),
('Elena Rivas',    'Santiago',   '2026-02-28'),
('Felipe Araya',   'Temuco',     '2025-08-19');

INSERT INTO productos (nombre, categoria, precio) VALUES
('Teclado mecánico',   'Periféricos',  45000),
('Mouse inalámbrico',  'Periféricos',  18000),
('Monitor 27"',        'Pantallas',    189000),
('Monitor 24"',        'Pantallas',    129000),
('Notebook Pro',       'Computadores', 899000),
('Notebook Básico',    'Computadores', 459000),
('Audífonos',          'Audio',        35000),
('Parlante Bluetooth', 'Audio',        52000),
('Webcam HD',          'Periféricos',  28000),
('Disco SSD 1TB',      'Almacenamiento', 68000);

INSERT INTO ventas (cliente_id, producto_id, cantidad, fecha) VALUES
(1, 3, 1, '2026-03-01'), (1, 2, 2, '2026-03-01'), (2, 5, 1, '2026-03-05'),
(3, 7, 3, '2026-03-07'), (4, 1, 1, '2026-03-09'), (2, 8, 1, '2026-03-12'),
(5, 4, 2, '2026-03-15'), (1, 10, 1, '2026-03-18'), (6, 6, 1, '2026-03-20'),
(3, 2, 1, '2026-03-22'), (4, 9, 2, '2026-03-25'), (2, 3, 1, '2026-03-28');

INSERT INTO clientes (nombre, ciudad, fecha_registro) VALUES
('Gabriela Lillo', 'Rancagua', '2026-04-02');

INSERT INTO productos (nombre, categoria, precio) VALUES
('Tablet', 'Computadores', 220000);

-- 1. Lista el nombre y el precio de todos los productos.
select nombre, precio from productos

-- 2. Muestra solo los productos de la categoría Periféricos.
select * from productos where categoria = 'Periféricos'

--3. Productos que cuesten más de 50.000, ordenados del más caro al más barato.
select * from productos where precio > 50000 order by precio desc;

-- 4. Productos cuyo precio esté entre 30.000 y 100.000.
select * from productos where precio > 30000 and precio < 100000

-- 5. Clientes que sean de Concepción o de Santiago (intenta hacerlo con IN).
select * from clientes where ciudad in ('Concepción', 'Santiago')

-- 6. Productos cuyo nombre contenga la palabra “Monitor” (pista: LIKE).
select * from productos where nombre like 'Monitor%'

-- 7. Las categorías distintas que existen en la tabla de productos, sin repetir.
select distinct categoria from productos

-- 8. Los 3 productos más caros (combina ORDER BY con LIMIT).
select * from productos order by precio desc limit 3

-- 9. Clientes que se registraron durante 2026.
select * from clientes where fecha_registro >= '2026-01-01'

-- 10. Productos de la categoría Audio o que cuesten menos de 20.000.
select * from productos where categoria = 'Audio' or precio < 20000

-- Bloque 2 — Retos para resolver
-- 1. Muestra cada venta junto con el nombre del cliente que la hizo (une ventas con clientes).
select clientes.nombre, clientes.ciudad, ventas.cantidad, ventas.fecha 
from clientes 
inner join ventas on ventas.cliente_id = clientes.id 

-- 2. Muestra cada venta junto con el nombre del producto vendido (une ventas con productos).
select p.nombre, p.precio, v.cantidad, v.fecha 
from ventas v 
inner join productos p on v.producto_id = p.id

-- 3. Muestra el nombre del cliente, el nombre del producto y la cantidad de cada venta (une las tres tablas: encadena dos JOIN).
select c.nombre, c.ciudad, p.nombre, p.precio, v.cantidad, v.fecha
from ventas v
inner join clientes c on v.cliente_id = c.id
inner join productos p on v.producto_id = p.id

-- 4. Lista todos los clientes, hayan comprado o no, mostrando sus ventas. Fíjate que Gabriela aparezca aunque no tenga ventas (pista: ¿qué tipo de JOIN conserva todas las filas de la izquierda?).
select *
from clientes c
left join ventas v on v.cliente_id = c.id

-- 5. Lista todos los productos, incluyendo los que nunca se han vendido (la Tablet debe aparecer).
select *
from productos p
left join ventas v on v.producto_id = p.id

-- 6. Un paso más: muestra el cliente y el producto solo de las ventas hechas por clientes de Santiago (combina un JOIN con un WHERE).
select c.nombre as cliente, c.ciudad, p.nombre as producto, v.fecha
from ventas v
inner join clientes c on v.cliente_id = c.id
inner join productos p on v.producto_id = p.id
where c.ciudad = 'Santiago'

-- Bloque 3 — Retos para resolver
-- 1. ¿Cuántas ventas hay en total? (un solo número, COUNT)
select COUNT(*) from ventas 

-- 2. ¿Cuál es el precio promedio de todos los productos? (AVG)
select AVG(precio) from productos

-- 3. ¿Cuál es el precio del producto más caro y del más barato? (MAX y MIN en la misma consulta)
select MIN(precio) as Mas_barato, MAX(precio) as Mas_caro from productos

-- 4. ¿Cuántos productos hay en cada categoría? (aquí entra GROUP BY categoria + COUNT)
select categoria, COUNT(*) as cantidad_productos from productos group by categoria

-- 5. ¿Cuál es el precio promedio por categoría? (GROUP BY + AVG)
select categoria , AVG(precio) as promedio
from productos
group by categoria

-- 6. ¿Cuántas ventas hizo cada cliente? (une ventas con clientes, agrupa por cliente, cuenta). Ojo: aquí combinas JOIN + GROUP BY, lo del bloque anterior se junta con este.
select clientes.nombre, COUNT(*) as cantidad_ventas
from clientes
inner join ventas on ventas.cliente_id = clientes.id
group by clientes.nombre 

-- 7. ¿Cuántas unidades en total (suma de cantidad) se vendieron de cada producto? (JOIN + GROUP BY + SUM)
select productos.nombre, SUM(ventas.cantidad) as unidades_totales_vendidas
from productos
left join ventas on ventas.producto_id = productos.id
group by productos.nombre

-- 8. Solo las categorías que tengan más de 2 productos (aquí necesitas HAVING).
select productos.categoria, COUNT(*) as cantidad
from productos
group by productos.categoria
having COUNT(productos.categoria) > 2

-- Bloque 4 — Subconsultas y CTEs

-- 1. Productos que cuestan más que el precio promedio (subconsulta de un valor).
select p.nombre, p.precio
from productos p
where p.precio > (select avg(precio) from productos p)

-- 2. Productos que cuestan menos que el más caro (subconsulta con MAX).
select p.nombre, p.precio
from productos p
where p.precio < (select MAX(precio) from productos p)

-- 3. Clientes que han hecho al menos una compra (subconsulta con IN).
select c.nombre
from clientes c 
where c.id IN (select cliente_id from ventas)

-- 4. Clientes que nunca han comprado (NOT IN — Gabriela debería salir).
select c.nombre
from clientes c 
where c.id not IN (select cliente_id from ventas)

-- 5. Con una CTE, calcula unidades vendidas por producto y muestra solo los que vendieron más de 2.
with unidades_productos as (
	select productos.nombre, sum(ventas.cantidad) as unidades_vendidas 
	from productos
	inner join ventas on ventas.producto_id = productos.id 
	group by productos.nombre
)

select * from unidades_productos
where unidades_vendidas > 2

-- Bloque 5 (funciones de ventana)

-- Ejemplo OVER()
SELECT nombre, precio,
       AVG(precio) OVER () AS promedio_general
FROM productos;

-- Ejemplo PARTITION BY()

SELECT nombre, categoria, precio,
       AVG(precio) OVER (PARTITION BY categoria) AS promedio_categoria
FROM productos;

-- Ejemplo funciones de ranking 

SELECT nombre, precio,
       ROW_NUMBER() OVER (ORDER BY precio DESC) AS ranking
FROM productos;

-- 1. Muestra cada producto con su nombre, precio, y una columna extra con el precio promedio de todos los productos al lado (AVG ... OVER ()).

select productos.nombre, productos.precio,
		AVG(productos.precio) OVER() as promedio_general
from productos 

-- 2. Muestra cada producto con su nombre, categoria, precio, y el precio promedio de su categoría al lado (PARTITION BY categoria).
select productos.nombre, productos.categoria, productos.precio,
		AVG(productos.precio) OVER(partition by categoria) as promedio_categoria
from productos



-- 3. Rankea todos los productos del más caro al más barato con ROW_NUMBER(). El más caro debe quedar como 1.
select productos.nombre, productos.precio,
		ROW_NUMBER() OVER(order by precio DESC) AS ranking
from productos

-- 4. Igual que el 3, pero el ranking dentro de cada categoría (el más caro de cada categoría = 1). Pista: combina PARTITION BY categoria con ORDER BY precio DESC dentro del mismo OVER().
select productos.nombre, productos.precio, productos.categoria,
		ROW_NUMBER() OVER(partition by productos.categoria order by precio DESC) AS ranking
from productos

-- Ejemplos LAG, LEAD.

SELECT fecha, cantidad,
       LAG(cantidad) OVER (ORDER BY fecha) AS cantidad_anterior
FROM ventas;

-- Retos cortos

-- 1. Muestra cada venta con su fecha, cantidad, y una columna al lado con la cantidad de la venta anterior (ordenando por fecha). Es casi el ejemplo de arriba — hazlo tú para agarrar la sintaxis.
select ventas.fecha, ventas.cantidad,
		LAG(cantidad) over (order by fecha) as cantidad_anterior
from ventas		

-- 2. Igual que el 1, pero agrega una columna más que calcule la diferencia entre la cantidad actual y la anterior (cantidad - LAG(...)). Las filas donde la anterior es NULL también darán NULL en la diferencia, y está bien.
select ventas.fecha, ventas.cantidad, 
		LAG(cantidad) over (order by fecha) as cantidad_anterior,
		ventas.cantidad - LAG(cantidad) over (order by fecha) as diferencia_actual_anterior
from ventas	


-- 3. (Un pasito más) Usa LEAD en vez de LAG para mostrar, al lado de cada venta, la cantidad de la venta siguiente. Observa qué fila queda con NULL esta vez.
select ventas.fecha, ventas.cantidad,
		LEAD(cantidad) over (order by fecha) as cantidad_siguiente
from ventas
