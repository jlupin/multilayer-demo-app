#!/usr/bin/env bash

rm -rf ./platform/logs/*
rm -rf ./platform-2/logs/*

./platform-2/start/start.sh
./platform/start/start.sh