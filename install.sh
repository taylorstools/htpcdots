#!/bin/bash

#Need to figure out:
#Dimmer and blue light filter - DONE
#Remote control/typing with phone app - DONE
#Auto-mapping LivingRoomPC and TaylorPC, plus TaylorNAS - DONE
#Makima - DONE
#Figure out backing up Gnome settings/extensions/themes/tweaks
#Dash shortcuts for YouTube, etc.
#Automatic upgrades for apt and flatpak - DONE
#Download wallpapers from hyprlanddots - DONE
#Copy .icons from Git for mouse cursor - DONE

#Shortcuts for: Netflix, Terminal, Chrome, YouTube, JellyFin, Cozy, File Explorer

#Make it so user doesn't have to type password to use sudof
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

#Install nala
#sudo apt install nala -y

#Fetch mirrors and save 10 fastest
#sudo nala fetch --fetches 10 --auto -y

#Perform update and upgrade
sudo apt update
sudo apt upgrade -y

packages=(
    gdm3
    gnome-shell
    gnome-terminal
    gnome-text-editor
    nautilus
    nautilus-extension-gnome-terminal
    ffmpegthumbnailer
    gnome-tweaks
    vlc
    qbittorrent
    git
    flatpak
    preload
    evtest
    gpg
    unattended-upgrades
    wget
    software-properties-common
    apt-transport-https
    ca-certificates
    curl
)

#Install packages with apt
for package in ${packages[@]}; do
    sudo apt install ${package} -y
done

#Install Segoe UI font
git clone https://github.com/mrbvrz/segoe-ui-linux ~/builds/segoe-ui-linux
cd ~/builds/segoe-ui-linux
chmod +x install.sh
./install.sh

#Install Tela icons
git clone https://github.com/vinceliuice/Tela-icon-theme ~/builds/Tela-icon-theme
cd ~/builds/Tela-icon-theme
chmod +x install.sh
./install.sh grey

#Install Google Chrome
curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable -y

#Install Firefox
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
sudo apt update
sudo apt install firefox -y

#Enable Flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpakages=(
    com.bitwarden.desktop
    io.missioncenter.MissionCenter
    it.mijorus.gearlever
)

#Install flatpak packages
for package in ${flatpakages[@]}; do
    flatpak install flathub ${package} --noninteractive
done

#Fix cursor in flatpaks
flatpak --user override --filesystem=/home/$USER/.icons/:ro
flatpak --user override --filesystem=/usr/share/icons/:ro

#Copy the /etc files (/etc)
sudo cp -r ~/builds/htpcdots/etc/* /etc/

#Change GRUB_TIMEOUT to 0
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
#Set boot args
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 systemd.show_status=0 vt.global_cursor_default=0"/' /etc/default/grub

#Remove Plymouth
sudo apt purge plymouth

#Remove Debian GRUB background
sudo rm /usr/share/images/desktop-base/desktop-grub.png

#Update GRUB and initramfs
sudo update-grub
sudo update-initramfs -u

#GNOME SETUP
#Configure automatic login in GNOME
sudo sed -i 's/^#  AutomaticLoginEnable =.*/AutomaticLoginEnable = true/' /etc/gdm3/daemon.conf
sudo sed -i "s/^#  AutomaticLogin =.*/AutomaticLogin = $USER/" /etc/gdm3/daemon.conf
rm ~/.local/share/keyrings/login.keyring

#Enable GDM
sudo systemctl enable gdm
sudo systemctl set-default graphical.target

#Enable fractional scaling in GNOME
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

#Fastfetch
mkdir -p ~/builds/fastfetch
#Download latest Fastfetch .deb package
curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
  | grep browser_download_url \
  | grep 'fastfetch-linux-amd64.deb"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 -I {} sh -c 'curl -L -o ~/builds/fastfetch/$(basename {}) {}'

sudo apt install -y ~/builds/fastfetch/fastfetch-linux-amd64.deb

#Modify .bashrc
echo "alias cls='clear'" | tee -a ~/.bashrc
echo "fastfetch --logo-type small" | tee -a ~/.bashrc

#MAKIMA SETUP
#Download the repo
#git clone https://github.com/cyber-sushi/makima ~/builds/makima

#Download latest Makima executable
#curl -s https://api.github.com/repos/cyber-sushi/makima/releases/latest \
#  | grep browser_download_url \
#  | grep 'makima"' \
# | cut -d '"' -f 4 \
#  | xargs -n 1 -I {} sh -c 'curl -L -o ~/builds/makima/$(basename {}) {}'

#Make install script executable
#chmod +x ~/builds/makima/install.sh
#Install
#sudo ~/builds/makima/install.sh $USER

#Fix 8bitdo controller
#echo 'ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310a", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c '\''echo 2dc8 310a > /sys/bus/usb/drivers/xpad/new_id'\''"' | sudo tee /etc/udev/rules.d/99-8bitdo-xinput.rules

#Reload udev
#sudo udevadm control --reload

#Install Unified Remote
mkdir -p ~/builds/urserver
wget -O ~/builds/urserver/unified-remote.deb https://www.unifiedremote.com/download/linux-x64-deb
sudo apt install -y ~/builds/urserver/unified-remote.deb

#Copy the .config dot files (~/.config)
mkdir -p ~/.config/
cp -r ~/builds/htpcdots/config/* ~/.config/

#Copy the .icons dot files (~/.icons)
mkdir -p ~/.icons/
cp -r ~/builds/htpcdots/.icons/* ~/.icons/

#Copy the htpcsetup folder to home (~/htpcsetup)
mkdir -p ~/htpcsetup/
cp -r ~/builds/htpcdots/htpcsetup/* ~/htpcsetup/
#Make scripts executable
chmod +x ~/htpcsetup/scripts/*.sh

#Copy the Unified Remote server custom remote
mkdir -p ~/.urserver/remotes/custom/HTPCRemote
cp -r ~/builds/htpcdots/urserver/remotes/custom/HTPCRemote/* ~/.urserver/remotes/custom/HTPCRemote

#Install Jellyfin Media Player
mkdir -p ~/builds/jmp
version=$(curl --head https://github.com/jellyfin/jellyfin-media-player/releases/latest | tr -d '\r' | grep '^location' | sed 's/.*\/v//g')
wget "https://github.com/jellyfin/jellyfin-media-player/releases/download/v$version/jellyfin-media-player_$version-$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2).deb" -O ~/builds/jmp/jmp.deb
sudo apt install -y ~/builds/jmp/jmp.deb

#Copy the wallpapers
git clone https://github.com/taylorstools/hyprlanddots ~/builds/hyprlanddots
rm ~/builds/hyprlanddots/config/wallpapers/.current_lockscreen.png
rm ~/builds/hyprlanddots/config/wallpapers/.current_wallpaper
mkdir -p ~/htpcsetup/wallpapers
cp -r ~/builds/hyprlanddots/config/wallpapers/* ~/htpcsetup/wallpapers
rm -rf ~/builds/hyprlanddots

#Configure automatic updates
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

#Create systemd service to auto-update flatpaks
cat << 'EOF' | sudo tee /etc/systemd/system/flatpak-auto-update.service > /dev/null
[Unit]
Description=Auto update Flatpak apps

[Service]
Type=oneshot
ExecStart=~/htpcsetup/scripts/flatpakautoupdate.sh
EOF
#Create the systemd timer file
cat << 'EOF' | sudo tee /etc/systemd/system/flatpak-auto-update.timer > /dev/null
[Unit]
Description=Run Flatpak auto update daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF
#Reload systemd and start the timer
sudo systemctl daemon-reload
sudo systemctl enable flatpak-auto-update.timer

#Remove ifupdown and configure NetworkManager for GNOME
sudo apt purge ifupdown -y
sudo sed -i '/^\[ifupdown\]/,/^\[/{s/^managed=.*/managed=true/}' /etc/NetworkManager/NetworkManager.conf

#Remove unneeded packages
sudo apt autoremove -y

echo
echo DONE. You should reboot now.
