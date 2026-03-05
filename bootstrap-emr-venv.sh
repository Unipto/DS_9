#!/bin/bash
set -euo pipefail

VENV_DIR="/opt/venvs/tf219"
PY="/usr/bin/python3"

# Créer le venv (idempotent)
if [ ! -d "$VENV_DIR" ]; then
  sudo mkdir -p "$VENV_DIR"
  sudo $PY -m venv "$VENV_DIR"
  sudo chown -R "$(whoami)":"$(whoami)" "$VENV_DIR" || true
fi

# pip à jour dans le venv
"$VENV_DIR/bin/python" -m pip install -U pip setuptools wheel

# PINS stricts et stables (TF 2.19)
"$VENV_DIR/bin/pip" install \
  "tensorflow==2.19.0" \
  "numpy==1.26.4" \
  "ml-dtypes==0.5.1"

"$VENV_DIR/bin/pip" install \
  pillow pandas pyarrow boto3 s3fs fsspec

# --- Kernel Jupyter (sur le master uniquement)
# EMR expose le rôle dans /mnt/var/lib/info/instance.json
ROLE_FILE="/mnt/var/lib/info/instance.json"
IS_MASTER="false"
if [ -f "$ROLE_FILE" ]; then
  # sans jq (souvent non installé), on fait simple:
  if grep -q '"isMaster":true' "$ROLE_FILE"; then
    IS_MASTER="true"
  fi
fi

if [ "$IS_MASTER" = "true" ]; then
  # ipykernel dans le venv + installation du kernelspec
  "$VENV_DIR/bin/pip" install ipykernel

  # Installe le kernel globalement (visible dans Jupyter)
  sudo "$VENV_DIR/bin/python" -m ipykernel install \
    --name "tf219" \
    --display-name "Python (tf219)" \
    --prefix /usr/local
fi

echo "Bootstrap OK: venv=${VENV_DIR}"