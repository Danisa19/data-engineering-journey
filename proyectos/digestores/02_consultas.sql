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

-- ---------------------------------------------------------
-- Nivel 3: subconsultas y CTE
-- ---------------------------------------------------------

-- 8. ¿Qué días el flujo promedio del DIG-L2 estuvo por debajo de su propio promedio semanal?
-- Por qué importa: el flujo es la variable más cercana a la falla de la bomba.
-- Respuesta: el 5 y el 6 de octubre. El 6 es el más bajo, porque concentró la
-- anomalía y la detención; el 5 baja por la anomalía que empezó a las 14:00.
with flujo_diario as (
    select l.fecha_hora::date as dia, avg(l.medicion) as flujo_promedio_diario
    from sensores s
    inner join lecturas l on l.sensor_id = s.id
    inner join digestores d on d.id = s.digestor_id
    where s.tipo = 'flujo' and d.tag = 'DIG-L2'
    group by l.fecha_hora::date
)
select f.dia,
       round(f.flujo_promedio_diario, 2) as flujo_promedio_diario,
       (select round(avg(f2.flujo_promedio_diario), 2) from flujo_diario f2) as flujo_promedio_semanal
from flujo_diario f
where f.flujo_promedio_diario < (select avg(f2.flujo_promedio_diario) from flujo_diario f2)
order by f.dia;

-- ---------------------------------------------------------
-- Nivel 4: funciones de ventana
-- ---------------------------------------------------------

-- 9. Para cada digestor, ¿cuál fue su día de cocción más caliente?
-- Por qué importa: da una referencia del mejor rendimiento de cada digestor.
-- Respuesta: en ambos es un día normal, cerca de 160 °C. Los días normales
-- difieren en décimas, así que el ganador depende del ruido de los datos.
with temperatura_diaria as (
    select d.tag, l.fecha_hora::date as dia, avg(l.medicion) as temp_coccion_promedio
    from sensores s
    inner join lecturas l on l.sensor_id = s.id
    inner join digestores d on d.id = s.digestor_id
    where s.tipo = 'temperatura' and s.zona = 'coccion'
    group by d.tag, l.fecha_hora::date
),
ranking_diario as (
    select tag, dia, temp_coccion_promedio,
           row_number() over (partition by tag order by temp_coccion_promedio desc) as ranking
    from temperatura_diaria
)
select tag, dia, round(temp_coccion_promedio, 2) as temp_coccion_promedio
from ranking_diario
where ranking = 1;

-- 10. ¿Cuándo empezó la anomalía del DIG-L2?
-- Por qué importa: saber desde cuándo existe una falla permite revisar qué pasó antes.
-- Respuesta: el 5 de octubre a las 14:00, cuando la temperatura de cocción cruzó
-- el límite normal de 150 °C. Se usa el cruce del umbral y no una caída fija,
-- porque el ruido normal del sensor puede llegar a 20 °C entre lecturas.
with lecturas_tt201 as (
    select l.fecha_hora as dia_hora,
           l.medicion as valor_actual,
           lag(l.medicion) over (order by l.fecha_hora) as valor_anterior
    from sensores s
    inner join lecturas l on l.sensor_id = s.id
    where s.tag = 'TT-201'
)
select dia_hora, valor_actual, valor_anterior
from lecturas_tt201
where valor_anterior >= 150 and valor_actual < 150;

-- 11. ¿Cuántas horas estuvo detenido cada digestor, según sus lecturas de flujo?
-- Por qué importa: valida los registros de mantenimiento con una fuente independiente.
-- Respuesta: DIG-L1, 24 horas; DIG-L2, 12 horas. El registro del DIG-L2 suma 15 horas
-- de correctivo, pero 3 de ellas (la revisión de la instrumentista) se hicieron
-- con el digestor funcionando. Horas de mantenimiento no son horas de detención.
select d.tag, count(*) * 0.25 as horas_detenido
from sensores s
inner join digestores d on d.id = s.digestor_id
inner join lecturas l on l.sensor_id = s.id
where s.tipo = 'flujo' and l.medicion < 10
group by d.tag
order by d.tag;

-- 12. Para cada mantenimiento correctivo, ¿cuál era la temperatura de cocción promedio en las 6 horas previas?
-- Por qué importa: muestra si la falla dio señales antes de la intervención (base del mantenimiento predictivo).
-- Respuesta:
--   DIG-L1, 3 oct 10:00: ~160 °C. Falla repentina, sin señales previas.
--   DIG-L2, 5 oct 16:30: ~150 °C. La falla llevaba 2,5 horas cuando llegó la instrumentista.
--   DIG-L2, 6 oct 09:00: ~135 °C. La primera intervención no resolvió el problema.
select m.id, d.tag,
       m.fecha_inicio as inicio_mantenimiento,
       round(avg(l.medicion), 2) as temp_coccion_previa,
       count(*) as lecturas
from mantenimientos m
inner join digestores d on d.id = m.digestor_id
inner join sensores s on s.digestor_id = m.digestor_id
inner join lecturas l on l.sensor_id = s.id
where m.tipo = 'correctivo'
  and s.tipo = 'temperatura'
  and s.zona = 'coccion'
  and l.fecha_hora >= m.fecha_inicio - interval '6 hours'
  and l.fecha_hora <  m.fecha_inicio
group by m.id, d.tag, m.fecha_inicio
order by m.fecha_inicio;

