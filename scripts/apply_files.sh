#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Ejecutando apply_files.sh"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="$HOME"

echo "ROOT_DIR = $ROOT_DIR"
ls -la "$ROOT_DIR/system/lightdm" || true
ls -la "$ROOT_DIR/system/backgrounds" || true
ls -la "$ROOT_DIR/config/bin" || true

echo "📁 Aplicando archivos del entorno…"

# ─────────────────────────────
# 1) HOME del usuario
# ─────────────────────────────
if [[ -d "$ROOT_DIR/config/home" ]]; then
  echo "👤 Sincronizando HOME del usuario"
  rsync -a --delete-after \
    --exclude ".cache/" \
    --exclude ".local/share/nvim/" \
    --exclude ".local/state/" \
    --exclude ".config/mozilla/" \
    --exclude "arch-i3-d1se0/" \
    "$ROOT_DIR/config/home/" "$HOME_DIR/"
else
  echo "⚠️ No existe config/home/"
fi

# ─────────────────────────────
# 1.1) Creación de SYMLINKS (PORTABLES)
# ─────────────────────────────
echo "🔗 Creando enlaces simbólicos del usuario"

link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

# Dotfiles principales
link "$HOME_DIR/.config/zsh/.zshrc"        "$HOME_DIR/.zshrc"
link "$HOME_DIR/.config/gtk-2.0/gtkrc-2.0" "$HOME_DIR/.gtkrc-2.0"
link "$HOME_DIR/.config/x11/xprofile"      "$HOME_DIR/.xprofile"
link "$HOME_DIR/.config/shell/profile"     "$HOME_DIR/.zprofile"

# Configs wal-dependientes
if [[ -d "$HOME_DIR/.cache/wal" ]]; then
  mkdir -p "$HOME_DIR/.config/dunst"
  mkdir -p "$HOME_DIR/.config/zathura"

  link "$HOME_DIR/.cache/wal/dunstrc"     "$HOME_DIR/.config/dunst/dunstrc"
  link "$HOME_DIR/.cache/wal/zathurarc"   "$HOME_DIR/.config/zathura/zathurarc"
fi

# ─────────────────────────────
# 2) Binarios personalizados → /usr/local/bin
# ─────────────────────────────
if [[ -d "$ROOT_DIR/config/bin" ]] && compgen -G "$ROOT_DIR/config/bin/*" > /dev/null; then
  echo "🧰 Instalando binarios personalizados"
  sudo install -Dm755 "$ROOT_DIR"/config/bin/* -t /usr/local/bin/
else
  echo "⚠️ No hay binarios en config/bin"
fi

# ─────────────────────────────
# 3) Configuración de root (symlinks dinámicos)
# ─────────────────────────────
if [[ -d "$ROOT_DIR/config/root" ]]; then
  echo "👑 Aplicando configuración de root"
  sudo rsync -a "$ROOT_DIR/config/root/" /root/
fi

echo "🔗 Creando symlinks de root hacia el usuario"

sudo rm -rf /root/.cache/wal
sudo mkdir -p /root/.config

sudo ln -sfn "$HOME_DIR/.config/zsh"      /root/.config/zsh
sudo ln -sfn "$HOME_DIR/.config/ohmyposh" /root/.config/ohmyposh
sudo ln -sfn "$HOME_DIR/.config/shell"    /root/.config/shell
sudo ln -sfn "$HOME_DIR/.cache/wal"       /root/.cache/wal
sudo ln -sfn /root/.config/zsh/.zshrc     /root/.zshrc

# ─────────────────────────────
# 4) LightDM (conf + theme)
# ─────────────────────────────

# 4.1 Configuración del greeter
if [[ -f "$ROOT_DIR/system/lightdm/lightdm-gtk-greeter.conf" ]]; then
  sudo install -Dm644 \
    "$ROOT_DIR/system/lightdm/lightdm-gtk-greeter.conf" \
    /etc/lightdm/lightdm-gtk-greeter.conf
fi

if [[ -d "$ROOT_DIR/system/lightdm/LightDM-Wal" ]]; then
  sudo mkdir -p /usr/share/themes/LightDM-Wal
  sudo rsync -a "$ROOT_DIR/system/lightdm/LightDM-Wal/" \
    /usr/share/themes/LightDM-Wal/
fi

# ─────────────────────────────
# 5) Backgrounds del sistema
# ─────────────────────────────

if [[ -d "$ROOT_DIR/system/backgrounds" ]]; then
  echo "🖼️ Instalando backgrounds"
  sudo mkdir -p /usr/share/backgrounds
  sudo rsync -a "$ROOT_DIR/system/backgrounds/" /usr/share/backgrounds/
fi

# ─────────────────────────────
# 6) Systemd services
# ─────────────────────────────
if [[ -d "$ROOT_DIR/services" ]]; then
  echo "🧷 Instalando services"
  sudo rsync -a "$ROOT_DIR/services/" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable wal-to-lightdm.service
fi

# ─────────────────────────────
# 7) Sudoers
# ─────────────────────────────
if [[ -d "$ROOT_DIR/sudoers" ]]; then
  echo "🔐 Instalando reglas sudoers"
  for file in "$ROOT_DIR/sudoers/"*; do
    sudo install -Dm440 "$file" "/etc/sudoers.d/$(basename "$file")"
  done
fi

# ─────────────────────────────
# 8) Symlinks para /etc/skel (usuarios nuevos)
# ─────────────────────────────
echo "🧬 Creando symlinks en /etc/skel"

declare -A SKEL_LINKS=(
  [".cache"]=".cache"
  [".config"]=".config"
  [".local"]=".local"
  [".wallpapers"]=".wallpapers"
  [".gtkrc-2.0"]=".config/gtk-2.0/gtkrc-2.0"
  [".xprofile"]=".config/x11/xprofile"
  [".zprofile"]=".config/shell/profile"
)

for link in "${!SKEL_LINKS[@]}"; do
  target="/home/\$USER/${SKEL_LINKS[$link]}"
  sudo ln -sfn "$target" "/etc/skel/$link"
done

# Iniciar servicios de docker
# sudo systemctl enable docker
# sudo systemctl start docker

if [[ -d "$ROOT_DIR/config/home/.cache/wal" ]]; then
  echo "🎨 Restaurando cache de wal"
  mkdir -p "$HOME_DIR/.cache"
  rsync -a "$ROOT_DIR/config/home/.cache/wal/" "$HOME_DIR/.cache/wal/"
fi

echo "[*] Modifica con tu usuario el archivo /etc/sudoers.d/wal-to-lightdm-theme"
echo "✅ Arch i3 environment aplicado correctamente"
