#!/usr/bin/env bash
set -euo pipefail

# No root
if [[ "${EUID}" -eq 0 ]]; then
  echo "❌ No ejecutes esto como root. Ejecuta como usuario normal."
  exit 1
fi

# sudo existe
if ! command -v sudo >/dev/null 2>&1; then
  echo "❌ No tienes sudo instalado."
  exit 1
fi

# el usuario debe tener sudo (wheel o sudo)
if ! groups | grep -Eq '(\bwheel\b|\bsudo\b)'; then
  echo "❌ Tu usuario no está en wheel/sudo. Necesitas privilegios de sudo."
  exit 1
fi

# Sesión i3 (sin inventar)
# Permite: i3 / i3wm / xsession con i3, etc.
desktop="${XDG_CURRENT_DESKTOP:-}"
session="${DESKTOP_SESSION:-}"

if ! echo "$desktop $session" | grep -Ei 'i3|i3wm' >/dev/null; then
  echo "⚠️  No se detecta sesión i3 activa."
  echo "    XDG_CURRENT_DESKTOP='$desktop'"
  echo "    DESKTOP_SESSION='$session'"
  echo "    Continuando instalación igualmente…"
fi

# Sudo ok (pedimos pass una vez)
echo "🔐 Validando sudo..."
sudo -v
