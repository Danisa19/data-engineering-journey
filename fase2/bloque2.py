import csv
import json

def promedio(numeros):
    
    resultado = sum(numeros) / len(numeros)
    return round(resultado, 2)

# Reto 1
with open ("lecturas.csv", "r", encoding="utf-8" ) as archivo:
    lector = csv.DictReader(archivo)
    for fila in lector:
        print(fila)

# Reto 2
with open ("lecturas.csv", "r", encoding="utf-8" ) as archivo:
    lector = csv.DictReader(archivo)
    lecturas = []
    for fila in lector:
        fila["medicion"] = float(fila["medicion"])
        lecturas.append(fila)
    
    print(type(lecturas[0]["medicion"]))

# Reto 3

mediciones = []

for lectura in lecturas:
    medicion = lectura["medicion"]
    mediciones.append(medicion)

print(f"El promedio de temperatura es de: {promedio(mediciones)} °C")

# Reto 4 

with open ("anormales.csv", "w", encoding='utf-8', newline="") as archivo:
    escritor = csv.DictWriter(archivo, fieldnames=["sensor","hora","medicion"])
    escritor.writeheader()
    for lectura in lecturas:
        if lectura["medicion"] < 150:
            escritor.writerow(lectura)
            
# Reto 5

with open ("anormales.csv", "r", encoding='utf-8') as archivo:
    lector = csv.DictReader(archivo)
    mediciones_anormales = 0
    for fila in lector:
        mediciones_anormales += 1
        
hora_cruce = None

for i in range(1, len(lecturas)):
    temperatura_actual = mediciones[i]
    temperatura_anterior = mediciones[i-1]
    if temperatura_anterior >= 150 and temperatura_actual < 150:
        hora_cruce = lecturas[i]["hora"]


resumen = {
    "sensor": lecturas[0]["sensor"],
    "lecturas": len(lecturas),
    "anormales": mediciones_anormales,
    "promedio": promedio(mediciones),
    "hora_cruce": hora_cruce
}

with open("resumen.json", "w", encoding="utf-8") as archivo:
    json.dump(resumen, archivo, indent=2, ensure_ascii=False)