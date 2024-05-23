#!/bin/bash

path=$(dirname "$0")

IEM_IP=$1

mkdir -p "${path}"/out

openssl genrsa -out "${path}"/out/myCA.key 4096

openssl req -x509 -new -nodes -key "${path}"/out/myCA.key -sha256 -days 825 -out "${path}"/out/myCA.crt -config "${path}"/ca.conf

openssl genrsa -out "${path}"/out/myCert.key 4096

openssl req -new -key "${path}"/out/myCert.key -out "${path}"/out/myCert.csr -subj "/C=DE/ST=Dummy/L=Dummy/O=Dummy/CN=$IEM_IP" -config <(cat "${path}"/cert.conf <(printf "\\n[alt_names]\\nIP.1=%s" "${IEM_IP}"))

openssl x509 -req -in "${path}"/out/myCert.csr -CA "${path}"/out/myCA.crt -CAkey "${path}"/out/myCA.key -CAcreateserial -out "${path}"/out/myCert.crt -days 825 -sha256 -extfile <(cat "${path}"/cert-ext.conf <(printf "\\n[alt_names]\\nIP.1=%s" "${IEM_IP}"))

cat "${path}"/out/myCert.crt "${path}"/out/myCA.crt > "${path}"/out/certChain.crt

rm "${path}"/out/myCert.csr "${path}"/out/myCA.srl

cp "${path}"/out/myCert.crt "${path}"/out/certChain.crt "$(pwd)"/
