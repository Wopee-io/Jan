#!/bin/bash

echo "Export user id to use in containers."
echo "------------------------------------"

export UID="$(id -u)" && wait $!
export GID="$(id -g)" && wait $!