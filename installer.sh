#!/bin/bash
current_path=$(pwd)
echo $current_path
apt update

# Packets installer
apt install -y polybar bspwm wmctrl xfce4-terminal tmux xbindkeys lsd vivid xclip bat rofi devilspie2
echo "Packets installed."

# Nerd fonts installer
mkdir tmpdir
cd tmpdir
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf JetBrainsMono.tar.xz
rm -r JetBrainsMono.tar.xz
mv * /usr/share/fonts
cd ..
rm -r tmpdir
fc-cache -fv
echo "Nerd fonts installed."

# lsd config
mkdir -p /etc/lsd
cp "$current_path/lsd/lsd_config.yaml" /etc/lsd/config.yaml
cp "$current_path/lsd/lsd_colors.yaml" /etc/lsd/colors.yaml
echo "lsd configured."

# Polybar config
mkdir -p /etc/polybar
cp "$current_path/polybar/polybar_config.ini" /etc/polybar/config.ini
mkdir -p /etc/polybar/scripts
cp "$current_path/polybar/target_setter.sh" /etc/polybar/scripts/target_setter.sh
chmod 777 /etc/polybar/scripts/target_setter.sh
cp "$current_path/polybar/polybar.desktop" /etc/xdg/autostart/polybar.desktop
echo "Polybar configured."

# vivid config
mkdir -p /etc/vivid
mkdir -p /etc/vivid/themes
cp "$current_path/vivid/vivid_theme.yml" /etc/vivid/themes/theme.yml
echo "vivid configured."

# Rofi config
mkdir -p /etc/rofi
mkdir -p /usr/share/rofi
mkdir -p /usr/share/rofi/themes
cp "$current_path/rofi/rofi_theme.rasi" /usr/share/rofi/themes/theme.rasi
echo "Rofi configured."

# Remove terminal border
mkdir -p /etc/skel/.config/devilspie2
cp "$current_path/qterminal-borders/qterminal.lua" /etc/skel/.config/devilspie2/qterminal.lua
cp "$current_path/qterminal-borders/qterminal.conf" /etc/xdg/qterminal.org/qterminal.conf
cp "$current_path/qterminal-borders/devilspie2.desktop" /etc/xdg/autostart/devilspie2.desktop
echo "Terminal border removed."

# ohmyzsh / p10k config
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ""
echo "Customization started. Now run installer2.sh"
