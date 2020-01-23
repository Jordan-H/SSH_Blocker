#!/bin/bash

#INSTALL
#* * * * * /[PATH-TO]/SSH_Blocker.sh [ATTEMPTS] [TIME_TO_BLOCK] &> /[PATH-TO]/SSH_BlockerCron.log
DATE=`date`
TODAY=$(date --date="$DATE" +%s)
ATTEMPTS=1
TIME_BLOCK=-1
declare -A IPBOOK

if [ $1 -lt 1 ]
    then
        echo "Invalid number of ATTEMPS inputted"
        echo "Usage: ./SSH_Blocker [ATTEMPTS] [TIME_TO_BLOCK Y M D H M S]"
        exit 1
fi

if ! [ -z "$1" ]
    then
        ATTEMPTS=$1
fi

#takes in format YYYY MM DD HH MM SS
if ! [ -z "$2" ] && ! [ -z "$3" ] && ! [ -z "$4" ] && ! [ -z "$5" ] && ! [ -z "$6" ] && ! [ -z "$7" ]
    then
        TEMPDATE=$(date -d "$DATE+$2 years +$3 months +$4 days +$5 hours +$6 minutes +$7 seconds")
        TIME_BLOCK=$(date --date="$TEMPDATE" +%s)
    elif ! [ -z "$2" ] || ! [ -z "$3" ] || ! [ -z "$4" ] || ! [ -z "$5" ] || ! [ -z "$6" ] || ! [ -z "$7" ]
    then
        echo "Invalid Date, All fields or no fields must be inputted."
        exit 1
fi

#create our file to store data
if [ ! -e "IPBOOK.txt" ]
    then
        echo >> "IPBOOK.txt"
fi

CUR_LINE=0
while read line; do

let CUR_LINE+=1
IFS=' ' read -ra TEMPLINE <<< $line
if [ ${TEMPLINE[1]} -le $TODAY ] && [ ${TEMPLINE[1]} -ne  -1 ]
    then
        /sbin/iptables -D INPUT -p tcp -s ${TEMPLINE[0]} -j DROP
        /sbin/iptables -D INPUT -p udp -s ${TEMPLINE[0]} -j DROP
        sed -i "$CUR_LINE"d IPBOOK.txt
fi

done < IPBOOK.txt

while read line; do

TEMP=$(echo $line | cut -c1-15)
LOGDATE=$(date --date="$TEMP" +%s)

#DIFFERENCE IN TIME IN SECONDS
let DIFF=$TODAY-$LOGDATE
if [ $DIFF -lt "60" ]
    then
        if [[ $line = *"Failed password"* ]]
            then
                ip="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$line")"
                #IF THE IP CURRENTLY EXISTS IN THE BOOK (subtract attempts until 0)
                if ! grep -Fq "$ip" IPBOOK.txt
                    then
                    #COUNT TO SEE IF IT REACHES X ATTEMPTS THEN BLOCK IT
                    if [ -z "${IPBOOK[$ip]}" ]
                        then
                            IPBOOK[$ip]=$((ATTEMPTS-1))
                        else
                            IPBOOK[$ip]=$((IPBOOK[$ip]-1))
                    fi
                    if [ "${IPBOOK[$ip]}" -eq 0 ]
                        then
                            if ! /sbin/iptables -L -n | grep -q "$ip"
                                then
                                    /sbin/iptables -A INPUT -p tcp -s $ip -j DROP
                                    /sbin/iptables -A INPUT -p udp -s $ip -j DROP
                                    echo "$ip $TIME_BLOCK" >> IPBOOK.txt
                            fi
                    fi
                fi
        fi
fi

done < /var/log/secure
