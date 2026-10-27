drop table if exists mantenimientos;
drop table if exists tecnicos;
drop table if exists lecturas;
drop table if exists sensores;
drop table if exists digestores;

create table digestores (
  id SERIAL primary key,
  tag VARCHAR(100) unique not null,
  tipo VARCHAR(100) check (tipo in ('continuo','batch')),
  ubicacion VARCHAR(100),
  capacidad numeric 
);

create table sensores(
  id SERIAL primary key,
  tag VARCHAR(100) unique not null,
  tipo VARCHAR(100) not null,
  zona VARCHAR(100) not null,
  unidad VARCHAR(100) not null,
  digestor_id integer references digestores(id) not null
);

create table lecturas (
  id SERIAL primary key,
  sensor_id integer references sensores(id) not null,
  medicion numeric not null,
  fecha_hora timestamp not null
);

create table tecnicos (
  id SERIAL primary key,
  nombre VARCHAR(100) not null,
  especialidad VARCHAR(100) not null
);

create table mantenimientos (
  id SERIAL primary key,
  tecnico_id integer references tecnicos(id) not null,
  digestor_id integer references digestores(id) not null,
  tipo VARCHAR(100) not null,
  duracion_horas numeric not null,
  fecha_inicio timestamp not null
);

insert into digestores (tag, tipo, ubicacion, capacidad) values
	('DIG-L1', 'continuo','Línea 1',1500),
	('DIG-L2', 'continuo','Línea 2',2500),
	('DIG-L3', 'batch','Línea 3',3300);

insert into sensores (tag, tipo, zona, unidad, digestor_id) values
	('TT-100', 'temperatura','inferior','°C',1),
	('TT-101', 'temperatura','coccion','°C',1),
	('TT-102', 'temperatura','superior','°C',1),
	('PT-100', 'presion','superior','bar',1),
	('LT-100', 'nivel','superior','%',1),
	('FT-100', 'flujo','linea_licor','m3/h',1),
	('TT-200', 'temperatura','inferior','°C',2),
	('TT-201', 'temperatura','coccion','°C',2),
	('TT-202', 'temperatura','superior','°C',2),
	('PT-200', 'presion','superior','bar',2),
	('LT-200', 'nivel','superior','%',2),
	('FT-200', 'flujo','linea_licor','m3/h',2),
	('TT-300', 'temperatura','inferior','°C',3),
	('TT-301', 'temperatura','superior','°C',3),
	('PT-300', 'presion','superior','bar',3),
	('LT-300', 'nivel','superior','%',3),
	('FT-300', 'flujo','linea_licor','m3/h',3);

insert into tecnicos (nombre, especialidad) values 
	('Daniel Figueroa', 'instrumentista'),
	('Juan Soto', 'electricista'),
	('Elias Gonzalez', 'mecanico'),
	('Fernanda Pedrero', 'instrumentista'),
	('Luis Santibañez', 'electricista');

insert into mantenimientos (tecnico_id, digestor_id, tipo, duracion_horas, fecha_inicio) values 
	(2,3,'preventivo',2,'2026-10-03 08:30:00'),
	(1,2,'preventivo',4,'2026-10-01 08:30:00'),
	(3,3,'preventivo',1,'2026-10-02 12:00:00'),
	(5,1,'correctivo',24,'2026-10-03 10:00:00'),
	(4,2,'correctivo',3,'2026-10-05 16:30:00'),
	(1,3,'preventivo',1,'2026-10-06 08:30:00'),
	(3,1,'preventivo',4,'2026-10-02 08:30:00'),
	(5,3,'preventivo',2,'2026-10-07 08:30:00'),
	(3,2,'correctivo',12,'2026-10-06 09:00:00'),
	(2,1,'preventivo',3,'2026-10-01 13:00:00'),
	(4,2,'preventivo',4,'2026-10-04 08:30:00'),
	(1,3,'preventivo',1,'2026-10-03 11:30:00');

insert into lecturas (sensor_id, medicion, fecha_hora) 
select s.id,
	case 
		when s.tipo ='presion' then round((7 + random() * (12 - 7))::numeric,2)
		when s.tipo ='nivel' then round((40 + random() * (90 - 40))::numeric,2)
		when s.tipo ='flujo' then round((200 + random() * (400 - 200))::numeric,2)
		when s.tipo ='temperatura' and s.zona = 'superior' then round((110 + random() * (130 - 110))::numeric,2)
		when s.tipo ='temperatura' and s.zona = 'coccion' then round((150 + random() * (170 - 150))::numeric,2)
		when s.tipo ='temperatura' and s.zona = 'inferior' then round((80 + random() * (100 - 80))::numeric,2)
	end as medicion, fecha_hora
from sensores s
cross join generate_series(
	'2026-10-01 00:00:00'::timestamp,
	'2026-10-07 23:45:00'::timestamp,
	'15 minutes'::interval
) as fecha_hora;

-- Anomalía: falla de la bomba de circulación del DIG-L2, del 5 de octubre a las 14:00 al 6 de octubre a las 09:00

update lecturas l
set medicion = round((130 + random() * (140 - 130))::numeric,2)
where l.sensor_id = (select id from sensores where sensores.tag = 'TT-201') and (l.fecha_hora >= '2026-10-05 14:00:00' and l.fecha_hora < '2026-10-06 09:00:00');

update lecturas l
set medicion = round((100 + random() * (150 - 100))::numeric,2)
where l.sensor_id = (select id from sensores where sensores.tag = 'FT-200') and (l.fecha_hora >= '2026-10-05 14:00:00' and l.fecha_hora < '2026-10-06 09:00:00');

-- Primera detención: DIG-L1, del 3 de octubre a las 10:00 al 4 de octubre a las 10:00
-- Actualizar variables temperatura con digestor en detencion

update lecturas l
set medicion = round((50 + random() * (80 - 50))::numeric,2)
where l.sensor_id in (select id from sensores where sensores.tipo = 'temperatura' and sensores.digestor_id = 1)
	and l.fecha_hora >= '2026-10-03 10:00' 
	and l.fecha_hora < '2026-10-04 10:00' ;

-- Actualizar variables presion con digestor en detencion
update lecturas l
set medicion = round((0 + random() * (1 - 0))::numeric,2)
where l.sensor_id in (select id from sensores where sensores.tipo = 'presion' and sensores.digestor_id = 1)
	and l.fecha_hora >= '2026-10-03 10:00' 
	and l.fecha_hora < '2026-10-04 10:00' ;

-- Actualizar variables flujo con digestor en detencion
update lecturas l
set medicion = round((0 + random() * (5 - 0))::numeric,2)
where l.sensor_id in (select id from sensores where sensores.tipo = 'flujo' and sensores.digestor_id = 1)
	and l.fecha_hora >= '2026-10-03 10:00' 
	and l.fecha_hora < '2026-10-04 10:00' ;


-- Segunda detencion: Digestor 2 entre 6 de octubre a las 09:00 y 6 de octubre a las 21:00

-- Actualizar variables temperatura con digestor en detencion

update lecturas l
set medicion = round((50 + random() * (80 - 50))::numeric,2)
where l.sensor_id in (select id from sensores where sensores.tipo = 'temperatura' and sensores.digestor_id = 2)
	and l.fecha_hora >= '2026-10-06 09:00' 
	and l.fecha_hora < '2026-10-06 21:00' ;

-- Actualizar variables presion con digestor en detencion
update lecturas l
set medicion = round((0 + random() * (1 - 0))::numeric,2)
where l.sensor_id in (select id from sensores where sensores.tipo = 'presion' and sensores.digestor_id = 2)
	and l.fecha_hora >= '2026-10-06 09:00' 
	and l.fecha_hora < '2026-10-06 21:00' ;

-- Actualizar variables flujo con digestor en detencion
update lecturas l
set medicion = round((0 + random() * (5 - 0))::numeric,2)
where l.sensor_id in (select id from sensores where sensores.tipo = 'flujo' and sensores.digestor_id = 2)
	and l.fecha_hora >= '2026-10-06 09:00' 
	and l.fecha_hora < '2026-10-06 21:00' ;

-- 1. ¿Cuál es la temperatura promedio de cada digestor en cada zona? (el perfil de temperatura)

select d.tag, s.zona, round((avg(l.medicion)), 2) as temperatura_promedio
from sensores s 
inner join lecturas l on l.sensor_id = s.id
inner join digestores d on d.id = s.digestor_id 
where s.tipo = 'temperatura'
group by d.tag, s.zona
order by d.tag, case 
		when s.zona ='superior' then 1
		when s.zona ='coccion' then 2
		when s.zona ='inferior' then 3
	end;

-- 2. ¿Cuántos mantenimientos tuvo cada digestor, por tipo?

select d.tag, 
	count(*) filter (where m.tipo = 'preventivo') as preventivos, count(*) filter (where m.tipo = 'correctivo') as correctivos
from digestores d 
inner join mantenimientos m on m.digestor_id = d.id
group by d.tag
order by d.tag;

-- 3. ¿Cuántas horas de mantenimiento acumuló cada especialidad?

select t.especialidad, SUM(m.duracion_horas) as horas_mantencion, count(*) as cantidad_mantenimientos
from mantenimientos m
inner join tecnicos t on t.id = m.tecnico_id 
group by t.especialidad 
order by horas_mantencion desc;

-- 4. ¿Qué digestor acumuló más horas de mantenimiento correctivo?

select d.tag, sum(m.duracion_horas) as horas_mantenimiento_correctivo
from digestores d 
inner join mantenimientos m on m.digestor_id = d.id
where m.tipo = 'correctivo'
group by d.tag
order by horas_mantenimiento_correctivo desc limit 1;

select count(*) from lecturas;

-- 5. ¿Qué sensores de temperatura de cocción registraron lecturas bajo 150 °C, y cuántas?

select s.tag, count(*) as lecturas_bajo_150
from sensores s
inner join lecturas l on l.sensor_id = s.id
where s.tipo = 'temperatura' and l.medicion < 150 and s.zona = 'coccion'
group by s.tag
having count(*) > 10;
	
-- 6. ¿Cuál fue la temperatura promedio de cocción de cada digestor, día por día?

select d.tag, l.fecha_hora::date as dia, round((AVG(l.medicion)), 2) as temperatura_promedio
from sensores s
inner join digestores d on d.id = s.digestor_id
inner join lecturas l on l.sensor_id = s.id
where s.tipo = 'temperatura' and s.zona = 'coccion'
group by d.tag, l.fecha_hora::date
order by d.tag, dia;

-- 7. ¿Qué digestores tuvieron una temperatura de cocción promedio por debajo del promedio general de la planta?

select d.tag, round(avg(l.medicion), 2) as temp_coccion_promedio
from sensores s
inner join digestores d on d.id = s.digestor_id
inner join lecturas l on l.sensor_id = s.id
where s.tipo = 'temperatura' and s.zona = 'coccion'
group by d.tag
having avg(l.medicion) < (
    select avg(l2.medicion)
	from sensores s2
	inner join lecturas l2 on l2.sensor_id = s2.id
	where s2.tipo = 'temperatura' and s2.zona = 'coccion'
);

-- 8. Qué días el flujo promedio del DIG-L2 estuvo por debajo de su propio promedio semanal?

select *
from senso

