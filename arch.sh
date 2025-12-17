#!/bin/bash

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NOCOLOR='\033[0m'

# Function to print error and exit
error_exit() {
    echo -e "\n${RED}ERROR: $1${NOCOLOR}\n" >&2
    exit 1
}

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    error_exit "This script is designed for Arch Linux only. Detected system is not Arch Linux."
fi

# Check for network connectivity
echo -e "${BLUE}Checking network connectivity...${NOCOLOR}"
if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
    error_exit "No network connectivity detected. Please check your internet connection."
fi

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    error_exit "yay (AUR helper) is not installed. Please run 'shuttle.sh' first to set up your system, then run this script again."
fi

AUR_HELPER="yay"
echo -e "${GREEN}✓ Found AUR helper: ${AUR_HELPER}${NOCOLOR}\n"

# Kernel headers
echo
read -p "$(echo -e '\n\e[32mDo you want to install kernel headers?\n\n\e[33m(Automatically detects appropriate headers package for installed kernels: linux, linux-zen, linux-lts, linux-hardened)\n\n\e[31mNOTE: Kernel headers are necessary for nvidia-dkms!\n\n\e[35mEnter your choice (Y/n):\e[0m ') " install_headers < /dev/tty
install_headers=${install_headers:-Y}

if [[ $install_headers =~ ^[Yy]$ ]]; then
    echo -e "\n\e[32mInstalling kernel headers...\e[0m\n"
    
    HEADERS_INSTALLED=false
    
    if pacman -Q linux &> /dev/null; then
        sudo pacman -S --needed --noconfirm linux-headers
        HEADERS_INSTALLED=true
    fi
    
    if pacman -Q linux-zen &> /dev/null; then
        sudo pacman -S --needed --noconfirm linux-zen-headers
        HEADERS_INSTALLED=true
    fi
    
    if pacman -Q linux-lts &> /dev/null; then
        sudo pacman -S --needed --noconfirm linux-lts-headers
        HEADERS_INSTALLED=true
    fi
    
    if pacman -Q linux-hardened &> /dev/null; then
        sudo pacman -S --needed --noconfirm linux-hardened-headers
        HEADERS_INSTALLED=true
    fi
    
    if [ "$HEADERS_INSTALLED" = false ]; then
        echo -e "\e[33mWarning: No standard kernel found. Skipping headers installation.\e[0m"
    fi
fi

# GPU drivers
echo
echo -e "\n\e[32mWhich type of GPU do you have?\e[0m\n"
echo -e "1) \e[36mNVIDIA\e[0m\n(Choose between open-source and proprietary drivers in the next step)\n\e[0m"
echo -e "2) \e[36mAMD\n\e[33m(${AUR_HELPER} -S --needed --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader)\n\e[0m"
echo -e "3) \e[36mIntel\n\e[33m(${AUR_HELPER} -S --needed --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader)\n\e[0m"
echo -e "4) \e[36mSkip GPU driver installation\e[0m\n"
read -p "$(echo -e '\e[35mEnter your choice (1-4):\e[0m ') " gpu_choice < /dev/tty

if [[ ! "$gpu_choice" =~ ^[1-4]$ ]]; then
    echo -e "\n\e[33mInvalid choice. Skipping GPU driver installation.\e[0m\n"
    gpu_choice=4
fi

case $gpu_choice in
    1)
        # Check if kernel headers are installed for NVIDIA DKMS
        if [ "$install_headers" != "Y" ] && [ "$install_headers" != "y" ]; then
            echo -e "\n\e[31mWARNING: NVIDIA DKMS drivers require kernel headers!\e[0m"
            read -p "$(echo -e '\e[33mDo you want to install kernel headers now? (Y/n):\e[0m ') " install_headers_now < /dev/tty
            install_headers_now=${install_headers_now:-Y}
            
            if [[ $install_headers_now =~ ^[Yy]$ ]]; then
                echo -e "\n\e[32mInstalling kernel headers...\e[0m\n"
                
                if pacman -Q linux &> /dev/null; then
                    sudo pacman -S --needed --noconfirm linux-headers
                fi
                if pacman -Q linux-zen &> /dev/null; then
                    sudo pacman -S --needed --noconfirm linux-zen-headers
                fi
                if pacman -Q linux-lts &> /dev/null; then
                    sudo pacman -S --needed --noconfirm linux-lts-headers
                fi
                if pacman -Q linux-hardened &> /dev/null; then
                    sudo pacman -S --needed --noconfirm linux-hardened-headers
                fi
            else
                echo -e "\n\e[31mSkipping NVIDIA driver installation due to missing kernel headers.\e[0m\n"
                gpu_choice=4
            fi
        fi
        
        if [ "$gpu_choice" != "4" ]; then
            echo
            echo -e "\n\e[32mWhich NVIDIA GPU series do you have?\e[0m\n"
            echo -e "1) \e[36mGeForce 16 series and newer\n\e[33m(${AUR_HELPER} -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader)\n\e[0m"
            echo -e "2) \e[36mGeForce 10 series and older\n\e[33m(${AUR_HELPER} -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader)\n\e[0m"
            read -p "$(echo -e '\e[35mEnter your choice (1 or 2):\e[0m ') " nvidia_choice < /dev/tty
            
            if [[ ! "$nvidia_choice" =~ ^[1-2]$ ]]; then
                echo -e "\n\e[33mInvalid choice. Skipping NVIDIA driver installation.\e[0m\n"
            else
                # Check if multilib is enabled (needed for 32-bit libs)
                if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
                    echo -e "\n\e[32mEnabling multilib repository for 32-bit GPU libraries...\e[0m\n"
                    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
                    sudo pacman -Sy
                fi
                
                case $nvidia_choice in
                    1)
                        echo -e "\n\e[32mInstalling NVIDIA drivers (open-source)...\e[0m\n"
                        ${AUR_HELPER} -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
                        ;;
                    2)
                        echo -e "\n\e[32mInstalling NVIDIA drivers (proprietary)...\e[0m\n"
                        ${AUR_HELPER} -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
                        ;;
                esac
            fi
        fi
        ;;
    2)
        # Check if multilib is enabled (needed for 32-bit libs)
        if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
            echo -e "\n\e[32mEnabling multilib repository for 32-bit GPU libraries...\e[0m\n"
            sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
            sudo pacman -Sy
        fi
        
        echo -e "\n\e[32mInstalling AMD drivers...\e[0m\n"
        ${AUR_HELPER} -S --needed --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
        ;;
    3)
        # Check if multilib is enabled (needed for 32-bit libs)
        if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
            echo -e "\n\e[32mEnabling multilib repository for 32-bit GPU libraries...\e[0m\n"
            sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
            sudo pacman -Sy
        fi
        
        echo -e "\n\e[32mInstalling Intel drivers...\e[0m\n"
        ${AUR_HELPER} -S --needed --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
        ;;
esac

# Desktop packages
echo
read -p "$(echo -e '\e[32mDo you want to install desktop packages?\n\n\e[33m('${AUR_HELPER}' -S --needed --noconfirm cava celluloid inter-font font-manager kitty brave-bin firefox obs-studio openssh sassc socat ttf-jetbrains-mono-nerd visual-studio-code-bin wine-staging wine-mono winetricks flatpak steam ente-auth-bin bambustudio-bin discord obsidian libappindicator gnome-shell-extension-appindicator network-manager-applet proton-vpn-gtk-app)\n\n\e[35mEnter your choice (Y/n):\e[0m ') " install_desktop < /dev/tty
install_desktop=${install_desktop:-Y}

if [[ $install_desktop =~ ^[Yy]$ ]]; then
    DESKTOP_STEPS=3
    DESKTOP_CURRENT=0
    
    # Check if multilib is already enabled
    ((DESKTOP_CURRENT++))
    echo -e "\n\e[32m[$DESKTOP_CURRENT/$DESKTOP_STEPS] Enabling multilib repository...\e[0m\n"
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
        sudo pacman -Sy
    fi
    
    ((DESKTOP_CURRENT++))
    echo -e "\n\e[32m[$DESKTOP_CURRENT/$DESKTOP_STEPS] Updating package lists...\e[0m\n"
    ${AUR_HELPER} -Syu --noconfirm
    
    ((DESKTOP_CURRENT++))
    echo -e "\n\e[32m[$DESKTOP_CURRENT/$DESKTOP_STEPS] Installing desktop packages...\e[0m\n"
    ${AUR_HELPER} -S --needed --noconfirm cava celluloid inter-font font-manager kitty brave-bin firefox obs-studio openssh sassc socat ttf-jetbrains-mono-nerd visual-studio-code-bin wine-staging wine-mono winetricks flatpak steam ente-auth-bin bambustudio-bin discord obsidian libappindicator gnome-shell-extension-appindicator network-manager-applet proton-vpn-gtk-app
fi

# Tailscale
echo
read -p "$(echo -e '\e[32mDo you want to install tailscale?\n\n\e[35mEnter your choice (Y/n):\e[0m ') " install_tailscale < /dev/tty
install_tailscale=${install_tailscale:-Y}

if [[ $install_tailscale =~ ^[Yy]$ ]]; then
    echo -e "\n\e[32mInstalling Tailscale...\e[0m\n"
    if ! curl -fsSL https://tailscale.com/install.sh | sh; then
        echo -e "\e[31mError: Failed to install Tailscale\e[0m"
    fi
fi

# KVM/QEMU/Virt Manager
echo
read -p "$(echo -e '\e[32mDo you want to install KVM/QEMU/Virt Manager?\n\n\e[35mEnter your choice (Y/n):\e[0m ') " install_kvm < /dev/tty
install_kvm=${install_kvm:-Y}

if [[ $install_kvm =~ ^[Yy]$ ]]; then
    KVM_STEPS=7
    KVM_CURRENT=0
    
    ((KVM_CURRENT++))
    echo -e "\n\e[32m[$KVM_CURRENT/$KVM_STEPS] Installing KVM/QEMU packages...\e[0m\n"
    sudo pacman -S --needed --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode ebtables iptables libguestfs
    
    ((KVM_CURRENT++))
    echo -e "\n\e[32m[$KVM_CURRENT/$KVM_STEPS] Configuring libvirt for standard user accounts...\e[0m\n"
    
    # Configure UNIX domain socket group ownership
    if ! grep -q '^unix_sock_group = "libvirt"' /etc/libvirt/libvirtd.conf 2>/dev/null; then
        if grep -q '^#unix_sock_group' /etc/libvirt/libvirtd.conf 2>/dev/null; then
            sudo sed -i 's/^#unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
        else
            echo 'unix_sock_group = "libvirt"' | sudo tee -a /etc/libvirt/libvirtd.conf > /dev/null
        fi
    fi
    
    # Configure UNIX socket permissions
    if ! grep -q '^unix_sock_rw_perms = "0770"' /etc/libvirt/libvirtd.conf 2>/dev/null; then
        if grep -q '^#unix_sock_rw_perms' /etc/libvirt/libvirtd.conf 2>/dev/null; then
            sudo sed -i 's/^#unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
        else
            echo 'unix_sock_rw_perms = "0770"' | sudo tee -a /etc/libvirt/libvirtd.conf > /dev/null
        fi
    fi
    
    ((KVM_CURRENT++))
    echo -e "\n\e[32m[$KVM_CURRENT/$KVM_STEPS] Adding user to libvirt group...\e[0m\n"
    
    if ! groups | grep -q '\blibvirt\b'; then
        sudo usermod -a -G libvirt $(whoami)
        echo -e "\e[33mNote: You'll need to log out and back in for group membership to take effect\e[0m"
    fi
    
    ((KVM_CURRENT++))
    echo -e "\n\e[32m[$KVM_CURRENT/$KVM_STEPS] Enabling and restarting libvirtd service...\e[0m\n"
    sudo systemctl enable libvirtd.service
    sudo systemctl restart libvirtd.service
    
    ((KVM_CURRENT++))
    echo -e "\n\e[32m[$KVM_CURRENT/$KVM_STEPS] Detecting CPU vendor for nested virtualization...\e[0m\n"
    
    # Detect CPU vendor
    CPU_VENDOR=""
    KVM_MODULE=""
    
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        CPU_VENDOR="intel"
        KVM_MODULE="kvm_intel"
        echo -e "\e[33mDetected Intel processor\e[0m"
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        CPU_VENDOR="amd"
        KVM_MODULE="kvm_amd"
        echo -e "\e[33mDetected AMD processor\e[0m"
    else
        echo -e "\e[31mCould not detect CPU vendor, skipping nested virtualization setup\e[0m"
    fi
    
    if [ -n "$CPU_VENDOR" ]; then
        ((KVM_CURRENT++))
        echo -e "\n\e[32m[$KVM_CURRENT/$KVM_STEPS] Enabling nested virtualization for $CPU_VENDOR...\e[0m\n"
        
        # Check if module is loaded and reload with nested=1
        if lsmod | grep -q "^$KVM_MODULE"; then
            sudo modprobe -r $KVM_MODULE 2>/dev/null || true
        fi
        sudo modprobe $KVM_MODULE nested=1
        
        ((KVM_CURRENT++))
        echo -e "\n\e[32m[$KVM_CURRENT/$KVM_STEPS] Making nested virtualization persistent...\e[0m\n"
        
        # Make configuration persistent
        if [ ! -f /etc/modprobe.d/$KVM_MODULE.conf ] || ! grep -q "options $KVM_MODULE nested=1" /etc/modprobe.d/$KVM_MODULE.conf; then
            echo "options $KVM_MODULE nested=1" | sudo tee /etc/modprobe.d/$KVM_MODULE.conf > /dev/null
        fi
        
        # Verify nested virtualization is enabled
        if [ "$CPU_VENDOR" = "intel" ]; then
            NESTED_STATUS=$(cat /sys/module/kvm_intel/parameters/nested 2>/dev/null || echo "unknown")
        else
            NESTED_STATUS=$(cat /sys/module/kvm_amd/parameters/nested 2>/dev/null || echo "unknown")
        fi
        echo -e "\e[33mNested virtualization status: $NESTED_STATUS\e[0m"
    else
        echo -e "\e[33mSkipping nested virtualization steps (CPU vendor unknown)\e[0m"
    fi
fi

echo
echo -e "\n\e[32m=== Installation complete!\e[0m\n"

echo -e "\e[31m=== It is recommended to reboot your system to apply all changes\e[0m\n"