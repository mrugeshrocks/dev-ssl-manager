#!/bin/bash

############################################################
# Dev Shared SSL Certificate Manager (Apache + mkcert)
#
# Description:
# This script manages a shared development SSL certificate
# using mkcert for multiple local domains.
#
# Features:
# - Add multiple domains at once
# - Remove multiple domains at once
# - Automatically adds wildcard (*.domain) for base domains
# - Automatically removes wildcard if base domain is removed
# - Regenerates shared certificate
# - Reloads Apache after regeneration
#
# Directory Structure:
# /etc/ssl/mkcert/
# ├── certs/dev-shared.pem
# ├── private/dev-shared.key
# └── domains.txt
#
# IMPORTANT:
# - DO NOT run this script with sudo.
# - mkcert must run as normal user.
# - Only Apache reload uses sudo internally.
#
# Requirements:
# - Ubuntu
# - mkcert installed and initialized
# - Apache with SSL enabled
#
# Usage:
# ./ssl-manager.sh
#
############################################################

CERT_DIR="/etc/ssl/mkcert"
CERT_FILE="$CERT_DIR/certs/dev-shared.pem"
KEY_FILE="$CERT_DIR/private/dev-shared.key"
DOMAIN_FILE="$CERT_DIR/domains.txt"

if [ ! -f "$DOMAIN_FILE" ]; then
echo "Domain file not found: $DOMAIN_FILE"
exit 1
fi

echo "--------------------------------------"
echo "Current domains:"
cat "$DOMAIN_FILE"
echo "--------------------------------------"
echo "Choose an option:"
echo "1) Add domain(s)"
echo "2) Remove domain(s)"
echo "3) Regenerate only"
echo "4) Exit"
read -p "Enter choice [1-4]: " choice

case $choice in
1)
echo "Enter domain(s) separated by space:"
read domains

for domain in $domains; do
if grep -qx "$domain" "$DOMAIN_FILE"; then
echo "$domain already exists."
else
echo "$domain" | sudo tee -a "$DOMAIN_FILE" > /dev/null
echo "Added: $domain"

# Only auto-add wildcard for base domains (no leading * and no sub-subdomain logic)
if [[ "$domain" != \*.* ]]; then
wildcard="*.$domain"
if ! grep -qx "$wildcard" "$DOMAIN_FILE"; then
echo "$wildcard" | sudo tee -a "$DOMAIN_FILE" > /dev/null
echo "Added wildcard: $wildcard"
fi
fi
fi
done
;;
2)
echo "Enter domain(s) to remove separated by space:"
read domains

for domain in $domains; do
if grep -qx "$domain" "$DOMAIN_FILE"; then
sudo sed -i "/^$domain$/d" "$DOMAIN_FILE"
echo "Removed: $domain"

# If removing base domain, also remove its wildcard
wildcard="*.$domain"
if grep -qx "$wildcard" "$DOMAIN_FILE"; then
sudo sed -i "/^\*\.$domain$/d" "$DOMAIN_FILE"
echo "Removed wildcard: $wildcard"
fi
else
echo "$domain not found."
fi
done
;;
3)
echo "Regenerating without modifying domains..."
;;
4)
exit 0
;;
*)
echo "Invalid option."
exit 1
;;
esac

echo "--------------------------------------"
echo "Updated domain list:"
cat "$DOMAIN_FILE"
echo "--------------------------------------"

echo "Regenerating shared SSL certificate..."

mkcert \
-cert-file "$CERT_FILE" \
-key-file "$KEY_FILE" \
$(cat "$DOMAIN_FILE")

if [ $? -eq 0 ]; then
echo "SSL certificate successfully regenerated."
echo "Reloading Apache..."
sudo systemctl reload apache2
echo "Done."
else
echo "Certificate generation failed."
fi
