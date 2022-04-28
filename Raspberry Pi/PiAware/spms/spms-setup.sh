#!/bin/bash

#echo "This script is down for maintenance"
#echo "Joe needs to figure out some issues that are occurring"
#exit

#
#####################################################################################
#                        ADS-B EXCHANGE SETUP SCRIPT FORKED                         #
#####################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
# Copyright (c) 2015-2016 Joseph A. Prochazka                                       #
#                                                                                   #
# Permission is hereby granted, free of charge, to any person obtaining a copy      #
# of this software and associated documentation files (the "Software"), to deal     #
# in the Software without restriction, including without limitation the rights      #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell         #
# copies of the Software, and to permit persons to whom the Software is             #
# furnished to do so, subject to the following conditions:                          #
#                                                                                   #
# The above copyright notice and this permission notice shall be included in all    #
# copies or substantial portions of the Software.                                   #
#                                                                                   #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER            #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,     #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     #
# SOFTWARE.                                                                         #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Script modified for use with South Plains Multilateration System                  #
# Joe Jurecka  No copyright claimed						    #
# Version 2.0 23 AUG 2018                                                           #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#
## CHECK IF SCRIPT WAS RAN USING SUDO

if [ "$(id -u)" != "0" ]; then
    echo -e "\033[33m"
    echo "This script must be run using sudo or as root."
    echo -e "\033[37m"
    exit 1
fi

INSTALLDIR=/home/pi/spms
mkdir -p $INSTALLDIR
cd $INSTALLDIR
LOGFILE=/home/pi/spms/install.log

RECEIVERPORT=41000
FAMLATPORT=42000


## CHECK FOR PACKAGES NEEDED BY THIS SCRIPT

echo -e "\033[33m"
echo "Checking for packages needed to run this script..."

if [ $(dpkg-query -W -f='${STATUS}' curl 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Installing the curl package..." >> $LOGFILE 2>&1
    echo -e "\033[37m"
    sudo apt-get update
    sudo apt-get install -y curl
fi

echo -e "\033[37m"

if [ $(dpkg-query -W -f='${STATUS}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Installing the git package..." >> $LOGFILE 2>&1
    echo -e "\033[37m"
    sudo apt-get update
    sudo apt-get install -y git
fi

if [ $(dpkg-query -W -f='${STATUS}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Installing the wget package..." >> $LOGFILE 2>&1
    echo -e "\033[37m"
    sudo apt-get update
    sudo apt-get install -y git
fi

echo -e "\033[37m"

## ASSIGN VARIABLES

LOGDIRECTORY="$PWD/logs"
MLATCLIENTVERSION="0.2.6"
MLATCLIENTTAG="v0.2.6"

## WHIPTAIL DIALOGS

BACKTITLETEXT="Southern Plains Multilateration Setup Script"

whiptail --backtitle "$BACKTITLETEXT" --title "$BACKTITLETEXT" --yesno "Thanks for choosing to share your data with the Southern Plains Multilateration System!\n\nWe are a co-op of ADS-B/Mode S/MLAT feeders. This script (Version 3.1) will configure your current your ADS-B receiver to share your data with our private network.\n\nWould you like to continue setup?" 13 78
CONTINUESETUP=$?
if [ $CONTINUESETUP = 1 ]; then
    exit 0
fi

SPMSLOCATIONIDENTIFIER=$(whiptail --backtitle "$BACKTITLETEXT" --title "SPMS Location Identifier" --nocancel --inputbox "\nPlease enter your station identifier as assigned by the administrator.\n\nIf you have more than one receiver, this username should be unique.\nExample: \"IAH\", \"DEN\", etc." 12 78 3>&1 1>&2 2>&3)
RECEIVERLATITUDE=$(whiptail --backtitle "$BACKTITLETEXT" --title "Receiver Latitude" --nocancel --inputbox "\nEnter your receivers latitude." 9 78 3>&1 1>&2 2>&3)
RECEIVERLONGITUDE=$(whiptail --backtitle "$BACKTITLETEXT" --title "Receiver Longitude" --nocancel --inputbox "\nEnter your recivers longitude.\nNOTE: Enter WEST longitude as a NEGATIVE NUMBER" 9 78 3>&1 1>&2 2>&3)
RECEIVERALTITUDE=$(whiptail --backtitle "$BACKTITLETEXT" --title "Receiver Longitude" --nocancel --inputbox "\nEnter your receivers altitude (IN METERS).  The default provided is your estimated ground level height (in meters). METERS = FEET/3.281 \n\nPlease add your antenna height (in meters) to this value" 9 78 "`curl -s https://maps.googleapis.com/maps/api/elevation/json?locations=$RECEIVERLATITUDE,$RECEIVERLONGITUDE | python -c "import json,sys;obj=json.load(sys.stdin);print obj['results'][0]['elevation'];"`" 3>&1 1>&2 2>&3)
#RECEIVERPORT=$(whiptail --backtitle "$BACKTITLETEXT" --title "Receiver Feed Port" --nocancel --inputbox "\nChange only if you were assigned a custom feed port.\nFor most all users it is required this port remain set to port 41000." 10 78 "41000" 3>&1 1>&2 2>&3)
#RECEIVERPORT = 41000

#NOW HANDLE THE FLIGHTAWARE FAMLAT DATA
#FAMLATPORT=$(whiptail --backtitle "$BACKTITLETEXT" --title "FAMLAT Feed Destination Port" --nocancel --inputbox "\nChange only if you were assigned a custom feed port.\nFor most all users it is required this port remain set to port 42000." 10 78 "42000" 3>&1 1>&2 2>&3)
#FAMLATPORT=42000

whiptail --backtitle "$BACKTITLETEXT" --title "$BACKTITLETEXT" --yesno "We are now ready to begin setting up your receiver to feed the SPMS.\n\nDo you wish to proceed?" 9 78
CONTINUESETUP=$?
if [ $CONTINUESETUP = 1 ]; then
    exit 0
fi
## BEGIN SETUP

{
    #UPDATE METADATA WITH USER INFO
    /usr/bin/wget -O mlatstat 'http://mlat.rjr-services.com:1090/mlat/maint/metadata.php?station_id='${SPMSLOCATIONIDENTIFIER^^}'&lat='$RECEIVERLATITUDE'&lon='$RECEIVERLONGITUDE'&alt='$RECEIVERALTITUDE'&adsbport='$RECEIVERPORT'&famlatport='$FAMLATPORT'&clientver='$MLATCLIENTVERSION > /dev/null 2>&1 &

    # Make a log directory if it does not already exist.
    if [ ! -d "$LOGDIRECTORY" ]; then
        mkdir $LOGDIRECTORY
    fi
    LOGFILE="$LOGDIRECTORY/image_setup-$(date +%F_%R)"
    touch $LOGFILE

    echo 4
    sleep 0.25
# ENSURE OUR APT-GET stuff is up to date
    apt-get update >> $LOGFILE 2>&1 2>&1

    sleep 0.25


#Configure PIAWARE
    echo "Configuring FlightAware MLAT for port $FAMLATPORT" >> $LOGFILE 2>&1
    piaware-config mlat-results-format "beast,connect,localhost:30104 beast,listen,30105 beast,connect,mlat.rjr-services.com:$FAMLATPORT" >> $LOGFILE 2>&1 2>&1
    echo "Restarting Piaware" >> $LOGFILE 2>&1
    systemctl restart piaware  >> $LOGFILE 2>&1 2>&1

    sleep 0.25

    # BUILD AND CONFIGURE THE MLAT-CLIENT PACKAGE

    echo "INSTALLING PREREQUISITE PACKAGES" >> $LOGFILE 2>&1
    echo "--------------------------------------" >> $LOGFILE 2>&1
    echo "" >> $LOGFILE 2>&1


    # Check that the prerequisite packages needed to build and install mlat-client are installed.
    if [ $(dpkg-query -W -f='${STATUS}' build-essential 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo apt-get install -y build-essential >> $LOGFILE 2>&1  2>&1
    fi

    echo 10
    sleep 0.25

    if [ $(dpkg-query -W -f='${STATUS}' debhelper 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo apt-get install -y debhelper >> $LOGFILE 2>&1  2>&1
    fi

    echo 16
    sleep 0.25

    if [ $(dpkg-query -W -f='${STATUS}' python 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo apt-get install -y python >> $LOGFILE 2>&1  2>&1
    fi

    echo 18
    sleep 0.26
    
    if [ $(dpkg-query -W -f='${STATUS}' python3-dev 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo apt-get install -y python3-dev >> $LOGFILE 2>&1  2>&1
    fi

    echo 22
    sleep 0.25

    if [ $(dpkg-query -W -f='${STATUS}' socat 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo apt-get install -y socat >> $LOGFILE 2>&1  2>&1
    fi

    echo 24
    sleep 0.25

    if [ $(dpkg-query -W -f='${STATUS}' netcat 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo apt-get install -y netcat >> $LOGFILE 2>&1  2>&1
    fi

    echo 26
    sleep 0.25
	
     if [ $(dpkg-query -W -f='${STATUS}' dump978-fa 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo apt-get install -y dump978-fa >> $LOGFILE 2>&1  2>&1
    fi

    echo 28
    sleep 0.25

    echo "" >> $LOGFILE 2>&1
    echo " BUILD AND INSTALL MLAT-CLIENT" >> $LOGFILE 2>&1
    echo "-----------------------------------" >> $LOGFILE 2>&1
    echo "" >> $LOGFILE 2>&1

    # Check if the mlat-client git repository already exists.
    if [ -d mlat-client ] && [ -d mlat-client/.git ]; then
        # If the mlat-client repository exists update the source code contained within it.
        cd mlat-client >> $LOGFILE 2>&1
        git pull >> $LOGFILE 2>&1 2>&1
        git checkout tags/$MLATCLIENTTAG >> $LOGFILE 2>&1 2>&1
    else
        # Download a copy of the mlat-client repository since the repository does not exist locally.
        git clone https://github.com/mutability/mlat-client.git >> $LOGFILE 2>&1 2>&1
        cd mlat-client >> $LOGFILE 2>&1 2>&1
        git checkout tags/$MLATCLIENTTAG >> $LOGFILE 2>&1 2>&1
    fi

    echo 34
    sleep 0.25

    # Build and install the mlat-client package.
    dpkg-buildpackage -b -uc >> $LOGFILE 2>&1 2>&1
    cd .. >> $LOGFILE 2>&1
    sudo dpkg -i mlat-client_${MLATCLIENTVERSION}*.deb >> $LOGFILE 2>&1

    echo 40
    sleep 0.25

    echo "" >> $LOGFILE 2>&1
    echo " CREATE AND CONFIGURE MLAT-CLIENT STARTUP SCRIPTS" >> $LOGFILE 2>&1
    echo "------------------------------------------------------" >> $LOGFILE 2>&1
    echo "" >> $LOGFILE 2>&1

###################################################################################
#GET THE NEEDED FILES	
/usr/bin/wget -O /home/pi/spms/uat2esnt 'http://www.jurecka.net/spms/uat2esnt' >> $LOGFILE 2>&1
/usr/bin/wget -O /home/pi/spms/uat2json 'http://www.jurecka.net/spms/uat2json' >> $LOGFILE 2>&1
/usr/bin/wget -O /home/pi/spms/uat2text 'http://www.jurecka.net/spms/uat2text' >> $LOGFILE 2>&1
/usr/bin/wget -O /home/pi/spms/restart 'http://www.jurecka.net/spms/restart' >> $LOGFILE 2>&1

chmod +x /home/pi/spms/uat2esnt >> $LOGFILE 2>&1
chmod +x /home/pi/spms/uat2json >> $LOGFILE 2>&1
chmod +x /home/pi/spms/uat2text >> $LOGFILE 2>&1
chmod +x /home/pi/spms/restart >> $LOGFILE 2>&1

/usr/bin/wget -O /lib/systemd/system/spms-adsb.service 'http://www.jurecka.net/spms/systemd/spms-adsb.service' >> $LOGFILE 2>&1
/usr/bin/wget -O /lib/systemd/system/spms-mlat.service 'http://www.jurecka.net/spms/systemd/spms-mlat.service' >> $LOGFILE 2>&1
/usr/bin/wget -O /lib/systemd/system/spms-push-uat978.service 'http://www.jurecka.net/spms/systemd/spms-push-uat978.service' >> $LOGFILE 2>&1
/usr/bin/wget -O /lib/systemd/system/spms-uat978.service 'http://www.jurecka.net/spms/systemd/spms-uat978.service' >> $LOGFILE 2>&1

sudo chmod 644 /lib/systemd/system/spms*
sudo chown root:root /lib/systemd/system/spms*
#systemctl daemon-reload


//systemctl enable spms-push-uat978 >> $LOGFILE 2>&1
//systemctl enable spms-uat978 >> $LOGFILE 2>&1
systemctl enable spms-adsb >> $LOGFILE 2>&1
systemctl enable spms-mlat >> $LOGFILE 2>&1


systemctl stop spms-push-uat978 >> $LOGFILE 2>&1
systemctl stop spms-uat978 >> $LOGFILE 2>&1
systemctl stop spms-adsb >> $LOGFILE 2>&1
systemctl stop spms-mlat >> $LOGFILE 2>&1


###################################################################################
tee spms-push-uat.sh > /dev/null <<EOF
#!/bin/bash
while true
   do
      # Sleep first do that the parent comes up before we try to start to connect
      sleep 30
      /bin/nc localhost 30978 | /home/pi/spms/uat2esnt | /bin/nc mlat.rjr-services.com 41978
      echo 'Restarting DUMP978 PUSH '
   done
EOF

# Set execute permissions on the uat push maintenance script.

chmod +x spms-push-uat.sh >> $LOGFILE 2>&1

##################################################################

tee spms-uat.sh > /dev/null <<EOF
#!/bin/bash
while true
   do
      dump978-fa --sdr drive=rtlsdr,serial=00000978 --raw-port 30978 --json-port 30979
      echo 'Restarting DUMP978'
      sleep 30
   done
EOF

 # Set execute permissions on the uat maintenance script.

chmod +x spms-uat.sh >> $LOGFILE 2>&1

####################################################################
tee $INSTALLDIR/spms-mlat_maint.sh > /dev/null <<EOF
#!/bin/sh
while true
  do
    #Sleep for a while first before trying to connect to dump1090 and such
    sleep 30 
    /usr/bin/wget -O mlatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=${SPMSLOCATIONIDENTIFIER^^}&feed=M&event=U' > /dev/null 2>&1 &
    /usr/bin/mlat-client --input-type dump1090 --input-connect localhost:30005 --lat $RECEIVERLATITUDE --lon $RECEIVERLONGITUDE --alt $RECEIVERALTITUDE --user ${SPMSLOCATIONIDENTIFIER^^} --server mlat.rjr-services.com:30010 --no-udp --results beast,connect,localhost:30104
    /usr/bin/wget -O mlatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=${SPMSLOCATIONIDENTIFIER^^}&feed=M&event=D' > /dev/null 2>&1 &
  done
EOF

    echo 46
    sleep 0.25

    # Set execute permissions on the mlat-client maintenance script.
    chmod +x $INSTALLDIR/spms-mlat_maint.sh >> $LOGFILE 2>&1

#######################################################################

    echo 52
    sleep 0.25

    # Add a line to execute the mlat-client maintenance script to /etc/rc.local so it is started after each reboot if one does not already exist.
    #if ! grep -Fxq "$PWD/spms-mlat_maint.sh &" /etc/rc.local; then
    #    LINENUMBER=($(sed -n '/exit 0/=' /etc/rc.local))
    #    ((LINENUMBER>0)) && sudo sed -i "${LINENUMBER[$((${#LINENUMBER[@]}-1))]}i $PWD/spms-mlat_maint.sh &\n" /etc/rc.local >> $LOGFILE 2>&1
    #fi

    echo 58
    sleep 0.25

    echo "" >> $LOGFILE 2>&1
    echo " CREATE AND CONFIGURE NETCAT STARTUP SCRIPTS" >> $LOGFILE 2>&1
    echo "-------------------------------------------------" >> $LOGFILE 2>&1
    echo "" >> $LOGFILE 2>&1

    # Kill any currently running instances of the spms-mlat_maint.sh script.
    #PIDS=`ps -efww | grep -w "spms-mlat_maint.sh" | awk -vpid=$$ '$2 != pid { print $2 }'`
    #if [ ! -z "$PIDS" ]; then
    #    sudo kill $PIDS >> $LOGFILE 2>&1
    #    sudo kill -9 $PIDS >> $LOGFILE 2>&1
    #fi

    # Kill any currently running instances of the socat program.
    #PIDS=`ps -efww | grep -w "socat" | awk -vpid=$$ '$2 != pid { print $2 }'`
    #if [ ! -z "$PIDS" ]; then
    #    sudo kill $PIDS >> $LOGFILE 2>&1
    #    sudo kill -9 $PIDS >> $LOGFILE 2>&1
    #fi

    echo 64
    sleep 0.25

    # Execute the mlat-client maintenance script.
    sudo nohup $PWD/spms-mlat_maint.sh > /dev/null 2>&1 & >> $LOGFILE 2>&1

    echo 70
    sleep 0.25

    # SETUP NETCAT TO SEND DUMP1090 DATA TO SPMS 
    # Create the netcat maintenance script.

##################################################################################
     

tee spms-netcat_maint.sh > /dev/null <<EOF
#!/bin/sh
while true
  do
    #Sleep before trying to connect everything together.
    sleep 30 
    /usr/bin/wget -O netcatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=${SPMSLOCATIONIDENTIFIER^^}&feed=A&event=U' > /dev/null 2>&1 &
    /usr/bin/socat -u TCP:localhost:30005 TCP:mlat.rjr-services.com:$RECEIVERPORT
    /usr/bin/wget -O netcatstat 'http://mlat.rjr-services.com:1090/mlat/maint/status.php?station_id=${SPMSLOCATIONIDENTIFIER^^}&feed=A&event=D' > /dev/null 2>&1 &
  done
EOF

    echo 76
    sleep 0.25

    # Set permissions on the file spms-netcat_maint.sh.
    chmod +x spms-netcat_maint.sh >> $LOGFILE 2>&1

###################################################################################
    echo 82
    sleep 0.25

    # Add a line to execute the netcat maintenance script to /etc/rc.local so it is started after each reboot if one does not already exist.
    #if ! grep -Fxq "$PWD/spms-netcat_maint.sh &" /etc/rc.local; then
    #    lnum=($(sed -n '/exit 0/=' /etc/rc.local))
    #    ((lnum>0)) && sudo sed -i "${lnum[$((${#lnum[@]}-1))]}i $PWD/spms-netcat_maint.sh &\n" /etc/rc.local >> $LOGFILE 2>&1
    #fi

    echo 88
    sleep 0.25

    # Kill any currently running instances of the spms-netcat_maint.sh script.
    #PIDS=`ps -efww | grep -w "spms-netcat_maint.sh" | awk -vpid=$$ '$2 != pid { print $2 }'`
    #if [ ! -z "$PIDS" ]; then
    #    sudo kill $PIDS >> $LOGFILE 2>&1
    #    sudo kill -9 $PIDS >> $LOGFILE 2>&1
    #fi

    echo 94
    sleep 0.25

    # Execute the netcat maintenance script.
    #sudo nohup $PWD/spms-netcat_maint.sh > /dev/null 2>&1 & >> $LOGFILE 2>&1
    echo 100
    sleep 0.25

//systemctl start spms-push-uat978 >> $LOGFILE 2>&1
//systemctl start spms-uat978  >> $LOGFILE 2>&1 
systemctl start spms-adsb  >> $LOGFILE 2>&1
systemctl start spms-mlat  >> $LOGFILE 2>&1


} | whiptail --backtitle "$BACKTITLETEXT" --title "Setting Up SPMS Feed"  --gauge "\nSetting up your receiver to feed SPMS.\nThe setup process may take several minutes to complete.\nPerhaps upward of 5-10 minutes if this is the first run.\nGrab yourself a glass of iced tea and hit the restroom." 8 60 0

## SETUP COMPLETE


# Display the thank you message box.
whiptail --title "SPMS Setup Script" --msgbox "\nSetup is now complete.\n\nAfter 30 seconds, your feeder should be feeding data to the SPMS.\nThanks again for choosing to share your data with SPMS.\nIf you have questions or encountered any issues while using this script please contact meteojoe@gmail.com\n\nTo ensure you are feeding you should see three ESTAB entries to mlat.rjr-services.com\nusing the command:  netstat -a | grep rjr " 8 60 0
echo "\nSetup is now complete.\n\nAfter 30 seconds, your feeder should be feeding data to the SPMS.\nThanks again for choosing to share your data with SPMS.\nIf you have questions or encountered any issues while using this script please contact meteojoe@gmail.com\n\nTo ensure you are feeding you should see three ESTAB entries to mlat.rjr-services.com\nusing the command:  netstat -a | grep rjr "


exit 0
