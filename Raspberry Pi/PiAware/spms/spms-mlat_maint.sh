#!/bin/sh
while true
  do
    #Sleep for a while first before trying to connect to dump1090 and such
    sleep 30 
    /usr/bin/wget -O mlatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=LSA&feed=M&event=U' > /dev/null 2>&1 &
    /usr/bin/mlat-client --input-type dump1090 --input-connect localhost:30005 --lat 32.9565 --lon -102.1398 --alt 954 --user LSA --server mlat.rjr-services.com:30010 --no-udp --results beast,connect,localhost:30104
    /usr/bin/wget -O mlatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=LSA&feed=M&event=D' > /dev/null 2>&1 &
  done
