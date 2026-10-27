-- Proyecto: Monitoreo de digestores - Planta de celulosa
-- Archivo: consultas de negocio
-- Ejecutar planta_celulosa_carga.sql

-- Nivel 1: JOIN y agregaciones

-- 1. ¿Cuál es la temperatura promedio de cada digestor en cada zona?
-- el perfil de temperatura muestra si la cocción
-- se hace bien y permite comparar digestores.
select d.tag, s.zona, round(avg(l.medicion), 2) as temperatura_promedio
from sensores s
inner join lecturas l on l.sensor_id = s.id
inner join digestores d on d.id = s.digestor_id
where s.tipo = 'temperatura'
group by d.tag, s.zona
order by d.tag, case
        when s.zona = 'superior' then 1
        when s.zona = 'coccion' then 2
        when s.zona = 'inferior' then 3
    end;

-- 2. ¿Cuántos mantenimientos tuvo cada digestor, por tipo?
-- La proporcion de mantenciones muestra que digestor falla mas y cual se mantiene solo con prevencion.

select d.tag, 
	count(*) filter (where m.tipo = 'preventivo') as preventivos, count(*) filter (where m.tipo = 'correctivo') as correctivos
from digestores d 
inner join mantenimientos m on m.digestor_id = d.id
group by d.tag
order by d.tag

-- 3. ¿Cuántas horas de mantenimiento acumuló cada especialidad?
-- Comparar horas con cantidad de trabajos muestra si la carga viene de muchas tareas cortas o de pocas fallas largas.

select t.especialidad, SUM(m.duracion_horas) as horas_mantencion, count(*) as cantidad_mantenimientos
from mantenimientos m
inner join tecnicos t on t.id = m.tecnico_id 
group by t.especialidad 
order by horas_mantencion desc;

-- 4. ¿Qué digestor acumuló más horas de mantenimiento correctivo?
-- El DIG-L1 acumuló más horas de correctivo con una sola falla de 24 horas, aunque el DIG-L2 tuvo más correctivos. 
-- La duración pesa más que la frecuencia en la producción perdida.

select d.tag, sum(m.duracion_horas) as horas_mantenimiento_correctivo
from digestores d
inner join mantenimientos m on m.digestor_id = d.id
where m.tipo = 'correctivo'
group by d.tag
order by horas_mantenimiento_correctivo desc limit 1;

-- 5. ¿Qué sensores de temperatura de cocción registraron lecturas bajo 150 °C, y cuántas?
-- los únicos sensores de cocción con lecturas anormales fueron el TT-101 y el TT-201, con 96 y 124 lecturas bajo 150 °C. Esos números coinciden exactamente con los períodos de la detención del DIG-L1 y de la anomalía más la detención del DIG-L2. El resto de la semana, los dos operaron con normalidad.

select s.tag, count(*) as lecturas_bajo_150
from sensores s
inner join lecturas l on l.sensor_id = s.id
where s.tipo = 'temperatura' and l.medicion < 150 and s.zona = 'coccion'
group by s.tag
having count(*) > 10;

-- 6. ¿Cuál fue la temperatura promedio de cocción de cada digestor, día por día?
-- Los dias anomalos como el 3 y 4 de octubre para dig-l1 fue bajo y el 5 y 6 de octubre tambien, como esperaba.

select d.tag, l.fecha_hora::date as dia, round((AVG(l.medicion)), 2) as temperatura_promedio
from sensores s
inner join digestores d on d.id = s.digestor_id
inner join lecturas l on l.sensor_id = s.id
where s.tipo = 'temperatura' and s.zona = 'coccion'
group by d.tag, l.fecha_hora::date
order by d.tag, dia;

-- 7. ¿Qué digestores tuvieron una temperatura de cocción promedio por debajo del promedio general de la planta?
-- Comparar cada digestor con el promedio de la planta indica cuál está rindiendo peor y conviene revisar primero.

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


