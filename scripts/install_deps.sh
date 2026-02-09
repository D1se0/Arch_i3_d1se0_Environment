#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Ejecutando install_deps.sh"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PACMAN_LIST="$ROOT_DIR/deps/pacman.txt"
AUR_LIST="$ROOT_DIR/deps/aur.txt"

install_pacman() {
  echo "📦 Instalando paquetes (pacman)..."
  sudo pacman -Syu --noconfirm
  # filtra comentarios/vacíos
  mapfile -t pkgs < <(grep -vE '^\s*#' "$PACMAN_LIST" | sed '/^\s*$/d')
  if ((${#pkgs[@]})); then
    sudo pacman -S --needed --noconfirm "${pkgs[@]}" || 
    {
     echo "❌ Error instalando paquetes pacman"
     echo "👉 Revisa deps/pacman.txt"
     exit 1
    }
  fi
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    echo "✔ yay ya instalado"
    return 0
  fi

  echo "🧰 Instalando yay..."

  # 1) Intentar desde pacman primero (más estable)
  if sudo pacman -Si yay >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm yay
    return 0
  fi

  # 2) Fallback clásico por git (si pacman no lo tiene)
  echo "⚠️ yay no disponible en pacman, usando AUR manual"

  sudo pacman -S --needed --noconfirm base-devel git

  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"

  (
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
  )

  rm -rf "$tmpdir"
}

# ─────────────────────────────
# Evitar conflicto i3lock-color
# ─────────────────────────────
if pacman -Qi i3lock-color >/dev/null 2>&1; then
  echo "🧹 Eliminando i3lock-color (usamos i3lock estándar)"
  sudo pacman -Rns --noconfirm i3lock-color
fi

install_aur() {
  echo "📦 Instalando paquetes (AUR)..."
  mapfile -t aurpkgs < <(grep -vE '^\s*#' "$AUR_LIST" | sed '/^\s*$/d')
  if ((${#aurpkgs[@]})); then
    yay -S --needed --noconfirm "${aurpkgs[@]}"
  fi
}

install_pacman
ensure_yay
install_aur

# ─────────────────────────────
# Establecer zsh como shell por defecto
# ─────────────────────────────
if command -v zsh >/dev/null 2>&1; then
  echo "🐚 Estableciendo zsh como shell por defecto"

  ZSH_PATH="$(command -v zsh)"

  # Asegurar que zsh está en /etc/shells
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi

  # Cambiar shell a todos los usuarios con home válido
  while IFS=: read -r user _ uid _ _ home shell; do
    [[ "$uid" -ge 1000 && -d "$home" ]] || continue
    sudo chsh -s "$ZSH_PATH" "$user" || true
  done < /etc/passwd

  # Root también
  sudo chsh -s "$ZSH_PATH" root || true
fi
