import psycopg2

conexion = psycopg2.connect(
    host="localhost",
    database="postgres",
    user="dani_admin",  # <-- Aquí va tu usuario correcto
    password="1213",
    port="5433"
)

cursor = conexion.cursor()

query_sql = """
WITH recaudacion_por_cancha AS (
    SELECT 
        canchas.nombre, 
        COALESCE(SUM(reservas.horas * canchas.precio_hora), 0) AS total_cancha
    FROM canchas
    LEFT JOIN reservas ON canchas.id = reservas.cancha_id
    GROUP BY canchas.nombre
)
SELECT nombre, total_cancha
FROM recaudacion_por_cancha
WHERE total_cancha > (SELECT AVG(total_cancha) FROM recaudacion_por_cancha);
"""

# 4. Ejecutamos y traemos los datos
cursor.execute(query_sql)
resultados = cursor.fetchall()

print("--- REPORTE DE CANCHAS SOBRE EL PROMEDIO ---")
for fila in resultados:
    nombre_cancha = fila[0]
    monto_recaudado = fila[1]
    print(f"La cancha '{nombre_cancha}' recaudó un total de ${monto_recaudado:,}")

cursor.close()
conexion.close()
