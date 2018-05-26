# Overview

This project is designed to run mariadb on a raspberry pi, specifically on something like Portainer.

## What is does

The `Dockerfile` installs `mariadb-server` and sets up configuration files while the `entrypoint.sh`
script initializes the database and root user.

## Influences

Heavily influenced by the following repositories:

* https://github.com/hypriot/rpi-mysql
* https://github.com/JSurf/docker-rpi-mariadb