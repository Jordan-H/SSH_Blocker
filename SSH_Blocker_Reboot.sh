#!/bin/bash

#script to be run on startup

crontab -l > mycron

echo "* * * * * /[PATH-TO]/SSH_Blocker.sh [ATTEMPTS] [TIME_TO_BLOCK] &> /[PATH-TO]/SSH_BlockerCron.log" >> mycron
echo "" >> mycron

crontab mycron

rm mycron
