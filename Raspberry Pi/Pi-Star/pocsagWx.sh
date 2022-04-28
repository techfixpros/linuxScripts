#!/bin/bash
#
# wx2pocsag.sh
#
# John/KI5NYZ 2022
#
# Configuration

call="KI5NYZ"
grid="DM82ww"
time=$(date +"%H:%M")
server="altair.lan"
prefix="weewx"
ric="1080"
pause=0

# Get MQTT Wx Data
outT=$(mosquitto_sub -h $server -C 1 -t $prefix/outTemp_F | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')
sleep $pause

windS=$(mosquitto_sub -h $server -C 1 -t $prefix/windSpeed_mph | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')
sleep $pause

windD=$(mosquitto_sub -h $server -C 1 -t $prefix/windDir | awk -F '.' '{print $1}')
sleep $pause

humid=$(mosquitto_sub -h $server -C 1 -t $prefix/outHumidity | awk -F '.' '{print $1}')
sleep $pause

baro=$(mosquitto_sub -h $server -C 1 -t $prefix/barometer_inHg | awk -F '.' '{print $1 "." substr ($2, 0, 3)}')
sleep $pause

rainR=$(mosquitto_sub -h $server -C 1 -t $prefix/rainRate_inch_per_hour | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')
sleep $pause

#rainT=$(mosquitto_sub -h $server -C 1 -t $prefix/rain_in | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')
#sleep $pause

lux=$(mosquitto_sub -h $server -C 1 -t $prefix/radiation_Wpm2 | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')
sleep $pause

# Debug to CLI
#echo "$time $call/$grid: ${outT}F w: ${windS}mi/h=${windD}deg h: $humid% inHg: $baro r: ${rainR}in/h l: ${lux}Wpm2"

sudo RemoteCommand 7642 page $ric "$call/$grid: ${outT}F w: ${windS}mi/h=${windD}deg h: $humid% inHg: $baro r: ${rainR}in/h l: ${lux}Wpm2"
