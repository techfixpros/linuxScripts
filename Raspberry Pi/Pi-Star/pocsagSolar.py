## solar_index.py - Pull XML data from hamsql
## copy the solarflux value to a POCSAG msg and send via RemoteCommand or DAPNet
#
# John/KI5NYZ 2022
#
# Original script by Josh/KI6NAZ
# Adapted from youtube screenshot https://www.youtube.com/watch?v=XnyxwmMPX_g

import urllib3.request
import xmltodict
import subprocess
from datetime import datetime

callSign = "KI5NYZ"
rubric = "1082"

now = datetime.now()
dt_string = now.strftime("%m/%d/%y %H:%M:%S : ")
#print("Date and Time =", dt_string)
#print('----------------------')

http = urllib3.PoolManager()

url = 'http://www.hamqsl.com/solarxml.php'
response = http.request('GET',url)

#print(str(response.data))

doc = xmltodict.parse(str(response.data))
solarindex = doc['solar']['solardata']['solarflux']
aindex = doc['solar']['solardata']['aindex']
kindex = doc['solar']['solardata']['kindex']
sunspots = doc['solar']['solardata']['sunspots']

solarindexS = " Solar Index: {}".format(solarindex)
aindexS = " / A Index: {}".format(aindex)
kindexS = " / K Index: {}".format(kindex)
sunspotsS = " / Sunspots: {}".format(sunspots)

#print('Solar Index: ', solarindex)
#print('A Index: ', aindex)
#print('K Index: ', kindex)
#print('Sunspots: ', sunspots)
#print('----------------------')
#print(solarindexS)
#print(aindexS)
#print(kindexS)
#print(sunspotsS)

#Send Local
cmd = "sudo /usr/local/bin/RemoteCommand 7642 page " + rubric + solarindexS + aindexS + kindexS + sunspotsS

#Send DAPNet
#cmd = "sudo /usr/local/sbin/pistar-dapnetapi KI5NYZ 'Solar Index:'" + solarindex

process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

