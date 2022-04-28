#!/bin/bash

# Build script for Xastir via git for Raspbian on a Raspberry Pi
# December 14, 2019 - applicable to the versions of Raspbian based
# on Debian 10 (Buster), Debian 9 (Stretch), Debian 8 (Jessie),
# or Debian 7 (Wheezy).

# First attempt at adding support for Buster - currently assumes 
# dependent packages for Buster are the same as those required 
# by Stretch


# check if user is in root mode and abort if yes
if [ "`whoami`" = "root" ]
then
  echo -e "\nPlease do not run this script as root."
  exit 1
fi

# Make sure it's a raspbian distribution
if ! grep -q "raspbian" /etc/apt/sources.list; then
  echo "This script applies only to the Raspbian distribution"
  exit 1
fi

if grep -q "8." /etc/debian_version; then
 # refresh repositories and grab Xastir dependencies
  sudo apt-get update || exit 1
  sudo apt-get -y install build-essential automake git xorg-dev libmotif-dev graphicsmagick gv libcurl4-openssl-dev shapelib libshp-dev libpcre3-dev libproj-dev libdb-dev python-dev libax25-dev libwebp-dev libgraphicsmagick1-dev festival festival-dev || exit 1
else
  if grep -q "7." /etc/debian_version; then 
    sudo apt-get -y install build-essential automake git xorg-dev lesstif2-dev graphicsmagick gv libxp-dev libcurl4-openssl-dev shapelib libshp-dev tcl8.4 gpsman gpsmanshp libpcre3-dev libproj-dev libdb5.1-dev python-dev libax25-dev libgraphicsmagick1-dev festival festival-dev || exit 1
  else
    if grep -q "9." /etc/debian_version; then
      sudo apt-get -y install build-essential automake git xorg-dev libmotif-dev graphicsmagick gv libcurl4-openssl-dev shapelib libshp-dev libpcre3-dev libproj-dev libdb-dev python-dev libax25-dev libwebp-dev libwebp-dev libgraphicsmagick1-dev festival festival-dev || exit 1
    else
      if grep -q "10." /etc/debian_version; then
        sudo apt-get -y install build-essential automake git xorg-dev libmotif-dev graphicsmagick gv libcurl4-openssl-dev shapelib libshp-dev libpcre3-dev libproj-dev libdb-dev python-dev libax25-dev libwebp-dev libwebp-dev libgraphicsmagick1-dev festival festival-dev || exit 1
      else
        echo "\nThis script applies only to Raspbian releases based on Debian 7.x thru 10.x\n\n"
        exit 1
      fi
    fi
  fi
fi

# create directories for source code, etc.
mkdir -p ~/src ; cd ~/src || exit 1
 
 # retrieve Xastir via git

#git clone https://github.com/Xastir/Xastir.git || exit 1
 
# execute the bootstrap shell script
#cd Xastir
#./bootstrap.sh
 
# create a build directory and configure
#mkdir build; cd build || exit 1
#../configure || exit 1
 
# compile and install
#make || exit 1
#sudo make install
