#!/bin/bash
set -e

LAMBDA_SRC_DIR=$1
OUTPUT_ZIP=$2
REQUIREMENTS_FILE=$3

echo "--- 🛠️ Packaging Lambda ---"
WORK_DIR=$(mktemp -d)

# Copiar código fuente
cp -r ${LAMBDA_SRC_DIR}/* ${WORK_DIR}/

# Instalar dependencias en el directorio temporal
pip install -r ${REQUIREMENTS_FILE} -t ${WORK_DIR}/

# Crear el ZIP en la ruta absoluta
cd ${WORK_DIR}
zip -r ${OLDPWD}/${OUTPUT_ZIP} .
cd -

# Limpiar
rm -rf ${WORK_DIR}

echo "--- ✅ Lambda package created at ${OUTPUT_ZIP} ---"
