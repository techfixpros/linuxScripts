#!/bin/sh
while true
  do
    #Sleep before trying to connect everything together.
    sleep 30 
    /usr/bin/wget -O netcatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=LSA&feed=A&event=U' > /dev/null 2>&1 &
    /usr/bin/socat -u TCP:localhost:30005 TCP:mlat.rjr-services.com:41000
    /usr/bin/wget -O netcatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=LSA&feed=A&event=D' > /dev/null 2>&1 &
  done
