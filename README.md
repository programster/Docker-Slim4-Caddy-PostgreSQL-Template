Docker Slim4 Caddy PostgreSQL Template
======================================

A template for quickly deploying a PHP 8.2 Slim4 web application using a 
[Caddy webserver](https://caddyserver.com/) and a PostgreSQL database backend, through Docker using a Debian 12 base 
image.


## Setting Up

### Config Files
Create a `.env` file from the `.env.example` template and fill in accordinly.

Update the domain for your site in `/docker/Caddyfile` as it is currently set to `my.domain.com`.
Also, if you have any issues with the webserver, you may wish to uncomment the `#debug` line in
the global options.


### SSL/TLS
Generate some TLS certificates and place them at:
* ssl/fullchain.pem - your full site certificate, including any certificate authorities
* ssl/privkey.pem - your private key

Alternatively, Caddy can manage TLS certificate generation for you, but that is up to you to 
configure, or you could disable TLS and have this behind a reverse proxy.
