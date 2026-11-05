lecturas = [
    {"sensor": "TT-201", "hora": "13:30", "medicion": 159.4},
    {"sensor": "TT-201", "hora": "13:45", "medicion": 155.5},
    {"sensor": "TT-201", "hora": "14:00", "medicion": 134.4},
    {"sensor": "TT-201", "hora": "14:15", "medicion": 137.9},
    {"sensor": "TT-201", "hora": "14:30", "medicion": 131.2},
]

# Reto 1

i = 1

for lectura in lecturas:
    print(f"{i}. El sensor {lectura["sensor"]} a las {lectura["hora"]} midió {lectura["medicion"]} °C")
    i += 1

# Reto 2 

variables_anormales = 0

for lectura in lecturas:
    if lectura["medicion"] < 150:
        print(f"El sensor {lectura["sensor"]} a las {lectura["hora"]} midió {lectura["medicion"]} ⚠ ANORMAL")
        variables_anormales += 1
print(f"Hay {variables_anormales} lecturas anormales.")

# Reto 4

mediciones = []

for lectura in lecturas:
    mediciones.append(lectura["medicion"])
print(f"Las mediciones fueron: {mediciones}")

def promedio(numeros):
    
    resultado = sum(numeros) / len(numeros)
    return round(resultado, 2)

print(f"El promedio entre las {len(mediciones)} mediciones es {promedio(mediciones)} °C")

# Reto 5

for i in range(1, len(lecturas)):
    temperatura_actual = mediciones[i]
    temperatura_anterior = mediciones[i-1]
    if temperatura_anterior >= 150 and temperatura_actual < 150:
        print(f"A las {lecturas[i]["hora"]} se cruzo el umbral de temperatura") 

    
