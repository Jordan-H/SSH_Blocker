#!/bin/bash

#script to be run on startup

crontab -l > mycron

echo "* * * * * /[PATH-TO]/SSH_Blocker.sh 2 0 0 0 0 0 30 &> /[PATH-TO]/SSH_BlockerCron.log" >> mycron
echo "" >> mycron

crontab mycron

rm mycron
