<h1>SSH Blocker</h1>

A script to block multiple failed SSH attempts

This script is built to handle failed logins for SSH only. It uses crontab to scan for SSH logins every minute.
If the number of SSH login attempts is greater than or equal to the user-provided limit, the script will create
a Netfilter rule to block the IP address for a user-provided amount of time. The Netfilter rule will simply DROP
all TCP and UDP packets received from that IP address.

<h2>Usage</h2>

The script is invoked by adding the following cronjob:

`* * * * * /[PATH-TO]/SSH_Blocker.sh [ATTEMPTS] [TIME_TO_BLOCK] &> /[PATH-TO]/SSH_BlockerCron.log`

where TIME_TO_BLOCK is the amount of time the IP address should be blocked for after reaching the number of failed attempts.
The syntax for TIME_TO_BLOCK is:

`YYYY MM DD HH MM SS`

<h2>Reboot</h2>

The script can be invoked on reboot by adding the following cronjob:

`@reboot /[PATH-TO]/SSH_Blocker_Reboot.sh`

After restarting crond, the reboot script will setup the main script to be executed.
