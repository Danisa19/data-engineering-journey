import sys
import os
from datetime import datetime

print("=== HOLA DESDE ADENTRO DEL CONTENEDOR DOCKER ===")
print(f"Fecha y hora de ejecución: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print(f"Carpeta actual dentro del contenedor: {os.getcwd()}")
print(f"Versión de Python del contenedor: {sys.version.split()[0]}")
print("================================================")

