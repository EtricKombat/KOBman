#!/bin/bash 

cd $HOME
sudo rm -rf .kobman/ 

cd /usr/home/kobman
sudo rm -rf KOBman/
sudo rm -rf TheOrgBook/
sudo rm -rf greenlight/
sudo rm -rf von-network/ 

sudo figlet Clean-Up -f small
sudo reboot
