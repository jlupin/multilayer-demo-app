#!/usr/bin/env bash


curl -X GET "http://127.0.0.1:8000/admin-gateway/list" -H "accept: text/event-stream"

echo ''