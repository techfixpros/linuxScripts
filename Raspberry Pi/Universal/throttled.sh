#!/bin/bash
clear

if ! command -v vcgencmd &>/dev/null
then
    echo -------
    echo "Command vcgencmd not found, can't check for throttling!"
    echo "Exiting."
    echo -------
    exit 1
fi

#System Colors
pSTAT=`tput setaf 2`
pUNIT=`tput setaf 3`
pNC=`tput sgr0`

gpu=$(vcgencmd measure_temp | awk -F "[=']" '{print $2}')
cpu=$(</sys/class/thermal/thermal_zone0/temp)
cpu=$(echo "$cpu / 100 * 0.1" | bc)
cpuf=$(echo "(1.8 * $cpu) + 32" | bc)
gpuf=$(echo "(1.8 * $gpu) + 32" | bc)
iTempC=$(checkTemp | awk '{ print substr($7, 1, length($7)-1) }')
iTempF=$(checkTemp | awk '{ print substr($8, 1, length($8)-1) }')
eTempC=$(checkTemp | awk '{ print substr($10, 1, length($10)-1) }')
eTempF=$(checkTemp | awk '{ print substr($11, 1, length($11)-1) }')

echo "$(date) @ $(hostname)"
echo "-------------------------------------------"
echo "Temperature"
echo "-------------------------------------------"
echo "GPU  => ${pSTAT}${gpu}${pNC}'${pUNIT}C${pNC} (${pSTAT}${gpuf}${pNC}'${pUNIT}F${pNC})"
echo "CPU  => ${pSTAT}${cpu}${pNC}'${pUNIT}C${pNC} (${pSTAT}${cpuf}${pNC}'${pUNIT}F${pNC})"
echo "Case => ${pSTAT}${iTempC}${pNC}'${pUNIT}C${pNC} (${pSTAT}${iTempF}${pNC}'${pUNIT}F${pNC})"
echo "Fan  => ${pSTAT}${eTempC}${pNC}'${pUNIT}C${pNC} (${pSTAT}${eTempF}${pNC}'${pUNIT}F${pNC})"
echo "-------------------------------------------"
echo "Power"
echo "-------------------------------------------"
cpuV=$(vcgencmd measure_volts | awk -F "[=']" '{print substr($2, 1, length($2)-3)}')
ampsNow=$(cat /sys/devices/platform/rpi-poe-power-supply@0/power_supply/rpi-poe/current_now | awk '{print $1/1000000}')
ampsAvg=$(cat /sys/devices/platform/rpi-poe-power-supply@0/power_supply/rpi-poe/current_avg | awk '{print $1/1000000}')
ampsMax=$(cat /sys/devices/platform/rpi-poe-power-supply@0/power_supply/rpi-poe/current_max | awk '{print $1/1000000}')
poeHealth=$(cat /sys/devices/platform/rpi-poe-power-supply@0/power_supply/rpi-poe/health)
wattsNow=$(echo "$ampsNow * 5" | bc)
wattsAvg=$(echo "$ampsAvg * 5" | bc)
wattsMax=$(echo "$ampsMax * 5" | bc)
echo "Core    => ${pSTAT}${cpuV}${pUNIT}V${pNC}"
echo "PoE Now => ${pSTAT}${ampsNow}${pUNIT}A${pNC} (${pSTAT}${wattsNow}${pUNIT}W${pNC})"
echo "PoE Avg => ${pSTAT}${ampsAvg}${pUNIT}A${pNC} (${pSTAT}${wattsAvg}${pUNIT}W${pNC})"
echo "PoE Max => ${pSTAT}${ampsMax}${pUNIT}A${pNC} (${pSTAT}${wattsMax}${pUNIT}W${pNC})"
echo "Health  => ${pSTAT}${poeHealth}${pNC}"


#Flag Bits
UNDERVOLTED=0x1
CAPPED=0x2
THROTTLED=0x4
SOFT_TEMPLIMIT=0x8
HAS_UNDERVOLTED=0x10000
HAS_CAPPED=0x20000
HAS_THROTTLED=0x40000
HAS_SOFT_TEMPLIMIT=0x80000


#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0`

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"

#Get Status, extract hex
STATUS=$(vcgencmd get_throttled)
STATUS=${STATUS#*=}

echo "-------------------------------------------"
echo -n "Status: "
(($STATUS!=0)) && echo "${RED}${STATUS}${NC}" || echo "${GREEN}${STATUS}${NC}"

echo "Undervolted:"
echo -n "   Now: "
((($STATUS&UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Throttled:"
echo -n "   Now: "
((($STATUS&THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Frequency Capped:"
echo -n "   Now: "
((($STATUS&CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Softlimit:"
echo -n "   Now: "
((($STATUS&SOFT_TEMPLIMIT)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_SOFT_TEMPLIMIT)!=0)) && echo "${BAD}" || echo "${GOOD}"
