#!/bin/bash
while true
   do
      # Sleep first do that the parent comes up before we try to start to connect
      sleep 30
      /bin/nc localhost 30978 | /home/pi/spms/uat2esnt | /bin/nc mlat.rjr-services.com 41978
      echo 'Restarting DUMP978 PUSH '
   done
