## pocsagSolar.py - Pull XML data from hamsql
## Parse XML to a POCSAG msg and send via RemoteCommand or DAPNet
#
# John/KI5NYZ 2022
#
# Original script by Josh/KI6NAZ
# Adapted from youtube screenshot https://youtu.be/XnyxwmMPX_g?t=323

import urllib3.request
import xmltodict
import subprocess

callsign = "N0CALL"
rubric1 = "1082" # Solar Weather
rubric2 = "1083" # Band Conditions

http = urllib3.PoolManager()

url = 'http://www.hamqsl.com/solarxml.php'
response = http.request('GET',url)

print("STEP: 1 - Parsing rubric1 XML")

doc = xmltodict.parse(str(response.data))
solarindex = doc['solar']['solardata']['solarflux']
aindex = doc['solar']['solardata']['aindex']
kindex = doc['solar']['solardata']['kindex']
sunspots = doc['solar']['solardata']['sunspots']
snr = doc['solar']['solardata']['signalnoise']
muf = doc['solar']['solardata']['muf']

print("STEP: 2 - Sending rubric1 to MQTT")

cmd = "mosquitto_pub -h altair.lan -t hamSolar/int/solarIndex -m " + solarindex
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/int/aIndex -m " + aindex
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/int/kIndex -m " + kindex
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/int/sunspots -m " + sunspots
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/snr -m " + snr
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/int/muf -m " + muf
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/muf -m " + muf
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

print("STEP: 3 - Formatting rubric1")

solarindex = "  SFI: {}".format(solarindex)
aindex = " / A: {}".format(aindex)
kindex = " / K: {}".format(kindex)
sunspots = " / Sunspots: {}".format(sunspots)
snr = " / SNR: {}".format(snr)
muf = " / MUF: {}".format(muf)

print("STEP: 4 - Parsing rubric2 XML")

d0 = doc['solar']['solardata']['calculatedconditions']['band'][0]
d1 = doc['solar']['solardata']['calculatedconditions']['band'][1]
d2 = doc['solar']['solardata']['calculatedconditions']['band'][2]
d3 = doc['solar']['solardata']['calculatedconditions']['band'][3]
n0 = doc['solar']['solardata']['calculatedconditions']['band'][4]
n1 = doc['solar']['solardata']['calculatedconditions']['band'][5]
n2 = doc['solar']['solardata']['calculatedconditions']['band'][6]
n3 = doc['solar']['solardata']['calculatedconditions']['band'][7]
v1 = doc['solar']['solardata']['calculatedvhfconditions']['phenomenon'][2]

print("STEP: 5 - Formatting rubric2 XML")

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

print("STEP: 6 - Sending rubric2 to MQTT")

cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/d8040 -m " + d0
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/d3020 -m " + d1
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/d1715 -m " + d2
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/d1210 -m " + d3
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/n8040 -m " + n0
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/n3020 -m " + n1
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/n1715 -m " + n2
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
cmd = "mosquitto_pub -h altair.lan -t hamSolar/str/n1210 -m " + n3
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
#cmd = "mosquitto_pub -h altair.lan -t hamSolar/vhf -m " + v1
#process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

print("STEP: 7 - Reformatting rubric2")

d0 = " 80-40:{}".format(d0)
d1 = " 30-20:{}".format(d1)
d2 = " 17-15:{}".format(d2)
d3 = " 12-10:{}".format(d3)
n0 = " 80-40:{}".format(n0)
n1 = " 30-20:{}".format(n1)
n2 = " 17-15:{}".format(n2)
n3 = " 12-10:{}".format(n3)
v1 = " / VHF: {}".format(v1)

#POCSAG

print("STEP: 8 - Display prepared POCSAG Message")

print(solarindex + kindex + aindex + sunspots + snr + muf + v1)
print(d0 + d1 + d2 + d3 + n1 + n2 + n3)

print("STEP: 9 - Transmitting POCSAG Message")

#Send Solar Weather via RemoteCommand
cmd = "sudo /usr/local/bin/RemoteCommand 7642 page " + rubric1 + solarindex + kindex + aindex + sunspots + snr + muf + v1
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

#Send Band Conditions via RemoteCommand
cmd = "sudo /usr/local/bin/RemoteCommand 7642 page " + rubric2 + d0 + d1 + d2 + d3 + n0 + n1 + n2 + n3
process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

#Send Solar Weather via DAPNet
#cmd = "sudo /usr/local/sbin/pistar-dapnetapi KI5NYZ 'Solar Index:'" + solarindex + kindex + aindex + sunspots + snr + muf + v1
#process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)

#Send Band Conditions via DAPNet
#cmd = "sudo /usr/local/sbin/pistar-dapnetapi KI5NYZ 'Band Conditions:'" + d0 + d1 + d2 + d3 + n0 + n1 + n2 + n3
#process = subprocess.call(cmd,stdout=subprocess.PIPE, shell=True)
