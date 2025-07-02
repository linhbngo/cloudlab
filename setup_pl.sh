#!/bin/bash
set -e

USERNAME="pl"
SCRIPT_NAME="/home/PrairieLearn/docker.sh"
KEY_DIR="/home/${USERNAME}/.ssh"
KEY_FILE="${KEY_DIR}/id_rsa"
REPO_DIR="/home/${USERNAME}/PrairieLearn"
REPO_URL="https://github.com/PrairieLearn/PrairieLearn.git"

# 1. Create the user with no password
if ! id "$USERNAME" &>/dev/null; then
    echo "[+] Creating user '$USERNAME'..."
    useradd -m -s /bin/bash "$USERNAME"
else
    echo "[=] User '$USERNAME' already exists."
fi

# 2. Generate SSH keypair
echo "[+] Setting up SSH keys..."
mkdir -p "$KEY_DIR"
ssh-keygen -q -t rsa -b 4096 -f "$KEY_FILE" -N "" -C "${USERNAME}@$(hostname)"
chown -R $USERNAME:$USERNAME "$KEY_DIR"
chmod 700 "$KEY_DIR"
chmod 600 "$KEY_FILE"
chmod 644 "${KEY_FILE}.pub"

# 3. Add public key to authorized_keys
cat "${KEY_FILE}.pub" >> "${KEY_DIR}/authorized_keys"
chmod 600 "${KEY_DIR}/authorized_keys"
chown $USERNAME:$USERNAME "${KEY_DIR}/authorized_keys"

# 4. Allow passwordless sudo for docker.sh
SUDO_RULE="$USERNAME ALL=(ALL) NOPASSWD: ${SCRIPT_NAME}"
SUDO_FILE="/etc/sudoers.d/99-${USERNAME}-docker"

echo "[+] Configuring sudo permissions..."
echo "$SUDO_RULE" > "$SUDO_FILE"
chmod 440 "$SUDO_FILE"

# 5. Clone PrairieLearn repo as the 'pl' user
echo "[+] Cloning PrairieLearn repository into $REPO_DIR..."
sudo -u "$USERNAME" GIT_SSH_COMMAND="ssh -i $KEY_FILE -o StrictHostKeyChecking=no" \
    git clone "$REPO_URL" "$REPO_DIR"

# 6. Create docker.sh file to execute the PrairieLearn

cat <<EOF > /home/${USERNAME}/PrairieLearn/docker.sh
#!/bin/bash
cd /home/${USERNAME}/PrairieLearn
sudo docker compose -f docker-compose-production.yml up
EOF

chmod 755 /home/${USERNAME}/PrairieLearn/docker.sh
chown ${USERNAME}: /home/${USERNAME}/PrairieLearn/docker.sh

# 7. Create config.json (need to fill in more info

DOMAIN=$(hostname -f)
cat <<EOF > /home/${USERNAME}/PrairieLearn/config.json
{
  "serverCanonicalHost": "https://${DOMAIN}",
  "googleClientId": "",
  "googleClientSecret": "",
  "googleRedirectUrl": "https://${DOMAIN}/pl/oauth2callback",
  "hasOauth": true,

  "cookieDomain": ".${DOMAIN}"
}
EOF
chown ${USERNAME}: /home/${USERNAME}/PrairieLearn/config.json

# 8. Update docker-compose-production.yaml
mv /home/${USERNAME}/PrairieLearn/docker-compose-production.yml /home/${USERNAME}/PrairieLearn/docker-compose.production.yml.default
cat <<EOF > /home/${USERNAME}/PrairieLearn/docker-compose.production.yml
services:
  pl:
    image: prairielearn/prairielearn:latest
    ports:
      - 3000:3000
    volumes:
      - postgres:/var/postgres
      - /var/run/docker.sock:/var/run/docker.sock
      - ${HOME}/pl_ag_jobs:/jobs
      - ./config.json:/PrairieLearn/config.json
      - ${HOME}/.ssh:/root/.ssh

    container_name: pl
    environment:
      - HOST_JOBS_DIR=${HOME}/pl_ag_jobs
      - NODE_ENV=production
    # This must be changed if you've changed Docker's address pools.
    # i.e., "default-address-pools" in /etc/docker/daemon.json
    extra_hosts:
      - 'host.docker.internal:172.17.0.1'

volumes:
  postgres:
EOF



echo "[✔] Setup complete."
echo "[→] SSH keys stored in: $KEY_FILE and ${KEY_FILE}.pub"
echo "[→] PrairieLearn cloned to: $REPO_DIR"
