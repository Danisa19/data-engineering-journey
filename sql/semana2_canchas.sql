-- Limpiamos tablas 

drop table if exists reservas;
drop table if exists canchas;

-- Crear la tabla madre canchas

create table canchas(
	id serial primary key,
	nombre VARCHAR(50) not null unique,
	precio_hora INT not null check (precio_hora > 0)
);

-- Crear la tabla hija reservas

create table reservas(
	id serial primary key,
	cliente VARCHAR(100) not null,
	horas INT not null check(horas >=1 and horas <= 5),
	cancha_id INT not null references canchas(id)
);

-- Cargar datos canchas

insert into canchas(nombre, precio_hora) values
('Cancha 1 Fraternidad', 25000),
('Cancha 2 techada', 30000),
('Cancha 3 rosario', 20000);

insert into reservas(cliente,horas, cancha_id) values
('Daniel Figueroa', 2, 1),
('Fernanda Pedrero', 1, 2),
('Cosme fulanito',2, 1);

select
	canchas.nombre,
	coalesce(SUM(canchas.precio_hora * reservas.horas),0) as total_a_pagar
from canchas
left join reservas on reservas.cancha_id = canchas.id
group by nombre
order by total_a_pagar desc;
