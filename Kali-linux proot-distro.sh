#!/bin/bash

###############################################################################
# setup_debian_with_kali.sh
# A script to set up a Debian environment in Termux, replace its repositories
# with Kali Linux rolling repositories, and install necessary tools.
#
# Copyright © 2024 Aymen Gharsalli, Luxtrust
# This script is provided "as is," without warranty of any kind.
###############################################################################

# Colors for output
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

# Step 1: Update and upgrade Termux packages
echo -e "${CYAN}[*] Updating and upgrading Termux packages...${RESET}"
pkg update -y && pkg upgrade -y

# Step 2: Install necessary Termux repositories and packages
echo -e "${CYAN}[*] Installing Termux repositories...${RESET}"
pkg install -y root-repo x11-repo unstable-repo termux-x11-nightly

echo -e "${CYAN}[*] Installing necessary packages...${RESET}"
pkg install -y git wget tar proot nano curl axel python php tsu busybox pulseaudio mesa proot-distro

# Step 3: Install Debian using proot-distro
echo -e "${CYAN}[*] Installing Debian with proot-distro...${RESET}"
proot-distro install debian

# Step 4: Log into Debian, replace sources.list with Kali repositories, add GPG key, and update/upgrade
echo -e "${CYAN}[*] Logging into Debian and setting up Kali repositories...${RESET}"
proot-distro login debian --shared-tmp --user root << 'EOF'
    echo -e "${YELLOW}[+] Updating and upgrading with Debian repositories...${RESET}"
    apt update -y && apt upgrade -y

    # Define the path to the sources.list file
    SOURCES_LIST="/etc/apt/sources.list"

    # Remove any existing content in the sources.list file
    echo -e "${YELLOW}[+] Removing existing Debian repositories...${RESET}"
    echo "" > $SOURCES_LIST

    # Add Kali rolling repositories
    echo -e "${YELLOW}[+] Adding Kali rolling repositories...${RESET}"
    cat <<EOL > $SOURCES_LIST
# Kali Linux rolling repositories
deb http://http.kali.org/kali kali-rolling main non-free contrib

# For source packages (uncomment if needed)
# deb-src http://http.kali.org/kali kali-rolling main non-free contrib
EOL

    echo -e "${GREEN}[+] Kali rolling repositories have been added successfully!${RESET}"

    # Download and add the Kali Linux GPG key to fix the verification issues
    echo -e "${YELLOW}[+] Adding the Kali Linux GPG key...${RESET}"
    curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor | tee /usr/share/keyrings/kali-archive-keyring.gpg > /dev/null

    # Update and upgrade the system with the new repositories
    echo -e "${YELLOW}[+] Updating and upgrading with Kali repositories...${RESET}"
    apt update -y && apt upgrade -y

    echo -e "${GREEN}[+] Kali setup completed!${RESET}"
EOF

# Script completion message
echo -e "${GREEN}[*] Script completed successfully!${RESET}"
echo -e "${CYAN}Created by Aymen Gharsalli, Luxtrust${RESET}"

