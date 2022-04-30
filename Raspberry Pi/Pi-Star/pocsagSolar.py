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
import time
from datetime import datetime

callSign = "changeMe"
rubric1 = "changeMe"
rubric2= "changeMe"

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
snr = doc['solar']['solardata']['signalnoise']
muf = doc['solar']['solardata']['muf']

solarindexS = " Solar Index: {}".format(solarindex)
aindexS = " / A: {}".format(aindex)
kindexS = " / K: {}".format(kindex)
sunspotsS = " / Sunspots: {}".format(sunspots)
snrS = " / SNR: {}".format(snr)
mufS = " / MUF: {}".format(muf)

#print('Solar Index: ', solarindex)
#print('A Index: ', aindex)
#print('K Index: ', kindex)
#print('Sunspots: ', sunspots)
#print('SNR: ',snr)
#print('MUF: ', muf)
#print('----------------------')
#print(solarindexS)
#print(aindexS)
#print(kindexS)
#print(sunspotsS)
#print(snrS)
#print(mufS)

#Send Local
cmd = "sudo /usr/local/bin/RemoteCommand 7642 page " + rubric1 + solarindexS + aindexS + kindexS + sunspotsS + snrS + mufS

#time.sleep(5)

#cmd = "sudo /usr/local/bin/RemoteCommand 7642 page " + rubric2 +

#Send DAPNet
#cmd = "sudo /usr/local/sbin/pistar-dapnetapi changeMe 'Solar Index:'" + solarindexS + aindexS + kindexS + sunspotsS + snrS + mufS

process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

