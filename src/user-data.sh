#!/bin/bash

sudo apt update -y 

sudo apt upgrade -y 

sudo apt install nginx -y

# This will start the Nginx service automatically when the server boots
sudo systemctl enable nginx

# This will start the Nginx service immediately
sudo systemctl start nginx