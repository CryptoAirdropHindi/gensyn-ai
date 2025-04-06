#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 8. CRYPTOLOSS ASCII art
echo " "
echo " "
echo " "
echo -e "    ${RED}██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗${NC}"
echo -e "    ${GREEN}██║  ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║${NC}"
echo -e "    ${BLUE}███████║███████║███████╗███████║██╔██╗ ██║${NC}"
echo -e "    ${YELLOW}██╔══██║██╔══██║╚════██║██╔══██║██║╚██╗██║${NC}"
echo -e "    ${MAGENTA}██║  ██║██║  ██║███████║██║  ██║██║ ╚████║${NC}"
echo -e "    ${CYAN}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
echo " "
echo " "
echo " "
echo " "

echo "📦 Updating server..."
sudo apt update && sudo apt install -y sudo

echo "🔧 Installing required packages..."
sudo apt update && sudo apt install -y \
  python3 python3-venv python3-pip curl wget screen git lsof
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

echo "🚀 Starting Gensyn script..."
curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash

echo "📁 Cloning repository..."
cd $HOME
[ -d rl-swarm ] && rm -rf rl-swarm
git clone https://github.com/zunxbt/rl-swarm.git
cd rl-swarm

echo "📦 Updating Yarn..."
cd modal-login
yarn install
yarn upgrade
yarn add next@latest
yarn add viem@latest

echo "🚀 Installing Node..."
cd $HOME/rl-swarm
screen -dmS gensyn bash -c "python3 -m venv .venv && . .venv/bin/activate && ./run_rl_swarm.sh"

echo -e "${GREEN}CC : CryptoAirdropHindi ${NC}"

echo "Process completed."

# 8. CryptoAirdropHindi ASCII art
echo " "
echo " "
echo " "
echo " "
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
echo -e "${GREEN}To run the node: ${NC}""${YELLOW}screen -r gensyn${NC}"
