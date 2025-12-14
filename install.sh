read -p "Enter new computer hostname: " NEWHOSTNAME

#Prompt for SMB credentials (used to copy Save Desktop backup file)
read -p "Enter SMB username: " SMB_USER
read -p "Enter SMB password: " SMB_PASS
echo

#Make it so user doesn't have to type password to use sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

#Set hostname
sudo hostnamectl set-hostname "$NEWHOSTNAME"

flatpakages=(
    io.github.vikdevelop.SaveDesktop
)

#Install flatpak packages
for package in ${flatpakages[@]}; do
    flatpak install flathub ${package} --noninteractive
done

#AntiMicroX
mkdir -p ~/AppImages
curl -s https://api.github.com/repos/AntiMicroX/antimicrox/releases/latest \
  | grep browser_download_url \
  | grep 'AntiMicroX-x86_64.AppImage"' \
  | cut -d '"' -f 4 \
  | xargs -n 1 -I {} sh -c 'curl -L -o ~/AppImages/AntiMicroX/AntiMicroX-x86_64.AppImage {}'

chmod +x ~/AppImages/AntiMicroX-x86_64.AppImage

#Fix AntiMicroX on Wayland
sudo wget -O /etc/udev/rules.d/60-antimicrox-uinput.rules https://raw.githubusercontent.com/AntiMicroX/antimicrox/master/other/60-antimicrox-uinput.rules

#Copy the KDE Save Desktop backup from the share to ~
smbclient "//192.168.0.63/TaylorNAS" -U "$SMB_USER%$SMB_PASS" \
  -c "cd GitHub/htpcdots; get KDEConfig.sd.zip $HOME/KDEConfig.sd.zip"

#Copy home dir
cp -r ~/htpcdots/home/* ~/

#Copy config dir
cp -r ~/htpcdots/config/* ~/.config/
chmod +x ~/.config/scripts/*
chmod +x ~/.config/autostart/*

#Copy antimicrox settings
mkdir -p ~/.config/antimicrox
cp ~/htpcdots/antimicroxsettings.gamecontroller.amgp ~/.config/antimicrox

#Copy wallpapers
mkdir -p "$HOME/Wallpapers"
#Copy the Wallpapers
smbclient "//192.168.0.63/TaylorNAS" -U "$SMB_USER%$SMB_PASS" \
  -c "cd Wallpapers; lcd $HOME/Wallpapers; prompt; mget *"

#Set grub timeout to 0
if command -v grub-mkconfig >/dev/null 2>&1; then
  sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

#Clear keyring
rm -rf "$HOME/.local/share/kwalletd"
rm -rf "$HOME/.local/share/keyrings"
rm -f  "$HOME/.config/kwalletrc"

#Copy system.yaml
sudo cp ~/htpcdots/system.yaml /
#System update
sudo akshara update

echo
echo -e "\e[32mDONE. You should reboot now.\e[0m"
