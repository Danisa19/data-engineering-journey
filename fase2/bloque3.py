# Reto 1

import pandas as pd 

df = pd.read_csv("lecturas_multi.csv")

primeras_filas = df.head()

print(primeras_filas)
print(df.dtypes)

# Reto 2

mediciones_bajo_150 = df[df["medicion"] < 150]
print(mediciones_bajo_150)
print(len(mediciones_bajo_150))

# Reto 3

promedio_sensor = df.groupby("sensor")["medicion"].mean().round(2)
print(promedio_sensor)

# Reto 4

sensores = pd.read_csv("sensores.csv")
lecturas_sensores = pd.merge(df, sensores, left_on="sensor", right_on="tag")
lecturas_sensores_final = lecturas_sensores.drop(columns="tag")
print(lecturas_sensores_final)

# Reto 5

temp_coccion_bajo_150 = lecturas_sensores_final[
    (lecturas_sensores_final["medicion"] < 150) 
    & (lecturas_sensores_final["tipo"] == 'temperatura') 
    & (lecturas_sensores_final["zona"] == 'coccion')
]
print(temp_coccion_bajo_150)

# Reto 6

temp_coccion_bajo_150.to_csv("anormales_coccion.csv", index = False)