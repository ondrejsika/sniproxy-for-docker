#!/bin/sh

# Sniproxy for Docker
#
#     Ondrej Sika <ondrej@ondrejsika.com>
#     https://github.com/ondrejsika/sniproxy-for-docker
#     MIT license https://ondrejsika.com/license/mit.txt
#

mkdir -p /tmp/sniproxy

docker rm -f sniproxy >/dev/null 2>/dev/null

cat << EOF > /tmp/sniproxy/sniproxy.conf
listen 80 {
    proto http
    table hosts
}

listen 443 {
    proto https
    table hosts
}

table hosts {
EOF

docker inspect --format '{{.Name}} {{ .NetworkSettings.IPAddress }}' \
    `docker ps -q` \
    | sed 's/\//    /g' \
    | grep '172.' \
    >> /tmp/sniproxy/sniproxy.conf

cat << EOF >> /tmp/sniproxy/sniproxy.conf
}
EOF

docker run --name sniproxy \
    -p 80:80 \
    -p 443:443 \
    -v /tmp/sniproxy:/etc/sniproxy \
    -d tommylau/sniproxy \
    >/dev/null


