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
apt install -y openssl 
snap install core
snap refresh core
snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# === STEP 3: Generate private key and CSR ===
cd "$CERTBOT_TMP"
openssl genrsa -out "$DOMAIN.key" 2048
openssl req -new -key "$DOMAIN.key" -subj "/CN=$DOMAIN" -out "$DOMAIN.csr"

# === STEP 4: Obtain certificate using standalone plugin ===
certbot certonly -d "$DOMAIN" --standalone \
  --preferred-challenges tls-alpn \
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

# === STEP 7: Optional — Install Web Server ===
apt install -y nginx

cat << EOF > /etc/nginx/sites-available/ssl-site
server {
	listen 443 ssl;
	server_name ${DOMAIN};
	
	ssl_certificate		/etc/ssl/${DOMAIN}/fullchain.pem;
	ssl_certificate_key	/etc/ssl/${DOMAIN}/privkey.pem;
	
	ssl_protocols		TLSv1.2 TLSv1.3;
	ssl_ciphers		HIGH:!aNULL:!MD5;

  	access_log              /var/log/nginx/nginx.access.log;
  	error_log               /var/log/nginx/nginx.error.log;

  location / {
    proxy_pass              http://localhost:3000;
    proxy_set_header        Host \$host;
    proxy_set_header        X-Forwarded-Proto \$scheme;
    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_redirect          off;
  }
}

server {
	listen 80;
	server_name ${DOMAIN};
	return 301 https://\$host\$request_uri;
}

EOF

nginx -t
ln -s /etc/nginx/sites-available/ssl-site /etc/nginx/sites-enabled/
systemctl reload nginx

# === STEP 8: Done ===
echo "Installed certificate for $DOMAIN at $INSTALL_PATH"
ls -l "$INSTALL_PATH"
