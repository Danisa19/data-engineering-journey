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

