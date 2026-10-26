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

