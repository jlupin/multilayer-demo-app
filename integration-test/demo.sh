#!/usr/bin/env bash

id=$(uuidgen)

tp='priv'
if [[ $(($RANDOM%2)) -eq 0 ]]
then
    tp='priv'
else
    tp='pub'
fi

curl -X PUT "http://127.0.0.1:8000/api-gateway/create/$id" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"login\": \"jan-$id\", \"type\": \"$tp\"}"

echo ''