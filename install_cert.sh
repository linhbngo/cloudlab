#!/bin/bash
set -x

# === STEP 1: Configuration ===
DOMAIN=$(hostname -f)
EMAIL=${CERTBOT_EMAIL:-admin@$DOMAIN}
INSTALL_PATH="/etc/ssl/$DOMAIN"
CERTBOT_TMP="/etc/letsencrypt/manual_certs/$DOMAIN"
mkdir -p "$CERTBOT_TMP"
mkdir -p "$INSTALL_PATH"

# === STEP 2: Install Certbot ===
apt update
apt install -y openssl certbot

# === STEP 3: Generate private key and CSR ===
cd "$CERTBOT_TMP"
openssl genrsa -out "$DOMAIN.key" 2048
openssl req -new -key "$DOMAIN.key" -subj "/CN=$DOMAIN" -out "$DOMAIN.csr"

# === STEP 4: Obtain certificate using standalone plugin ===
certbot certonly --csr "$DOMAIN.csr" --standalone \
  --preferred-challenges http \
  --non-interactive --agree-tos --email "$EMAIL"

# === STEP 5: Combine and Install ===
cat 0000_cert.pem 0000_chain.pem > "$DOMAIN.fullchain.pem"

# Install to /etc/ssl
cp "$DOMAIN.key" "$INSTALL_PATH/privkey.pem"
cp 0000_cert.pem "$INSTALL_PATH/cert.pem"
cp "$DOMAIN.fullchain.pem" "$INSTALL_PATH/fullchain.pem"
cp 0000_chain.pem "$INSTALL_PATH/chain.pem"

# === STEP 6: Set Permissions ===
chmod 600 "$INSTALL_PATH/privkey.pem"
chmod 644 "$INSTALL_PATH/"*.pem

# === STEP 7: Optional — Reload Web Server ===
systemctl reload nginx

# === STEP 8: Done ===
echo "✔ Installed certificate for $DOMAIN at $INSTALL_PATH"
ls -l "$INSTALL_PATH"
