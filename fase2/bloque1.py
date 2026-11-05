# Reto 1 

tag = "PT-200"
tipo = "presion"
unidad = "bar"

print(f"El sensor {tag} mide {tipo} en {unidad}")

# Reto 2

temperaturas_coccion = [158.2, 161.5, 134.3, 159.8, 136.7]
print(f"Se registraron {len(temperaturas_coccion)} mediciones. La mayor medicion fue de {max(temperaturas_coccion)} {unidad} y la menor fue {min(temperaturas_coccion)} {unidad}")

# Reto 3 

promedio = sum(temperaturas_coccion) / len(temperaturas_coccion)
print(f"El promedio es: {promedio}")

# Reto 4

temperaturas_coccion.append(162.0)
promedio_2 = sum(temperaturas_coccion) / len(temperaturas_coccion)
print(f"Se registraron {len(temperaturas_coccion)} mediciones. El nuevo promedio es: {round(promedio_2, 2)}")
