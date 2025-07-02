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
SUDO_RULE="$USERNAME ALL=(ALL) NOPASSWD: /usr/local/bin/${SCRIPT_NAME}"
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
sudo docker compose -f docker-compose-production.yml up
EOF

chmod 755 /home/${USERNAME}/PrairieLearn/docker.sh
chown ${USERNAME}: /home/${USERNAME}/PrairieLearn/docker.sh

echo "[✔] Setup complete."
echo "[→] SSH keys stored in: $KEY_FILE and ${KEY_FILE}.pub"
echo "[→] PrairieLearn cloned to: $REPO_DIR"
