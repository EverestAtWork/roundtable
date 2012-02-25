#!/bin/bash

#This script ensures that roundtable is automatically restarting after an error happens
# Taken from etherpad lite.

#Handling Errors
# 0 silent
# 1 email
ERROR_HANDLING=1
# Your email address which should recieve the error messages
EMAIL_ADDRESS="cfd@media.mit.edu"
# Sets the minimun amount of time betweens the sending of error emails. 
# This ensures you not get spamed while a endless reboot loop 
# It's the time in seconds
TIME_BETWEEN_EMAILS=600 # 10 minutes

# DON'T EDIT AFTER THIS LINE

LAST_EMAIL_SEND=0

#Move to the folder where roundtable is installed
cd `dirname $0`

#Was this script started in the bin folder? if yes move out
if [ -d "../bin" ]; then
  cd "../"
fi

#check if a logfile parameter is set
if [ -z "$1" ]; then
  echo "Set a logfile as the first parameter"
  exit 1
fi

while [ 1 ]
do
  #try to touch the file if it doesn't exist
  if [ ! -f $1 ]; then
    touch $1 || ( echo "Logfile '$1' is not writeable" && exit 1 )
  fi

  #check if the file is writeable
  if [ ! -w $1 ]; then
    echo "Logfile '$1' is not writeable"
    exit 1
  fi

  #start the application
  bin/run.sh >>$1 2>>$1

  #Send email
  if [ $ERROR_HANDLING = 1 ]; then
    TIME_NOW=$(date +%s)
    TIME_SINCE_LAST_SEND=$(($TIME_NOW - $LAST_EMAIL_SEND))

    if [ $TIME_SINCE_LAST_SEND -gt $TIME_BETWEEN_EMAILS ]; then
      printf "Server was restared at: $(date)\nThe last 50 lines of the log before the error happens:\n $(tail -n 50 $1)" | mail -s "Roundtable server was restarted" $EMAIL_ADDRESS

      LAST_EMAIL_SEND=$TIME_NOW
    fi
  fi

  echo "RESTART!" >>$1

  #Sleep 10 seconds before restart
  sleep 10
done