#!/bin/bash

# Color Variables
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Script save path
SCRIPT_PATH="$HOME/gensyn-ai.sh"

# Function to install gensyn-ai node
function install_gensyn_ai_node() {
    # Update system
    sudo apt-get update && sudo apt-get upgrade -y

    # Install required packages
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano \
        automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev \
        libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev python3 python3-pip

    # Install Yarn
    echo "Installing Yarn..."
    curl -o- -L https://yarnpkg.com/install.sh | bash
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
    source ~/.bashrc
    echo "Yarn installation completed"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Docker not found, installing Docker..."
        # Install Docker
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        echo "Docker installation completed"
    else
        echo "Docker is already installed"
    fi

    # Clone GitHub repository and change directory
    git clone https://github.com/gensyn-ai/rl-swarm/ || {
        echo "Failed to clone repository"; 
        read -n 1 -s -r -p "Press any key to return to main menu...";
        main_menu;
        return;
    }
    cd rl-swarm || {
        echo "Failed to enter rl-swarm directory";
        read -n 1 -s -r -p "Press any key to return to main menu...";
        main_menu;
        return;
    }

    # Create and activate Python virtual environment
    python3 -m venv .venv
    source .venv/bin/activate

    # Install and run swarm in a screen session
    if ! command -v screen &> /dev/null; then
        sudo apt install -y screen
    fi
    screen -S swarm -d -m bash -c "./run_rl_swarm.sh"
    echo "Swarm has been started in a screen session. Use 'screen -r swarm' to access it."

    # Prompt to return to main menu
    read -n 1 -s -r -p "Press any key to return to main menu..."
    main_menu
}

# Function to view Rl Swarm logs
function view_rl_swarm_logs() {
    RL_SWARM_DIR="$HOME/rl-swarm"
    if [ -d "$RL_SWARM_DIR" ]; then
        cd "$RL_SWARM_DIR" && docker-compose logs -f swarm_node
    else
        echo "rl-swarm directory not found in $RL_SWARM_DIR"
    fi

    read -n 1 -s -r -p "Press any key to return to main menu..."
    main_menu
}

# Function to view Web UI logs
function view_web_ui_logs() {
    RL_SWARM_DIR="$HOME/rl-swarm"
    if [ -d "$RL_SWARM_DIR" ]; then
        cd "$RL_SWARM_DIR" && docker-compose logs -f fastapi
    else
        echo "rl-swarm directory not found in $RL_SWARM_DIR"
    fi

    read -n 1 -s -r -p "Press any key to return to main menu..."
    main_menu
}

# Function to view Telemetry logs
function view_telemetry_logs() {
    RL_SWARM_DIR="$HOME/rl-swarm"
    if [ -d "$RL_SWARM_DIR" ]; then
        cd "$RL_SWARM_DIR" && docker-compose logs -f otel-collector
    else
        echo "rl-swarm directory not found in $RL_SWARM_DIR"
    fi

    read -n 1 -s -r -p "Press any key to return to main menu..."
    main_menu
}

# Main menu function
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
        echo -e "${GREEN}            🚀 gensyn-ai Node Management 🚀${NC}"
        echo -e "${BLUE}=======================================================${NC}"
        echo -e "${CYAN}    🌐  Telegram: @CryptoAirdropHindi${NC}"
        echo -e "${CYAN}    📺  YouTube:  @CryptoAirdropHindi6${NC}"
        echo -e "${CYAN}    💻  GitHub:   github.com/CryptoAirdropHindi${NC}"
        echo -e "${BLUE}=======================================================${NC}"
        echo "To exit the script, press Ctrl + C"
        echo "Please select an option:"
        echo "1. Install gensyn-ai node"
        echo "2. View Rl Swarm logs"
        echo "3. View Web UI logs"
        echo "4. View Telemetry logs"
        echo "5. Exit"
        read -p "Enter your choice [1-5]: " choice
        case $choice in
            1)
                install_gensyn_ai_node
                ;;
            2)
                view_rl_swarm_logs
                ;;
            3)
                view_web_ui_logs
                ;;
            4)
                view_telemetry_logs
                ;;
            5)
                exit 0
                ;;
            *)
                echo "Invalid option, please try again..."
                sleep 2
                ;;
        esac
    done
}

# Run main menu
main_menu
