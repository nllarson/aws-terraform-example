#!/bin/bash

sudo yum update -y

sudo yum install nginx -y

sudo chkconfig nginx on
sudo service nginx start