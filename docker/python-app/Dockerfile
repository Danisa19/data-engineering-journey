# 1. Descargar la imagen base oficial de Python 3.11 liviana
FROM python:3.11-slim

# 2. Definir la carpeta de trabajo dentro del contenedor
WORKDIR /app

# 3. Copiar nuestro script desde el PC hacia adentro del contenedor
COPY app.py .

# 4. Orden que se ejecutará al encender el contenedor
CMD ["python", "app.py"]
