#!/usr/bin/env bash
# La línea 1 (shebang) le indica a Linux que este archivo debe ejecutarse con bash

# Definimos la variable con el nombre de nuestro archivo de registro
LOG_FILE="reporte_sistema.log"

# 1. Creamos el encabezado usando '>' (sobrescribe el archivo si ya existía)
echo "=== AUDITORÍA DE ENTORNO: $(date '+%Y-%m-%d %H:%M:%S') ===" > "$LOG_FILE"

# 2. Medimos el disco con 'df -h /', filtramos la fila 2 con '|' y agregamos con '>>'
echo -e "\n[1] Espacio en disco:" >> "$LOG_FILE"
df -h / | awk 'NR==2 {print "Usado: " $3 " de " $2 " (" $5 ")"}' >> "$LOG_FILE"

# 3. Consultamos la versión de Docker (guardando salida normal y posibles errores)
echo -e "\n[2] Estado de Docker:" >> "$LOG_FILE"
docker --version >> "$LOG_FILE" 2>&1

# 4. Forzamos un error a propósito listando una carpeta que no existe
# Gracias a '2>&1', el error del Canal 2 se mete al archivo y NO ensucia la pantalla
echo -e "\n[3] Prueba de captura de errores (Canal 2):" >> "$LOG_FILE"
ls /ruta_fantasma_inexistente >> "$LOG_FILE" 2>&1

echo "Auditoría completada. Archivo generado: $LOG_FILE"
