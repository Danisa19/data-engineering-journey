-- Verificación 1: contar las filas donde medicion es nula. 
select count(*)
from lecturas
where medicion is null;

--Verificación 2: comprobar que cada tipo y zona tiene valores dentro de su rango.
select s.tipo,s.zona, min(l.medicion) as minimo, max(l.medicion) as maximo, count(*)
from lecturas l
inner join sensores s on s.id = l.sensor_id
group by s.tipo, s.zona;

