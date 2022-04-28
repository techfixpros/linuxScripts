#!/bin/bash
tm=`/opt/vc/bin/vcgencmd measure_temp`
tc=`echo $tm| cut -d '=' -f2 | sed 's/..$//'`
tf=$(echo "scale=2;((9/5) * $tc) + 32" |bc)
echo $tc\%C \($tf\%F\)

