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

