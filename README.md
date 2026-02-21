# Dev Shared SSL Certificate Manager

Local SSL certificate management tool using **mkcert + Apache** on
Ubuntu.

------------------------------------------------------------------------

## Overview

This script manages a shared development SSL certificate for multiple
local domains.

It allows you to:

-   Add multiple domains
-   Remove multiple domains
-   Automatically manage wildcards
-   Regenerate certificate
-   Reload Apache

All certificates are stored in: /etc/ssl/mkcert/

Structure:
/etc/ssl/mkcert/ 
├── certs/dev-shared.pem 
├── private/dev-shared.key 
└── domains.txt

------------------------------------------------------------------------

## Requirements

-   Ubuntu
-   Apache (mod_ssl enabled)
-   mkcert installed: sudo apt install mkcert
-   mkcert initialized: mkcert -install ( dont use sudo or root user )
------------------------------------------------------------------------

## Installation

1.  Place script somewhere in your home directory:

    chmod +x ssl-manager.sh

2.  Ensure directory structure exists:

    sudo mkdir -p /etc/ssl/mkcert/certs
    sudo mkdir -p /etc/ssl/mkcert/private
    sudo touch /etc/ssl/mkcert/domains.txt

4.  Ensure Apache SSL config uses:

    SSLCertificateFile /etc/ssl/mkcert/certs/dev-shared.pem
    SSLCertificateKeyFile /etc/ssl/mkcert/private/dev-shared.key

------------------------------------------------------------------------

## Usage

Run:

    ./ssl-manager.sh

You will be prompted:

1)  Add domain(s)
2)  Remove domain(s)
3)  Regenerate only
4)  Exit

------------------------------------------------------------------------

## Adding Domains

You can add multiple domains at once:

    api.pma.dev admin.pma.dev pma.dev

If a base domain is added:

    pma.dev

The script automatically adds:

    *.pma.dev

------------------------------------------------------------------------

## Removing Domains

If you remove:

    pma.dev

The script automatically removes:

    *.pma.dev

Removing subdomains does NOT remove wildcard for base domain.

------------------------------------------------------------------------

## After Changes

The script will:

1.  Regenerate the shared certificate
2.  Reload Apache automatically

------------------------------------------------------------------------

## Important Notes

⚠ Never run the script with sudo.

Running mkcert as root will generate a different CA, causing browser
certificate errors.

Always run:

    ./ssl-manager.sh

------------------------------------------------------------------------

## Verification

To verify certificate:

    openssl s_client -connect pma.dev:443 -servername pma.dev

You should see:

    Verify return code: 0 (ok)

------------------------------------------------------------------------

## Recommended domains.txt Example

    pma.dev
    *.pma.dev
    localhost
    127.0.0.1

------------------------------------------------------------------------

## Troubleshooting

If browsers show:

    ERR_CERT_AUTHORITY_INVALID

Ensure:

    mkcert -install

And that the certificate was NOT generated using sudo.

------------------------------------------------------------------------

## Author

Local Development SSL automation using mkcert + Apache.
