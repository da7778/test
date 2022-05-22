#!/bin/sh

# Global variables
DIR_CONFIG="/etc/fq"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write fq configuration
cat << EOF > ${DIR_TMP}/heroku.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "${ID}",
                "alterId": 0
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "${WSPATH}"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get fq executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/da7778/fq/raw/main/fq.zip -o ${DIR_TMP}/fq_dist.zip
busybox unzip ${DIR_TMP}/fq_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/ctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install fq
install -m 755 ${DIR_TMP}/fq ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run fq
${DIR_RUNTIME}/fq -config=${DIR_CONFIG}/config.pb
