#!/bin/bash

echo "Export user id to use in containers."
echo "------------------------------------"

export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"