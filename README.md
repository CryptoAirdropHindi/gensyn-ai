# Gensyn Node Run One click

🎥 Video Guide [https://www.youtube.com/](https://www.youtube.com/@CryptoAirdropHindi6)

📌 medium Guide [https://medium.com/](https://medium.com/@CryptoAirdropHindi/gensyn-node-run-one-click-14d0e1b5a775)


```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/gensyn-ai/refs/heads/main/gensyn.sh)
```


# Update Node
**Method 1**: If you cloned official repo with no local changes
```bash
cd rl-swarm
git pull
```

**Method 2**: If you cloned official repo with local Changes
```console
cl rl-swarm

# Reset local changes:
git reset --hard
# Pull updates:
git pull

# Alternatively:
git fetch
git reset --hard origin/main
```
* You have to do your local changes again.

**Method 3**: Cloned unofficial repo or Try from scratch `Recommended`:
```console
cd rl-swarm

# backup .pem
cp ./swarm.pem ~/swarm.pem

cd ..

# delete rl-swarm dir
rm -rf rl-swarm

# clone new repo
git clone https://github.com/gensyn-ai/rl-swarm

cd rl-swarm

# Recover .pem
cp ~/swarm.pem ./swarm.pem
```
* If you had any local changes, you have to do it again.
---

# Troubleshooting:

### ⚠️ Upgrade viem & Node version in Login Page
1- Modify: `package.json`
```bash
cd rl-swarm
nano modal-login/package.json
```
* Update: `"viem":` to `"2.25.0"`

2- Upgrade
```bash
cd rl-swarm
cd modal-login
yarn install

yarn upgrade && yarn add next@latest && yarn add viem@latest

cd ..
```

### ⚠️ CPU-only Users: Ran out of input
Navigate:
```
cd rl-swarm
```
Edit:
```
nano hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
```
* Lower `max_steps` to `5`
