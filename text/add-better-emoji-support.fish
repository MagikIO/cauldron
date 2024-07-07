#!/usr/bin/env fish

sudo apt-add-repository ppa:eosrei/fonts -y
wait $last_pid
sudo apt update
wait $last_pid
sudo apt upgrade -y
wait $last_pid
sudo apt install fonts-twemoji-svginot -y
wait $last_pid
