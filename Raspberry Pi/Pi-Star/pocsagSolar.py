## pocsagSolar.py - Pull XML data from hamsql
## Parse XML to a POCSAG msg and send via RemoteCommand or DAPNet
#
# John/KI5NYZ 2022
#
# Original script by Josh/KI6NAZ
# Adapted from youtube screenshot https://www.youtube.com/watch?v=XnyxwmMPX_g

import urllib3.request
import xmltodict
import subprocess

callSign = "N0CALL"
rubric1 = "changeMe" # Solar Weather
rubric2= "changeMe" # Band Conditions

http = urllib3.PoolManager()

url = 'http://www.hamqsl.com/solarxml.php'
response = http.request('GET',url)

doc = xmltodict.parse(str(response.data))
solarindex = doc['solar']['solardata']['solarflux']
aindex = doc['solar']['solardata']['aindex']
kindex = doc['solar']['solardata']['kindex']
sunspots = doc['solar']['solardata']['sunspots']
snr = doc['solar']['solardata']['signalnoise']
muf = doc['solar']['solardata']['muf']

solarindex = " Solar Index: {}".format(solarindex)
aindex = " / A: {}".format(aindex)
kindex = " / K: {}".format(kindex)
sunspots = " / Sunspots: {}".format(sunspots)
snr = " / SNR: {}".format(snr)
muf = " / MUF: {}".format(muf)

d0 = doc['solar']['solardata']['calculatedconditions']['band'][0]
d1 = doc['solar']['solardata']['calculatedconditions']['band'][1]
d2 = doc['solar']['solardata']['calculatedconditions']['band'][2]
d3 = doc['solar']['solardata']['calculatedconditions']['band'][3]
n0 = doc['solar']['solardata']['calculatedconditions']['band'][4]
n1 = doc['solar']['solardata']['calculatedconditions']['band'][5]
n2 = doc['solar']['solardata']['calculatedconditions']['band'][6]
n3 = doc['solar']['solardata']['calculatedconditions']['band'][7]
v1 = doc['solar']['solardata']['calculatedvhfconditions']['phenomenon'][2]

for k, v in d0.items():
	d0 = v
for k, v in d1.items():
	d1 = v
for k, v in d2.items():
	d2 = v
for k, v in d3.items():
	d3 = v
for k, v in n0.items():
	n0 = v
for k, v in n1.items():
	n1 = v
for k, v in n2.items():
	n2 = v
for k, v in n3.items():
	n3 = v
for k, v in v1.items():
	v1 = v

d0 = " 80-40:{}".format(d0)
d1 = " 30-20:{}".format(d1)
d2 = " 17-15:{}".format(d2)
d3 = " 12-10:{}".format(d3)
n0 = " 80-40:{}".format(n0)
n1 = " 30-20:{}".format(n1)
n2 = " 17-15:{}".format(n2)
n3 = " 12-10:{}".format(n3)
v1 = " / VHF :{}".format(v1)

#Send Solar Weather via RemoteCommand
cmd = "sudo /usr/local/bin/RemoteCommand 7642 page " + rubric1 + solarindex + aindex + kindex + sunspots + snr + muf + v1
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

#Send Band Conditions via RemoteCommand
cmd = "sudo /usr/local/bin/RemoteCommand 7642 page " + rubric2 + d0 + d1 + d2 + d3 + n0 + n1 + n2 + n3
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

#Send Solar Weather via DAPNet
#cmd = "sudo /usr/local/sbin/pistar-dapnetapi changeMe 'Solar Index:'" + solarindex + aindex + kindex + sunspots + snr + muf + v1
#process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

#Send Band Conditions via DAPNet
#cmd = "sudo /usr/local/sbin/pistar-dapnetapi changeMe 'Conditions:'" + d0 + d1 + d2 + d3 + n0 + n1 + n2 + n3
#process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
