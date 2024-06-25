#!/bin/bash

clear
echo "     DRACOVM INSTALLER (Modified DevBhai7's script)"
echo "-------------------------------------"
echo "1) Install Basic Packages"
echo "2) PufferPanel"
echo "3) PufferPanel & Ngrok"
echo "4) COMING SOON"
echo "-------------------------------------"
read -p "Select an option: " option

# Input validation
if ! [[ "$option" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid input. Please enter a number."
    exit 1
fi

if [ "$option" -eq 1 ]; then
    clear
    echo "Installing Basic Packages..."
    apt update && apt upgrade -y
    apt install git curl wget sudo lsof iputils-ping -y
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod +x /bin/systemctl
    echo "Basic Packages Installed!"

elif [ "$option" -eq 2 ] || [ "$option" -eq 3 ]; then
    clear
    echo "Installing PufferPanel..."
    apt update && apt upgrade -y
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y
    apt install curl wget git python3 -y
    curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash
    apt update && apt upgrade -y
    apt install pufferpanel
    echo "PufferPanel installation completed!"

    read -p "Enter PufferPanel Port: " pufferPanelPort
    sed -i "s/\"host\": \"0.0.0.0:8080\"/\"host\": \"0.0.0.0:$pufferPanelPort\"/g" /etc/pufferpanel/config.json

    read -p "Enter admin username: " adminUsername
    read -s -p "Enter admin password: " adminPassword
    read -p "Enter admin email: " adminEmail

    pufferpanel user add --name "$adminUsername" --password "$adminPassword" --email "$adminEmail" --admin
    echo "Admin user $adminUsername added successfully!"
    systemctl restart pufferpanel
    echo "PufferPanel Created & Started - PORT: $pufferPanelPort"

    if [ "$option" -eq 3 ]; then
        echo "Installing Ngrok..."
        wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
        tar -xf ngrok-v3-stable-linux-amd64.tgz
        read -p "Enter Ngrok Auth Token: " NgrokAuthToken
        ./ngrok config add-authtoken "$NgrokAuthToken"

        read -p "Tunnel Ngrok port manually? (yes/no): " install_choice
        if [ "$install_choice" == "yes" ]; then
            echo "Please setup Ngrok tunnel manually."
            exit 0
        else
            read -p "Enter port to tunnel: " port
            echo "Starting Ngrok tunnel on port $port..."
            ./ngrok http "$port" &
            sleep 5
            ngrok_url=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')
            echo "Ngrok started! Access tunnel at: $ngrok_url"
        fi
    fi
else
    echo "Invalid option selected."
    exit 1
fi
