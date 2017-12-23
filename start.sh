#!/bin/sh

$HOME/.npm-packages/bin/homekit2mqtt \
  -s $HOME/.config/homekit2mqtt \
  -m $HOME/.config/homekit2mqtt/config.json \
  -u $MQTT_URL \
  -v $VERBOSITY
