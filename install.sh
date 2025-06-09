#!/bin/bash

#Need to figure out:
#Dimmer and blue light filter - DONE
#Remote control/typing with phone app
#Auto-mapping LivingRoomPC and TaylorPC, plus TaylorNAS
#Makima
#Figure out backing up Gnome settings/extensions/themes/tweaks
#Dash shortcuts for YouTube, etc.
#Automatic upgrades for apt and flatpak

#Make it so user doesn't have to type password to use sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

#Install nala
sudo apt install nala -y

#Fetch mirrors and save 10 fastest
sudo nala fetch --fetches 10 --auto -y

#Perform update and upgrade
sudo nala update
sudo nala upgrade -y

packages=(
    gdm3
    gnome-shell
    gnome-terminal
    gnome-text-editor
    nautilus
    nautilus-extension-gnome-terminal
    ffmpegthumbnailer
    gnome-tweaks
    git
    flatpak
    preload
    evtest
)

#Install packages with Nala
for package in ${packages[@]}; do
    sudo nala install ${package} -y
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
sudo nala install software-properties-common apt-transport-https ca-certificates curl -y #Dependencies
curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo nala update
sudo nala install google-chrome-stable -y

#Install Firefox
sudo nala install wget -y
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
sudo nala update
sudo nala install firefox -y

#Enable Flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

#Install Bitwarden
flatpak install flathub com.bitwarden.desktop --noninteractive

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

#MAKIMA SETUP
#Download the repo
git clone https://github.com/cyber-sushi/makima ~/builds/makima

#Download latest Makima executable
curl -s https://api.github.com/repos/cyber-sushi/makima/releases/latest \
  | grep browser_download_url \
  | grep 'makima"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 -I {} sh -c 'curl -L -o ~/builds/makima/$(basename {}) {}'

#Make install script executable
chmod +x ~/builds/makima/install.sh

sudo ~/builds/makima/install.sh $USER

#Fix 8bitdo controller
echo 'ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310a", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c '\''echo 2dc8 310a > /sys/bus/usb/drivers/xpad/new_id'\''"' | sudo tee /etc/udev/rules.d/99-8bitdo-xinput.rules

#Reload udev
sudo udevadm control --reload

#Install Unified Remote
mkdir -p ~/builds/urserver
wget -O ~/builds/urserver/unified-remote.deb https://www.unifiedremote.com/download/linux-x64-deb
sudo nala install -y ~/builds/urserver/unified-remote.deb

#Copy the .config dot files (~/.config)
mkdir -p ~/.config/
cp -r ~/builds/htpcdots/config/* ~/.config/

#Copy the Unified Remote server custom remote
mkdir -p "~/.urserver/remotes/custom/HTPC Remote"
cp -r "~/builds/htpcdots/urserver/remotes/custom/HTPC Remote/*" "~/.urserver/remotes/custom/HTPC Remote"

#Remove ifupdown and configure NetworkManager for GNOME
sudo nala purge ifupdown -y
sudo sed -i '/^\[ifupdown\]/,/^\[/{s/^managed=.*/managed=true/}' /etc/NetworkManager/NetworkManager.conf
