#!/usr/bin/env bash
# =====================================================
#  d1se0 Arch i3 Environment Installer
#  Author: Diseo
#  GitHub: https://github.com/D1se0
#  YouTube: https://www.youtube.com/@Hacking_Community
# =====================================================

set -euo pipefail
set -x

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/scripts/checks.sh"
source "$ROOT_DIR/scripts/install_deps.sh"
source "$ROOT_DIR/scripts/apply_files.sh"

find $HOME -type f -name "*.sh" -exec chmod +x {} +

echo
echo "✅ Instalación terminada."
echo "👉 Cierra sesión o reinicia para que todo cargue limpio."
