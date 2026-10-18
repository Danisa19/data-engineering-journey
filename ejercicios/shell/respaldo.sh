#!/usr/bin/env bash
# ==============================================================================
# Script: respaldo.sh (Día 1 - Semana 1)
# Uso: ./ejercicios/shell/respaldo.sh <carpeta_a_respaldar>
# ==============================================================================

CARPETA_ORIGEN="$1"
CARPETA_DESTINO="backups"
FECHA=$(date '+%Y%m%d_%H%M%S')

# 1. Validar que el usuario haya escrito qué carpeta quiere respaldar (-z = vacío)
if [ -z "$CARPETA_ORIGEN" ]; then
    echo "Error: Debes indicar qué carpeta quieres respaldar." >&2
    echo "Ejemplo de uso: ./ejercicios/shell/respaldo.sh notas" >&2
    exit 1
fi

# 2. Crear la carpeta 'backups' si aún no existe (-p evita errores si ya existe)
mkdir -p "$CARPETA_DESTINO"

# 3. Definir el nombre final del archivo comprimido
ARCHIVO_FINAL="$CARPETA_DESTINO/respaldo_${FECHA}.tar.gz"

# 4. Comprimir la carpeta (-c crear, -z comprimir con gzip, -f nombre de archivo)
echo "Creando respaldo de '$CARPETA_ORIGEN'..."
tar -czf "$ARCHIVO_FINAL" "$CARPETA_ORIGEN" 2>&1

# 5. Mostrar en pantalla cuánto pesa el respaldo usando un pipe (|)
echo "¡Respaldo exitoso! Detalle del archivo generado:"
ls -lh "$ARCHIVO_FINAL" | tail -n 1
