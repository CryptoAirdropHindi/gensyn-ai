#!/bin/bash

# Set version number
current_version=20250402001


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color


# Program name
PROGRAMNAME="gensyn"

update_script() {
    # Specify URL
    update_url="https://raw.githubusercontent.com/breaddog100/$PROGRAMNAME/main/$PROGRAMNAME.sh"
    file_name=$(basename "$update_url")

    # Download script file
    tmp=$(date +%s)
    timeout 10s curl -s -o "$HOME/$tmp" -H "Cache-Control: no-cache" "$update_url?$tmp"
    exit_code=$?
    if [[ $exit_code -eq 124 ]]; then
        echo "Command timed out"
        return 1
    elif [[ $exit_code -ne 0 ]]; then
        echo "Download failed"
        return 1
    fi

    # Check if new version is available
    latest_version=$(grep -oP 'current_version=([0-9]+)' $HOME/$tmp | sed -n 's/.*=//p')

    if [[ "$latest_version" -gt "$current_version" ]]; then
        clear
        echo ""
        # Prompt for script update
        printf "\033[31mNew script version available! Current version: %s, Latest version: %s\033[0m\n" "$current_version" "$latest_version"
        echo "Updating..."
        sleep 3
        mv $HOME/$tmp $HOME/$file_name
        chmod +x $HOME/$file_name
        exec "$HOME/$file_name"
    else
        # Script is up to date
        rm -f $tmp
    fi
}

# Node installation
function install_node() {
    # Define target swap size (in GB)
    TARGET_SWAP_GB=32

    # Get current swap size (in KB)
    CURRENT_SWAP_KB=$(free -k | awk '/Swap:/ {print $2}')

    # Convert to GB
    CURRENT_SWAP_GB=$((CURRENT_SWAP_KB / 1024 / 1024))

    echo "Current Swap size: ${CURRENT_SWAP_GB}GB"

    if [ "$CURRENT_SWAP_GB" -lt "$TARGET_SWAP_GB" ]; then
        # Temporarily disable all swap
        swapoff -a

        # Remove all swap partitions (if any)
        sed -i '/swap/d' /etc/fstab

        # Create new swap file
        SWAPFILE=/swapfile
        fallocate -l ${TARGET_SWAP_GB}G $SWAPFILE
        chmod 600 $SWAPFILE
        mkswap $SWAPFILE
        swapon $SWAPFILE

        # Add to fstab
        echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab

        # Adjust swappiness parameter (optional)
        echo "vm.swappiness = 10" >> /etc/sysctl.conf
        sysctl -p

        echo "Swap adjusted to ${TARGET_SWAP_GB}GB"
    fi

    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
    # Remove old Docker installations
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

    # Add Docker repository
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo usermod -aG docker $USER
    sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update
    sudo apt install python3.10 python3.10-venv python3.10-dev -y
    sudo apt install python-is-python3
    python --version
    sudo apt-get update
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install nodejs -y
    node -v
    sudo npm install -g yarn
    yarn -v
    curl -o- -L https://yarnpkg.com/install.sh | bash
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
    source ~/.bashrc

    git clone https://github.com/gensyn-ai/rl-swarm/
    cd rl-swarm
    python -m venv .venv
    source .venv/bin/activate

    PROJECT_DIR=$(pwd)

    sudo tee /etc/systemd/system/$PROGRAMNAME.service << EOF
[Unit]
Description=RL Swarm Service
After=network.target
Wants=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'source $PROJECT_DIR/.venv/bin/activate && ./run_rl_swarm.sh'
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=pop-node
WorkingDirectory=$PROJECT_DIR

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $PROGRAMNAME
    sudo systemctl start $PROGRAMNAME
    echo "Deployment completed..."
}

# View logs
function view_logs(){
    sudo journalctl -u $PROGRAMNAME.service -f --no-hostname -o short-iso
}

# View status
function view_status(){
    sudo systemctl status $PROGRAMNAME
}

# Start node
function start_node(){
    sudo systemctl start $PROGRAMNAME
    echo "$PROGRAMNAME node started"
}

# Stop node
function stop_node(){
    sudo systemctl stop $PROGRAMNAME
    echo "$PROGRAMNAME node stopped"
}

# Uninstall node
function uninstall_node(){
    echo "Are you sure you want to uninstall the $PROGRAMNAME node program? This will delete all related data. [Y/N]"
    read -r -p "Please confirm: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "Starting uninstallation..."
            stop_node
            rm -rf $PROJECT_DIR
            sudo rm -f /etc/systemd/system/$PROGRAMNAME.service
            sudo systemctl daemon-reload
            echo "Uninstallation completed."
            ;;
        *)
            echo "Uninstallation canceled."
            ;;
    esac
}

# Main menu
function main_menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        echo -e "    ${RED}██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗${NC}"
        echo -e "    ${GREEN}██║  ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║${NC}"
        echo -e "    ${BLUE}███████║███████║███████╗███████║██╔██╗ ██║${NC}"
        echo -e "    ${YELLOW}██╔══██║██╔══██║╚════██║██╔══██║██║╚██╗██║${NC}"
        echo -e "    ${MAGENTA}██║  ██║██║  ██║███████║██║  ██║██║ ╚████║${NC}"
        echo -e "    ${CYAN}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
        echo -e "${BLUE}=======================================================${NC}"
        echo -e "${GREEN} 🚀 gensyn-ai Node Management One-Click Setup Script 🚀 ${NC}"
        echo -e "${BLUE}=======================================================${NC}"
        echo -e "${CYAN}    🌐  Telegram: @CryptoAirdropHindi${NC}"
        echo -e "${CYAN}    📺  YouTube:  @CryptoAirdropHindi6${NC}"
        echo -e "${CYAN}    💻  GitHub:   github.com/CryptoAirdropHindi${NC}"
        echo -e "${BLUE}=======================================================${NC}"
        echo "Please select an operation:"
        echo "1. Deploy node install_node"
        echo "2. View status view_status"
        echo "3. View logs view_logs"
        echo "4. Stop node stop_node"
        echo "5. Start node start_node"
        echo "6. Uninstall node uninstall_node"
        echo "0. Exit script exit"
        read -p "Enter option: " OPTION
    
        case $OPTION in
        1) install_node ;;
        2) view_status ;;
        3) view_logs ;;
        4) stop_node ;;
        5) start_node ;;
        6) uninstall_node ;;
        0) echo "Exiting script."; exit 0 ;;
        *) echo "Invalid option, please try again."; sleep 3 ;;
        esac
        echo "Press any key to return to main menu..."
        read -n 1
    done
}

# Check for updates
update_script

# Show main menu
main_menu
