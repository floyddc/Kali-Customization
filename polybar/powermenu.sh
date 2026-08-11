#!/bin/bash

options="󰐥  Shutdown
󰜉  Reboot
󰗼  Logout
󰒲  Suspend
󰤄  Hibernate"

chosen=$(printf '%s\n' "$options" | rofi -dmenu \
    -i \
    -p "run" \
    -theme /usr/share/rofi/themes/theme.rasi
)

case "$chosen" in
    "󰐥  Shutdown")
        systemctl poweroff
        ;;
    "󰜉  Reboot")
        systemctl reboot
        ;;
    "󰗼  Logout")
        xfce4-session-logout --logout
        ;;
    "󰒲  Suspend")
        systemctl suspend
        ;;
    "󰤄  Hibernate")
        systemctl hibernate
        ;;
esac