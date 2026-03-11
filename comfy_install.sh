#!/bin/bash
set -e

echo "[1/7] Preparing environment..."
export WORKSPACE_DIR="${WORKSPACE:-/workspace}"
export COMFY_DIR="${WORKSPACE_DIR}/ComfyUI"
export CUSTOM_NODES_DIR="${COMFY_DIR}/custom_nodes"
export WF_URL="https://raw.githubusercontent.com/ecstasydream1-crypto/comfy-vast-install/main/workflow.json"
export WF_PATH="${WORKSPACE_DIR}/workflow.json"

mkdir -p "${CUSTOM_NODES_DIR}"

clone_or_pull () {
  local dir="$1"
  local repo="$2"
  if [ -d "${dir}/.git" ]; then
    git -C "${dir}" pull || true
  else
    git clone "${repo}" "${dir}"
  fi
}

echo "[2/7] Installing ComfyUI-Manager..."
cd "${CUSTOM_NODES_DIR}"
clone_or_pull "${CUSTOM_NODES_DIR}/ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager.git"
pip install -r "${CUSTOM_NODES_DIR}/ComfyUI-Manager/requirements.txt"

echo "[3/7] Installing comfy-cli..."
python -m pip install --upgrade pip
python -m pip install comfy-cli

echo "[4/7] Downloading workflow JSON..."
curl -L "${WF_URL}" -o "${WF_PATH}"

echo "[5/7] Trying automatic dependency install from workflow..."
cd "${COMFY_DIR}"

# Основной автоматический способ: поставить ноды по workflow
# docs: comfy node install-deps --workflow <file>
if comfy node install-deps --workflow "${WF_PATH}" --mode local; then
  echo "Automatic workflow dependency install finished."
else
  echo "Automatic install had issues, continuing with fallback repos..."
fi

echo "[6/7] Fallback install for common missing repos..."
cd "${CUSTOM_NODES_DIR}"

# Часто нужные пакеты для твоего workflow
clone_or_pull "${CUSTOM_NODES_DIR}/ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper.git"
clone_or_pull "${CUSTOM_NODES_DIR}/ComfyUI_tinyterraNodes" "https://github.com/TinyTerra/ComfyUI_tinyterraNodes.git"
clone_or_pull "${CUSTOM_NODES_DIR}/ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
clone_or_pull "${CUSTOM_NODES_DIR}/rgthree-comfy" "https://github.com/rgthree/rgthree-comfy.git"
clone_or_pull "${CUSTOM_NODES_DIR}/ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"

# SAM2 repo: пробуем основной вариант, если не выйдет — просто идем дальше
if [ ! -d "${CUSTOM_NODES_DIR}/ComfyUI-SAM2/.git" ]; then
  git clone https://github.com/kijai/ComfyUI-SAM2.git "${CUSTOM_NODES_DIR}/ComfyUI-SAM2" || true
fi

echo "[7/7] Installing Python requirements from custom nodes..."
find "${CUSTOM_NODES_DIR}" -maxdepth 2 -name requirements.txt -print0 | while IFS= read -r -d '' req; do
  echo "Installing requirements from ${req}"
  pip install -r "${req}" || true
done

echo "Provisioning complete."
echo "If some nodes are still missing, open ComfyUI -> Manager -> Missing Nodes -> Install All."
