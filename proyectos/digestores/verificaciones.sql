-- Verificación 1: contar las filas donde medicion es nula. 
select count(*)
from lecturas_generadas
where medicion is null;

--Verificación 2: comprobar que cada tipo y zona tiene valores dentro de su rango.
select l.tipo,l.zona, min(l.medicion) as minimo, max(l.medicion) as maximo, count(*)
from lecturas_generadas l
group by l.tipo, l.zona
