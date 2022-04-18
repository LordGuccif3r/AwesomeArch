#!/usr/bin/env bash

BOOT_SIZE=512M  #Boot Partition SIZE
SWAP_SIZE=4G    #Swap Partition SIZE
ROOT_SIZE=75G   #Root Partition SIZE

HOSTNAME="Arch"
PARTITION=/dev/sda
PARTITION_DEVICE="${PARTITION}1"
PARTITION_ROOT_DEVICE="${PARTITION}2"
PARTITION_SWAP_DEVICE="${PARTITION}3"
TIME_ZONE="America/New_York"
FILESYSTEM=ext4
BASE_SYSTEM=( base base-devel neofetch linux linux-headers linux-firmware grub nano vim wpa_supplicant )
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"

function banner(){
	clear
	echo -e "${yellow}"

    echo "     ............,,'...............'..................."
    echo "     ...........,oxdlc:;'........:cc,.................."
    echo "     ............coolc;;::,....'cc;...................."
    echo "     .............,,,,,'';c,.';c:'....................."
    echo "     .....................',.;lc,;cll'................."
    echo "     ........................',,:oooc.................."
    echo "     ...........',,;;;;;,'........',..'.,ldl:,........."
    echo "     ........';:ccclllloool:,......','...:k00Odc'......"
    echo "     .......;:ccclllloooddxxxdlc'...'.....,lkOOkd;....."
    echo "     .......'',;:cloodddxxkkO000kocclccc:lodkOkkkd;...."
    echo "     ..............';:coxkO0KKKXXXKK0kdddxkOkkkxxxl'..."
    echo "     ...................',:ldkOO00K000OOOOkkkxxxxdd:..."
    echo "     ....,;;,,,'................,;:cloddxxxxxxdddol:..."
    echo "     ...'coooodddolc:;,..................'',,,,,'......"
    echo "     ...'looddxxkkO00K0Oxoc;,.........................."
    echo "     ...'lddxxkkO00KXXXKKK00Oxxdlc:;,'................."
    echo "     ....,;;:cloxk0KXKKK000OOOOOkkkxxdolcc:;;;;;;;;'..."
    echo "     .............,;cloxkOOOOkkkkxxxxddddooooollllc'..."
    echo "     .....';;;'.........',;cloddxxxddddoooollllllc,...."
    echo "     .....'xKK0kdoc;'...........,;:cllooolllllllc,....."
    echo "     ......,xKKK000Okdl:,'............',,;;;::;;,......"
    echo "     .......'o000OOOOkkkxdoc:,,'......................."
    echo "     .........cxOOOkkkxxxxddddoolc:;,'................."
    echo "     ..........'cdkkxxxxddddooooolllllcc::;'..........."
    echo "     ............';lodddolc:;;;::ccllcc:;'............."
    echo "     ................',,'..........'''................."
    echo "     .................................................."
    echo ""
    sleep 2
    echo -e "${end}"
    echo -e "${red}"

    echo "   Automatic Installation of Arch Linux by Lord Guccif3r"
    sleep 5
    echo -e "${end}"
}

function banner2(){
    sleep 3
	echo -e "${green}"

    echo "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
    echo "████ ████▀▄▄▀█ ▄▄▀█ ▄▀████ ▄▄ █ ██ █▀▄▀█▀▄▀██▄██ ▄▄█ ▄▄ █ ▄▄▀██"
    echo "████ ████ ██ █ ▀▀▄█ █ ████ █▀▀█ ██ █ █▀█ █▀██ ▄█ ▄████▄▀█ ▀▀▄██"
    echo "████ ▀▀ ██▄▄██▄█▄▄█▄▄█████ ▀▀▄██▄▄▄██▄███▄██▄▄▄█▄███ ▀▀ █▄█▄▄██"
    echo "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
    sleep 7
    echo -e "${end}"
}

function VERIFY_BOOT_MODE(){
    [[ -d /sys/firmware/efi/efivars ]] && return 0
    return 1
}

function INTERNET_CHECK(){
    clear
    echo -e "${green}"
    echo "Testing internet connection..."
    $(ping -c 3 google.com &>/dev/null) || (echo "Not Connected to Network!!!" && exit 1)
    echo -e "${green}"
    echo "Good!  We're connected!!!" && sleep 3
    echo -e "${end}"
}

function DATE_CHECK(){
    timedatectl set-ntp true
    echo -e "${green}"
    echo && echo "Date/Time service Status is . . . "
    timedatectl status
    sleep 4
    echo -e "${end}"
}

function SFDISK(){
    cat > /tmp/sfdisk.cmd << EOF
        $PARTITION_DEVICE : start= 2048, size=+$BOOT_SIZE, type=83, bootable
        $PARTITION_ROOT_DEVICE : size=+$ROOT_SIZE, type=83
        $PARTITION_SWAP_DEVICE : size=+$SWAP_SIZE, type=82
        #$HOME_DEVICE : type=83
EOF
        sfdisk "$PARTITION" < /tmp/sfdisk.cmd 
}

function FORMAT_PARTITIONS(){
    mkfs.ext4 "$PARTITION_DEVICE"         # /boot
    mkfs.ext4 "$PARTITION_ROOT_DEVICE"    # /
    mkswap "$PARTITION_SWAP_DEVICE"       # swap partition

}

function MOUNT_FILESYSTEM(){
    mount "$PARTITION_ROOT_DEVICE" /mnt
    mkdir /mnt/boot && mount "$PARTITION_DEVICE" /mnt/boot
    swapon "$PARTITION_SWAP_DEVICE"
    lsblk && echo -e "${green}" "Here're your new block devices."
    sleep 3
    echo -e "${end}"
}

function INSTALL_BASE_SYSTEM(){
    pacstrap /mnt "${BASE_SYSTEM[@]}"

}

function GENERATE_FSTAB(){
    echo -e "${green}"
    echo "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
    cat /mnt/etc/fstab
    echo -e "${end}"
}

function SETUP_TIME(){
    clear
    echo -e "${green}"
    echo && echo "setting timezone to $TIME_ZONE..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime
    arch-chroot /mnt hwclock --systohc --utc
    arch-chroot /mnt date
    echo -e "${green}"
    echo && echo "Here's the date info"
    sleep 3
    echo -e "${end}"
}

function SETUP_HOSTNAME(){
    clear
    echo -e "${green}"
    echo && echo "Setting hostname..."; sleep 3
    echo "$HOSTNAME" > /mnt/etc/hostname
    cat > /mnt/etc/hosts << EOF
    127.0.0.1      localhost
    ::1            localhost
    127.0.1.1      $HOSTNAME.localdomain     $HOSTNAME
EOF
    echo -e "${green}"
    echo && echo "/etc/hostname and /etc/hosts files configured..."
    echo "/etc/hostname . . . "
    cat /mnt/etc/hostname 
    echo "/etc/hosts . . ."
    cat /mnt/etc/hosts
    echo && echo "Here are /etc/hostname and /etc/hosts."
    sleep 3
    echo -e "${end}"
}

function SET_ROOT_PASSWD(){
    clear
    echo -e "${green}"
    echo "Setting ROOT password..."
    arch-chroot /mnt passwd 
    echo -e "${end}"
}

function INSTALL_ESSENTIALS(){
    clear
    echo -e "${green}"
    echo && echo "Enabling dhcpcd, sshd and NetworkManager services..." && echo
    echo -e "${end}"
    sleep 3
    arch-chroot /mnt pacman -S git openssh networkmanager dhcpcd man-db xterm man-pages xterm curl xorg xorg-server gnome kitty gtkmm open-vm-tools xf86-video-vmware xf86-input-vmmouse firefox wget p7zip --noconfirm
    arch-chroot /mnt systemctl enable dhcpcd.service
    arch-chroot /mnt systemctl enable sshd.service
    arch-chroot /mnt systemctl enable NetworkManager.service
    arch-chroot /mnt systemctl enable systemd-homed
    arch-chroot /mnt systemctl enable wpa_supplicant
    arch-chroot /mnt systemctl enable gdm.service
    arch-chroot /mnt systemctl enable vmtoolsd
    sleep 3
}

function ADD_USER(){
    clear
    echo -e "${green}"
    echo && echo "Adding sudo + user acct..."
    sleep 2
    echo && echo "Password for root $Root_user?"
    arch-chroot /mnt passwd root "$Root_user"
    arch-chroot /mnt pacman -S sudo bash-completion sshpass --noconfirm
    arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers
    arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) ALL/# %wheel ALL=(ALL) ALL/g' /etc/sudoers
    echo && echo "Please provide a username: "; read sudo_user
    echo && echo "Creating $sudo_user and adding $sudo_user to sudoers..."
    arch-chroot /mnt useradd -m -G wheel "$sudo_user"
    echo && echo "Password for $sudo_user?"
    arch-chroot /mnt passwd "$sudo_user"
    echo -e "${end}"
}


function GENERATE_LOCALE(){
    arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/g' /etc/locale.gen
    arch-chroot /mnt locale-gen
    
}

function INSTALL_GRUB(){
    clear
    echo -e "${green}"
    echo "Installing grub..." && sleep 4
    arch-chroot /mnt pacman -S grub os-prober --noconfirm
    arch-chroot /mnt grub-install "$PARTITION"
    echo "configuring /boot/grub/grub.cfg..."
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    [[ "$?" -eq 0 ]] && echo "mbr bootloader installed..."
    echo -e "${end}"

}

function AUTOAWESOME(){

    sudo cp AutoAwesome/launchautoawesome /mnt/usr/bin/
    sudo cp AutoAwesome/autoawesome /mnt/usr/bin/
    sudo chmod 777 /mnt/usr/bin/launchautoawesome
    sudo chmod 777 /mnt/usr/bin/autoawesome
    mkdir -p /mnt/home/guccif3r/.local/share/applications/
    sudo cp AutoAwesome/autoawesome.desktop /mnt/home/$sudo_user/.local/share/applications/
    chmod 777 /mnt/home/$sudo_user/.local/share/applications/autoawesome.desktop
    sudo cp AutoAwesome/autoawesome.svg /mnt/usr/share/icons/hicolor/scalable/apps/
}

function LA_SILLA_PA_CUANDO(){
	clear
	echo -e "${blue}"
    cat <<EOF
                                                                                                                                                          
                               #(##/(#(/###%                                
                              %#%@&(&&%#&&#%/                               
                               %@@&%@@&%&@&@                                
                             #&##&%#&&&%%&#%&/                              
                          (###((###(%&%(#%#(##%#%                           
                          (####(####(#%/(##(####%                           
                           #%##((#((#%%/(#(/#%%#                            
                           ##&%((##(##%(##((&&%                             
                      /(((# ##&((##(###(##(%&%( #(((                        
                       ,/@  #&&(###(##((##(%&&   %*                         
                         %%&#&&####(###(##(%&&(.%/                          
                         &%# %&(###(#%#(##(%&#,%#(                          
                         (%#%%#&#&#&%&%%%&%&%%&&&                           
                             / @@@@@@&@@@@@@#                               
                              .%&%%%&&&%%#%# ,                              
                                  /, , ,                                    
                                     .                                      
                                 //(*(#.#.*                                 
                        *,#(%&%(((( ##(*(,..#%((( .                         
                      %#  ..,.........*......,..   @&                       
                     .,*...,,,,,,,,,#&,,,,,,,,,...,**                       
                                                              
EOF

    echo -e "${yellow}"
    echo "Ahora toma asiento en la HERMAN MILLER mientras se isntalan las dependencias"
    echo -e "${end}"
    sleep 7
}

function Kernel_error(){
	echo -e "${red}"
    cat << EOF

                    MMMMMMMMMMMMWWWMWWMWWKkocccldkKWMMWWWWMWWWWWWWMMMM
                    MMMMMMMMMMMMWMWWWXkl;..      ..;lONWWWWWWWWWWWMMMM
                    MMMMMMMMMMMMWWWXd'                ,xNWWWWWWWWWMMMM
                    MMMMMMMMMMMMWWK:                    :KWWWWWWWWMMMM
                    MMMMMMMMMMMMMX:                      :XWWWWWWWMMMM
                    MMMMMMMMMMMMMk.                      .OWWWWWWWMMMM
                    MMMMMMMMMMMMMk.                      .OWWWWWWWMMMM
                    MMMMMMMMMMMWWK, '.                .. ;XWWWWWWWMMMM
                    MMMMMMMMMMMWWNo,l'                ,c,dNWWWWWWWWMMM
                    MMMMMMMMMMWWWNo'';clll;.    .:llcc;''dNWWWWWWWWMMM
                    MMMMMMMMMWWWW0'.kWWWWWNo.  .dNWWWWNx.,KWWWWWWWWMMM
                    MMMMMMMMWWWWWO'.xWWWX0x;   .:kKNWWNd.,0WWWWWWWWMMM
                    MMMMMMWXNWWWWx. .;:;'. .ckk:  .'::;. .kWWWWWWWWWMM
                    MMMWWKc.:0WWWNO:...    ,ddxd'    . .:0WWWW0xdxKWMM
                    MMMNO;   'lkKNWWK00d.   ....   .x0O0NWWWNd.  .dWWM
                    MMWk.       .,:ok0NXc.        .oNWWNKOxo;.    .dNM
                    MWW0c,'''...     .,:cccc;;;:ldxkxl:'.      ....cKW
                   MWWWWNNXXXXKOxdl:'.   .';cloc,.. ..,:cloxkO0000XWW
                    MWWWWWWWWWWWWWWWWKx:.           .:d0XNWWWWWWWWWWWW
                    MWWWWWWWWWWWN0koc,.  ..,cooc,.     ..;coxO00kx0NWW
                    WWN0dok00xl;'.  ..;ldOKNWWWWNXOdc;..      ..  .xWW
                    WWx.   ..   .;lxOXWWWWWWWWWWWWWWNNX0xo:,.     .oXW
                    WWKc      ,xKNWWWWWWWWWWWWWWWWWWWWWWWWNX0xc'.  .xW
                    MWWO,. .,dXWWWWWWWWWWWWWWWWWWWWWWWWMWWWWWWWXOdlxXW
                    MMMWKkxxKWWWWWMMMMWMMMMMMMMMMMMMMMMMWWMMMWWWWMMWWW
    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    ██ █▀▄█ ▄▄█ ▄▄▀█ ▄▄▀█ ▄▄█ █████ ▄▄ █ ▄▄▀█ ▄▄▀██▄██▀▄▀████ ▄▄▄█ ▄▄▀█ ▄▄▀█▀▄▄▀█ ▄▄▀██
    ██ ▄▀██ ▄▄█ ▀▀▄█ ██ █ ▄▄█ █████ ▀▀ █ ▀▀ █ ██ ██ ▄█ █▀████ ▄▄▄█ ▀▀▄█ ▀▀▄█ ██ █ ▀▀▄██
    ██ ██ █▄▄▄█▄█▄▄█▄██▄█▄▄▄█▄▄████ ████▄██▄█▄██▄█▄▄▄██▄█████ ▀▀▀█▄█▄▄█▄█▄▄██▄▄██▄█▄▄██
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
    
EOF
    echo -e "${end}"
}

function PRINT_KERNEL_PANIC(){
    clear
    Kernel_error
    sleep 1.2
    clear
    sleep 1
    Kernel_error
    sleep 1.2
    clear
    sleep 1
    Kernel_error
    sleep 1.2
    clear
    sleep 1
    Kernel_error
    sleep 1.2
}

function TROLL(){

	clear
	echo "                        ......''''''',,,;;:cclcc::;'.             "
	echo "                .,:clok000OOO00OOOOOO0000KKXXXWWMWNKk:.          "
	echo "                'lO00K000KKKKXXXXXXXKKKKK000KK000KKKWMMMNd.       "  
	echo "            ,xXMMWNXK00OO0XNWWMMMMNK0XNXXKK0kxkOOO0KNMMWx.        "
	echo "            cXMMMX0KXNNNNX0XWMMMMMWKKXWMMMMMWNK0OkkkOKWMMNo.       "
	echo "            .dWMMWKKWMMMMMMXKWMMMMMWXNMWN0OkxxO0NNNX0KWMMMMXl       "
	echo "            ,0MMMMWN0xddxOXXXWMMMMMMXxlc:c:.   .'cONMMMMMMMMXl.     "
	echo "        .ckXXXKXKl...   .:kXNWMMM0:,cdkkl.    ...dX00NMWXXNO:.    "
	echo "        :xkk0XXKXNOdoolc;'..,lKMMWk',cc::cooclxdolkX0OOxo::ok0kc.  "
	echo "        ,kOOOxoooxKWMWWMMWNd'oXWMMMWKxoxKNMMXl,lOK0Odlcllloo:;oX0o' "
	echo "        :0KK0dlll:':llkWMMNd,kMMMMMMMMMMMMMMMNkl:::clxKXx:OMWk;dK0x."
	echo "        ,OKKNMMOoOxloxXWXx::dXMMMMMNkolok0NWWWWMWNWWNKdc'.;kKXc:KNK;"
	echo "        .:OKXWK;'OMMMWXd, ;KMMMMWKOxddxc'oKXXXNWN0xlccoOk,.;lx:cXWK;"
	echo "        .l0KXo. ;0WWXKkd:,oXWNWXdcclxOl;ONXOdl:;,.,ONWKc.oNNklOXKd."
	echo "        ,0NK; ...ckKWMMNkc:cdXMWNX0xl;,;;;:cok0x':kd:..;KMMX0KOl. "
	echo "        oW0' ,:'::,;loodo:;clc:;;;;;::.;0WWN0o' .,c;.lXMMMWKo'   "
	echo "        ;X0' ,;,00,;xdo:.'lod;'dKXNWWNl'll;'....c0d,oNMMMMWx.    "
	echo "        ,K0,    ,,.;dkOo':kkk:'dOkdol:.  .':d0k;:c,dNMMMMWd.     "
	echo "        ,KX;                        .';.,ONWMM0,.,OWMMMMNd.      "
	echo "        ;KWo..              ....;dkOKNWd,kMW0o,,dXMMMMMNo.       "
	echo "        :XM0,..;:.cc.,dd;.o00Xx;kMMMMMMK:,l:,:xXWMMMMWK:         "
	echo "        lWMWk,.,:.,k:,OWk,dWMMk,dXXK0kdc,':dOKXXNNXNKo.          "
	echo "        .dWMMWXkl:,','.'c;.'cll;.,:::ccldOK0000O0K0xc.            "
	echo "        .kMNNMWXNWNXK0kdodoooodkO0KXNNNX0Okxk00kdl,.              "
	echo "        .OMX0NWX000KKXKKKKK0000KKKK0OkxxxO0Oko:'                  "
	echo "        .OMWK00KXK0000000000OOOOOOO00KXXKkl,.                     "
	echo "        .lNMMWXKKKKXXXNNNXXXXNNNNWMWWXkl'                         "
	echo "            :OWMMMMMMMMMMMMMMWN0koccc;,.                           " 
	echo "            .;dOKXNWNNXK0kdl;..                                    "
	echo "                ..;:cc:;'.                                          "
    echo -e "${green}"
	echo "LOL Just kidding... Your system was installed successfully"
    sleep 3
	echo "               Restarting in 5 seconds"
    sleep 5
    reboot
    echo -e "${end}"
}

function main(){
    banner
    banner2
    VERIFY_BOOT_MODE
    INTERNET_CHECK
    LA_SILLA_PA_CUANDO
    DATE_CHECK
    SFDISK
    FORMAT_PARTITIONS
    MOUNT_FILESYSTEM
    INSTALL_BASE_SYSTEM
    GENERATE_FSTAB
    SETUP_TIME
    SETUP_HOSTNAME
    SET_ROOT_PASSWD
    INSTALL_ESSENTIALS
    ADD_USER
    GENERATE_LOCALE
    INSTALL_GRUB
    AUTOAWESOME
    PRINT_KERNEL_PANIC
    TROLL
}

main
