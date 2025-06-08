#!/bin/bash

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
)

#Install packages with Nala
for package in ${packages[@]}; do
    sudo nala install ${package} -y
done

#Enable GDM
sudo systemctl enable gdm
sudo systemctl set-default graphical.target

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

#Enable fractional scaling in GNOME
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

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

#Enable flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

#Install Bitwarden
flatpak install flathub com.bitwarden.desktop --noninteractive

#Copy the /etc files (/etc)
sudo cp -r ~/builds/htpcdots/etc/* /etc/

#Remove ifupdown and configure NetworkManager for GNOME
sudo nala purge ifupdown -y
