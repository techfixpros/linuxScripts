#!/bin/bash
while true
   do
      dump978-fa --sdr drive=rtlsdr,serial=00000978 --raw-port 30978 --json-port 30979
      echo 'Restarting DUMP978'
      sleep 30
   done
