# Automatic Customization
Script and files to customize your Linux environment.<br> 
_Tested on Kali Linux 2024.4 and 2025.1c_

- [Recommended initial steps](#recommended-initial-steps)
- [Usage](#usage)
- [Further actions to do](#further-actions-to-do)
- [Useful shortcuts (to set)](#useful-shortcuts-to-set)
- [Other features (to set)](#other-features-to-set)
- [Useful commands (already set)](#useful-commands-already-set)
- [Screenshots](#screenshots)

## Recommended initial steps
- `sudo -s` to log in as superuser
- `sudo apt update` to check for updates
- `sudo apt upgrade` to upgrade packets

## Usage
- `chmod +x installer.sh installer2.sh` to give scripts execution permissions
- `./installer.sh` to run the first script
- Wait for the end of the first installation, so don't close anything
- `./installer2.sh` to run the second script

## Further actions to do
- Restart your Terminal to apply changes on Polybar and Terminal
- Restart your machine to apply changes on Terminal top border

## Useful shortcuts (to set)
_Super is the Windows button_
- `Keyboard settings -> Shortcuts`:
  - Run Terminal
    - COMMAND: `Super + Enter`
    - SHORTCUT: `qterminal`
  - Run Rofi application manager
    - COMMAND: `Super`
    - SHORTCUT: `rofi -show run -config /usr/share/rofi/themes/theme.rasi`
  - Run Firefox browser
    - COMMAND: `Super + B`
    - SHORTCUT: `firefox`
  - Run Thunar file manager
    - COMMAND: `Super + F`
    - SHORTCUT: `thunar` 

- `Terminal -> Preferences`:
  - Split Terminal vertically 
    - SHORTCUT: `Ctrl + V` 
  - Split Terminal horizontally   
    - SHORTCUT: `Ctrl + H` 
  - Quit Terminal 
    - SHORTCUT: `Ctrl + Q` 
  - Close subTerminal (previously opened vertically/horizontally)   
    - SHORTCUT: `Ctrl + W` 

## Other features (to set)
- `Desktop settings -> Menu`: 
  - uncheck "Include applications menu on desktop right click"
  - uncheck "Show window list menu on desktop middle click"
- `Desktop settings -> Desktop icons`: 
  - Icon type -> None

## Useful commands (already set)
- `ip` instead of `ifconfig`
- `cls` instead of `clear`
- `ls` instead of `lsd -l` (lists files/dirs with nerd fonts)
- `lst` instead of `ls -tree` (prints files/dirs tree)
- `cat` instead of `batcat py` (prints file with highlighted lines)
- `off` instead of `poweroff`
- `settarget <IP>` (sets your target IP address on your Polybar)
- `extractPorts <file>` (extracts open ports from a grepable file and copies them on your clipboard)

## Screenshots
<img src="screenshots/rofi.png" alt="screenshotRofi">
<img src="screenshots/ls.png" alt="screenshotLs">
<img src="screenshots/lst.png" alt="screenshotLst">
<img src="screenshots/cat.png" alt="screenshotCat"><br>
<img src="screenshots/polybar.png" alt="screenshotPolybar">
<img src="screenshots/utilities.png" alt="screenshotUtilities">
