#!/bin/bash
#
# pocsagWx.sh
#
# Pull Wx data from MQTT broker, send to POCSAG via RemoteCommand
#
# John/KI5NYZ 2022
#
# Configuration

callsign="N0CALL"
grid="urGrid"
time=$(date +"%H:%M")
server="urServer"
prefix="urMQTTprefix"
ric="urRIC"

# Get MQTT Wx Data
outT=$(mosquitto_sub -h $server -C 1 -t $prefix/outTemp_F | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')

windS=$(mosquitto_sub -h $server -C 1 -t $prefix/windSpeed_mph | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')

windD=$(mosquitto_sub -h $server -C 1 -t $prefix/windDir | awk -F '.' '{print $1}')

humid=$(mosquitto_sub -h $server -C 1 -t $prefix/outHumidity | awk -F '.' '{print $1}')

baro=$(mosquitto_sub -h $server -C 1 -t $prefix/barometer_inHg | awk -F '.' '{print $1 "." substr ($2, 0, 3)}')

rainR=$(mosquitto_sub -h $server -C 1 -t $prefix/rainRate_inch_per_hour | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')

#rainT=$(mosquitto_sub -h $server -C 1 -t $prefix/rain_in | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')

lux=$(mosquitto_sub -h $server -C 1 -t $prefix/radiation_Wpm2 | awk -F '.' '{print $1 "." substr ($2, 0, 2)}')

sudo RemoteCommand 7642 page $ric "$callsign/$grid: ${outT}F w: ${windS}mi/h=${windD}deg h: $humid% inHg: $baro r: ${rainR}in/h l: ${lux}Wpm2"
