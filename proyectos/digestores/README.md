# Monitoreo y detección de fallas en digestores de una planta de celulosa
Se trabajó con datos simulados para interpretar anomalías en el funcionamiento
de los digestores de una planta. Se utilizó PostgreSQL, corriendo en Docker.
El modelo tiene 5 tablas, 11.424 lecturas de sensores y 12 consultas de análisis.

 **Hallazgo principal:** El análisis mostró que la falla de la bomba de circulación
de licor del DIG-L2 se podía haber detectado dos horas y media antes de la primera
intervención: la temperatura de cocción salió de su rango normal a las 14:00,
pero el técnico llegó a las 16:30.

## Contexto

El digestor es el equipo donde se cuece la madera a alta temperatura, entre 150 y 170 °C.
Esta cocción, con licor blanco, disuelve la lignina, la sustancia que mantiene unidas las
fibras de la madera, y deja libres las fibras de celulosa que forman la pulpa. Es el
corazón del proceso kraft.

Las variables monitoreadas son:

- **Temperatura por zona:** si la zona de cocción no llega a su rango, la lignina no se
  disuelve, la madera queda mal cocida y la pulpa sale de peor calidad.
- **Presión:** mantiene el licor líquido por sobre los 100 °C.
- **Nivel:** indica la altura de la columna de astillas y licor. Si baja demasiado, la
  cocción es más corta e incompleta; si sube demasiado, hay riesgo de atascos o rebalses.
- **Flujo de licor:** controla la proporción entre licor y madera. Con poco licor no se
  disuelve toda la lignina; con demasiado, se gasta químico de más y se dañan las fibras.

En una planta real, estos datos vendrían de una cadena: los sensores miden, el DCS los lee
y controla el proceso, y el historiador guarda cada variable con su valor y su hora. Un
ejemplo es AVEVA PI, el historiador más usado en la industria. En este proyecto, los datos
fueron simulados para imitar esa salida: la tabla `lecturas` guarda una medición de cada
sensor cada 15 minutos durante una semana.

## Modelo de datos

![Diagrama del modelo](diagrama_modelo.png)

| Tabla | Contenido |
|---|---|
| `digestores` | los 3 digestores: tag, tipo, ubicación y capacidad |
| `sensores` | los 17 sensores: tag, tipo, zona, unidad y digestor |
| `lecturas` | una medición por sensor cada 15 minutos |
| `tecnicos` | los técnicos y su especialidad |
| `mantenimientos` | las intervenciones: técnico, digestor, tipo, fecha y duración |

### Decisiones de diseño

- **La ubicación en planta va en `digestores`, no en `sensores`:** un sensor está montado
  en un digestor, así que su ubicación depende del digestor. Repetirla en cada sensor
  violaría la 3FN, y si un digestor cambiara de línea habría que editar varias filas.
- **Los tags son únicos:** identifican equipos en la planta. La restricción `UNIQUE` hace
  que Postgres rechace un tag duplicado. El nombre de los técnicos no es único, porque dos
  personas pueden llamarse igual.
- **El tipo de digestor tiene un `CHECK`:** solo acepta `continuo` o `batch`, y evita
  valores inválidos o mal escritos.
- **`mantenimientos` es una tabla intermedia:** técnicos y digestores tienen una relación
  muchos a muchos (N:M). Se resuelve con dos FK (`tecnico_id` y `digestor_id`) y los datos
  propios de cada intervención.
- **La unidad queda en `sensores`:** depende del tipo de sensor, no de cada sensor, así que
  en 3FN iría en una tabla `tipos_sensor`. Decidí dejarla en `sensores` como simplificación,
  porque el modelo es pequeño.
- **Las FK son `NOT NULL`:** una lectura sin sensor, o un mantenimiento sin técnico, no
  tiene sentido.
- **Datos reproducibles con `setseed`:** fija la secuencia de números al azar, así
  cualquiera que ejecute el script obtiene los mismos resultados que aparecen en este README.

##  Datos simulados
Se simularon datos del 1 al 7 de octubre de 2026, con una lectura por sensor cada 15 minutos: 17 sensores × 672 instantes = 11.424 lecturas. Se generaron con `generate_series` para los instantes, `CROSS JOIN` para combinarlos con cada sensor, y `random()` con un `CASE` para dar a cada sensor valores dentro de su rango. Después, los eventos se aplicaron con `UPDATE`.

### Rangos normales

| Variable | Zona | Rango Normal |
|---|---|---|
| Temperatura | superior| 110 – 130 °C |
| Temperatura | cocción| 150 – 170 °C |
| Temperatura | inferior| 80 – 100 °C|
| Presión | --- | 7 – 12 bar |
| Nivel | --- | 40 – 90 % |
| Flujo de licor | --- | 200 – 400 m³/h|

### Eventos de la semana 

| Evento| Digestor| Inicio| Fin | Efecto en las lecturas
|---|---|---|---|---|
| Detención por correctivo | DIG-L1| 3 oct, 10:00 | 4 oct, 10:00 | temperatura 50–80 °C, presión 0–1 bar, flujo 0–5 m³/h
| Falla de la bomba de circulación | DIG-L2| 5 oct, 14:00| 6 oct, 09:00 | cocción 130–140 °C, flujo 100–150 m³/h
| Detención por correctivo | DIG-L2| 6 oct, 09:00| 6 oct, 21:00 | temperatura 50–80 °C, presión 0–1 bar, flujo 0–5 m³/h

El 5 de octubre a las 14:00, la bomba de circulación de licor del DIG-L2 empezó a fallar. A las 16:30 llegó la instrumentista, porque se sospechaba de un sensor, pero el problema siguió porque la causa era mecánica. Al día siguiente, a las 09:00, el mecánico encontró la falla en la bomba y detuvo el digestor durante 12 horas para repararla. 

Por su parte, DIG-L3 operó normal toda la semana y sirve como referencia para comparar. 

## Hallazgos

### 1. Perfil de temperatura por digestor y zona

| Zona | DIG-L1 | DIG-L2 | DIG-L3 |
|---|---|---|---|
| superior | 112.19| 116.24 | 119.58 |
| cocción | 146.23| 150.50 | --- |
| inferior | 86.64 | 88.32 | 89.85 |

El DIG-L3 operó normal toda la semana y sirve como referencia. El DIG-L1 tiene todas
sus zonas por debajo de la referencia, de forma pareja, por su detención de 24 horas,
durante la cual las temperaturas bajaron a entre 50 y 80 °C. En el DIG-L2, la zona de
cocción fue la más afectada, porque sufrió dos eventos: la falla de la bomba de
circulación de licor y la detención, mientras que las zonas superior e inferior solo
tuvieron la detención.

### 2. Temperatura de cocción dia por dia

| Día | DIG-L1 | DIG-L2 
|---|---|---|
| 1 oct | 159.9| 160.55 | 
| 2 oct | 160.78| 160.47 | 
| 3 oct | **102.39** | 159.77 | 
| 4 oct | **120.41** | 161.05 | 
| 5 oct | 159.88 | **149.62** | 
| 6 oct | 160.39 | **103.25** | 
| 7 oct | 159.89 | 158.81 | 

En el DIG-L1 destacan el 3 y el 4 de octubre, y en el DIG-L2, el 5 y el 6. Los eventos
cruzan la medianoche, así que sus horas se reparten entre dos días.

El 5 de octubre del DIG-L2 casi no se nota, porque ese día no hubo detención, sino la
falla de la bomba de circulación de licor. Durante la falla, la cocción bajó a
130–140 °C, no a 50–80 °C como en una detención: una caída mucho más suave. Además,
la falla empezó a las 14:00, así que 14 de las 24 horas de ese día fueron normales.

El promedio diario sirve para detectar desviaciones respecto al rango normal de operación. Detecta bien las detenciones, pero casi esconde las fallas más suaves, como la de la bomba. Para encontrarlas hay que analizar las lecturas una por una, como en el siguiente hallazgo.

### 3. El inicio de la falla

| Momento | Lectura anterior | Lectura actual |
|---|---|---|
| 5 oct, 14:00 | 155,49 °C | 134,35 °C |

Se utilizó la función de ventana `LAG` para poner al lado de cada lectura el valor de
la medición anterior, y se buscó el momento en que la temperatura de cocción cruzó el
umbral de 150 °C: la lectura anterior dentro del rango normal y la actual por debajo.

Se eligió el cruce del umbral en vez de buscar una caída brusca, porque el ruido normal
del sensor entre dos lecturas puede llegar a 20 °C. Si se hubieran buscado caídas de
más de 25 °C, esta falla, de 21 °C, no habría aparecido; con caídas de más de 15 °C,
habría falsas alarmas en lecturas normales. El umbral evita ambos problemas, porque en
operación normal la cocción nunca baja de 150 °C.

Esto importa porque la falla empezó a las 14:00, pero la instrumentista llegó a las
16:30. Una alarma con esta lógica habría avisado 2,5 horas antes.

### 4. Horas de detención vs. registro de mantenimiento

| Digestor | Horas de correctivo (registro) | Horas detenido (sensores) |
|---|---|---|
| DIG-L1 | 24 | 24 |
| DIG-L2 | 15 | 12 |

Las horas de detención se calcularon a partir de las lecturas de flujo bajo 10 m³/h,
contando cada lectura como 15 minutos. En el DIG-L2 se contaron 12 horas de detención y
no 15, porque durante las 3 horas del correctivo del 5 de octubre el digestor siguió
operando, con el flujo reducido por la falla (entre 100 y 150 m³/h).

Las horas de mantenimiento no son lo mismo que las horas de detención. Cruzar el
registro de mantenimiento con los datos de los sensores permite calcular con más
precisión la producción perdida: usando solo el registro, se habrían contado 3 horas
de detención que no ocurrieron.

### 5. Temperatura de cocción en las 6 horas previas a cada correctivo

| Correctivo | Inicio | Temp. promedio previa | Qué indica |
|---|---|---|---|
| DIG-L1 | 3 oct, 10:00 | 159,74 °C | Falla repentina, sin señales previas |
| DIG-L2 | 5 oct, 16:30 | 149,85 °C | La falla llevaba 2,5 h cuando llegó la instrumentista |
| DIG-L2 | 6 oct, 09:00 | 135,50 °C | La primera intervención no resolvió el problema |

El valor del 5 de octubre queda casi en el límite porque la ventana mezcla 3,5 horas
normales (10:30 a 14:00) con 2,5 horas de falla (14:00 a 16:30).

Analizar qué ocurre antes de cada correctivo es la base del mantenimiento predictivo: si se reconocen los patrones previos a una falla, se pueden configurar alarmas que avisen antes y programar la mantención a tiempo, en vez de reaccionar cuando el equipo ya falló.

## Cómo ejecutarlo

**Requisitos:** Docker, Git y un cliente SQL (por ejemplo, DBeaver).

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/Danisa19/data-engineering-journey.git
   cd data-engineering-journey/proyectos/digestores
   ```

2. Levantar PostgreSQL en Docker:

   ```bash
   docker run --name postgres-dev \
     -e POSTGRES_USER=postgres \
     -e POSTGRES_PASSWORD=tu_contraseña \
     -p 5432:5432 \
     -d postgres:16
   ```

3. Crear la base de datos `planta_celulosa`:

   ```bash
   docker exec -it postgres-dev psql -U postgres -c "CREATE DATABASE planta_celulosa;"
   ```

4. Ejecutar los scripts, en este orden:

   | Orden | Archivo | Qué hace |
   |---|---|---|
   | 1 | `planta_celulosa_carga.sql` | Crea las tablas y carga los datos simulados |
   | 2 | `verificaciones.sql` | Revisa la calidad de los datos |
   | 3 | `02_consultas.sql` | Ejecuta las 12 consultas de análisis |

   Se pueden ejecutar desde DBeaver, conectado a `planta_celulosa`, o desde la terminal:

   ```bash
   docker exec -i postgres-dev psql -U postgres -d planta_celulosa < planta_celulosa_carga.sql
   ```

5. Verificar la carga: `SELECT COUNT(*) FROM lecturas;` debe devolver **11.424**.

Gracias a `setseed`, los resultados son los mismos que los de la sección de hallazgos.

## Estructura del repositorio

| Archivo | Contenido |
|---|---|
| `README.md` | Documentación del proyecto: contexto, modelo, hallazgos e instrucciones |
| `diagrama_modelo.png` | Diagrama entidad-relación |
| `planta_celulosa_carga.sql` | Crea las tablas y carga los datos simulados |
| `verificaciones.sql` | Revisa la calidad de los datos |
| `02_consultas.sql` | Ejecuta las 12 consultas de análisis |

## Próximos pasos

- Un script en Python que genere las lecturas y las cargue a Postgres, en vez de hacerlo con SQL
- Que ese pipeline corra solo, por ejemplo cada 15 minutos, con Airflow
- Un modelo dimensional con dbt: las lecturas como tabla de hechos, y los digestores y sensores como dimensiones
- Llevar la base y el pipeline a AWS
- Implementar la alarma del hallazgo 3 dentro del pipeline, para que avise automáticamente cuando una variable cruce su umbral.