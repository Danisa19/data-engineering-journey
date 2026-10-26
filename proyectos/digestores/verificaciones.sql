-- Verificación 1: contar las filas donde medicion es nula. 
select count(*)
from lecturas
where medicion is null;

--Verificación 2: comprobar que cada tipo y zona tiene valores dentro de su rango.
select s.tipo,s.zona, min(l.medicion) as minimo, max(l.medicion) as maximo, count(*)
from lecturas l
inner join sensores s on s.id = l.sensor_id
group by s.tipo, s.zona;

-- Verificacion anomalias digestor linea 1
select s.tipo, min(l.medicion), max(l.medicion), count(*)
from lecturas l
inner join sensores s on s.id = l.sensor_id 
where s.digestor_id = 1 
	and l.fecha_hora >= '2026-10-03 10:00' 
	and l.fecha_hora < '2026-10-04 10:00' 
group by s.tipo;

-- Verificación: detención del DIG-L2 (6 de octubre, 09:00 a 21:00)
select s.tipo, min(l.medicion), max(l.medicion), count(*)
from lecturas l
inner join sensores s on s.id = l.sensor_id
where s.digestor_id = 2
        and l.fecha_hora >= '2026-10-06 09:00'
        and l.fecha_hora < '2026-10-06 21:00'
group by s.tipo;
