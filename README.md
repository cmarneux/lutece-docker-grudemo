# Lutece GRU demo for Docker
## Variables
BASE_SCHEMA : HTTP or HTTPS
BASE_HOST: IP, localhost or domain name
BASE_PORT: the port to show site
BASE_PATH: do not use this variable except if you use reverse proxy
## Examples
docker run -d --name demo-gru lutece/gru-demo:1.0
If you want to forward port, use :
docker run -d --name demo-gru -p 82:80 -e BASE_PORT=82 -e BASE_HOST=localhost lutece/gru-demo:1.0
