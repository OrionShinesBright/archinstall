# Archlinux Installatiion Script
This script installs my install of archlinux to my hp elitebook 840 g7.

## Caution
All the figures are hardcoded. Might (will) break on other systems. Do not use unmodified.

## Instructions
1. Boot up the current monthly archiso.
2. Connect to the internet:
  - Ethernet: Plug it in.
  - Wifi: Run `iwctl station wlan0 connect WIFI_NAME` and then enter your password
3. Install git (`pacman -Sy archlinux-keyring git`)
4. `git clone https://github.com/OrionShinesBright/archinstall`
5. `cd archinstall`
6. `chmod +x install-1`
7. Carefully look through both install-1 and install-2 scripts. 1 runs before and after chroot, while 2 runs during it.
8. `./install-1`

## Best of luck
Upon rebooting (boot with the non-lts kernel), login, and enter `sway` to launch.
