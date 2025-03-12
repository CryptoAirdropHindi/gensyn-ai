# Run RL Swarm Node
**RL Swarm** is a fully open-source framework developed by **GensynAI** for building reinforcement learning (RL) training swarms over the internet. This guide walks you through setting up an RL Swarm node and a web UI dashboard to monitor swarm activity.

## Hardware Requirements
- CPU: Minimum 16GB RAM (more RAM recommended for larger models or datasets).
- GPU (Optional): Supported CUDA devices for enhanced performance:
    - RTX 3090
    - RTX 4090
    - A100
    - H100
-  **Note**: You can run the node without a GPU using CPU-only mode (details in the docker-compose.yaml section).
---

## Install Dependencies
**1. Update System Packages**
```bash
sudo apt-get update && sudo apt-get upgrade -y
```
**2. Install General Utilities and Tools**
```bash
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
```

**3. Install Docker**
```bash
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
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test Docker
sudo docker run hello-world
```
* Tip: To run Docker without sudo, add your user to the Docker group:
```bash
sudo usermod -aG docker $USER
```

**4. Install Python**
```bash
sudo apt-get install python3 python3-pip
```

---

## Clone the Repository
```bash
git clone https://github.com/gensyn-ai/rl-swarm/
cd rl-swarm
```

---

## Create `docker-compose.yaml`
This file defines the services: the RL Swarm node, telemetry collector, and web UI.
1. Rename the old file:
```bash
mv docker-compose.yaml docker-compose.yaml.old
```
2. Create the new file:
```bash
nano docker-compose.yaml
```

3. Paste the following configuration:
```bash
version: '3'

services:
  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.120.0
    ports:
      - "4317:4317"  # OTLP gRPC
      - "4318:4318"  # OTLP HTTP
      - "55679:55679"  # Prometheus metrics (optional)
    environment:
      - OTEL_LOG_LEVEL=DEBUG

  swarm_node:
    image: europe-docker.pkg.dev/gensyn-public-b7d9/public/rl-swarm:v0.0.1
    command: ./run_hivemind_docker.sh
    runtime: nvidia  # Enables GPU support; remove if no GPU is available
    environment:
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - PEER_MULTI_ADDRS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
      - HOST_MULTI_ADDRS=/ip4/0.0.0.0/tcp/38331
    ports:
      - "38331:38331"  # Exposes the swarm node's P2P port
    depends_on:
      - otel-collector

  fastapi:
    build:
      context: .
      dockerfile: Dockerfile.webserver
    environment:
      - OTEL_SERVICE_NAME=rlswarm-fastapi
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - INITIAL_PEERS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
    ports:
      - "8080:8000"  # Maps port 8080 on the host to 8000 in the container
    depends_on:
      - otel-collector
      - swarm_node
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/healthz"]
      interval: 30s
      retries: 3
```
* **GPU/CPU Note**: If you don't have an NVIDIA GPU or the NVIDIA Container Runtime, remove the `runtime: nvidia` line under `swarm_node` to run on **CPU**.

### What Each Service Does:
* **otel-collector**: Gathers telemetry data (metrics, traces).
* **swarm_node**: The core RL Swarm node connecting to the network.
* **fastapi**: The web UI dashboard for monitoring.

---

## Run RL Swarm Node + Web UI Dashboard
Start the services with:
```bash
docker compose up --build -d && docker compose logs -f
```
* **Note**: The first run may take time due to image downloads. Look for this log to confirm your node joined the swarm

![Screenshot_654](https://github.com/user-attachments/assets/56243405-85ca-41ae-8591-2e61631835da)

* **Exit Logs**: Press `Ctrl+C`

---

## Check logs
* **RL Swarm node:**
```bash
docker-compose logs -f swarm_node
```

* **Web UI:**
```bash
docker-compose logs -f fastapi
```

* **Telemetry Collector:**
```bash
docker-compose logs -f otel-collector
```

* All Logs: Use `docker-compose logs -f` without a service name.

---

## Access the Web UI Dashboard
* VPS: `http://<your-vps-ip>:8080/`
* Local PC: `http://localhost:8080` or `http://0.0.0.0:8080`

![image](https://github.com/user-attachments/assets/5be7755d-bcc9-41d8-ae03-37816002e014)

## Monitoring Your Node
* The dashboard displays *collective swarm data*, not individual node stats. To track your node:

  1- Check the `swarm_node` logs for your node’s unique ID (e.g., `[F-d2042cff-01c9-4801-8ea7-1c1afc29c9b6]`):
  
![image](https://github.com/user-attachments/assets/4bc5efa2-c9c3-4bf0-8dab-d21069c89a79)

  2- Search for this ID in the dashboard data to see your node’s contributions.

* **Note**: The dashboard monitors all peers together. The node ID in the logs is likely your identifier but I am keep experimenting to find out more about the node metrics!


