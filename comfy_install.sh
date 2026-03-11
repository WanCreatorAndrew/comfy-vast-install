#!/bin/bash
set -e

echo "Installing ComfyUI custom nodes..."

cd /workspace/ComfyUI/custom_nodes

clone_or_pull () {
if [ -d "$1/.git" ]; then
git -C "$1" pull
else
git clone "$2" "$1"
fi
}

# WAN video nodes

clone_or_pull "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper.git"

# SAM2

clone_or_pull "ComfyUI-SAM2" "https://github.com/kijai/ComfyUI-SAM2.git"

# TinyTerra nodes

clone_or_pull "ComfyUI_tinyterraNodes" "https://github.com/TinyTerra/ComfyUI_tinyterraNodes.git"

# Video helper suite

clone_or_pull "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"

# Impact pack (mask nodes)

clone_or_pull "ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"

echo "Installing dependencies..."

find /workspace/ComfyUI/custom_nodes -maxdepth 2 -name requirements.txt -print0 | while IFS= read -r -d '' req; do
pip install -r "$req"
done

echo "All nodes installed"
