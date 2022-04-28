
===============================
   Install DESCRIPTION for RPi
===============================

1. Create a new directory by typing the command "mkdir /home/pi/modesfiltered" and 
   changed to it "cd /home/pi/modesfiltered".

2. Copy the zip-file to the newly created directory (from Windows use WINSCP).

3. Extract the files from zip-file: "unzip modesfiltered.zip".

4. Copy the start script "modes.sh" to /etc/init.d/. Command: "cp /home/pi/modesfiltered/modes.sh /etc/init.d/".

5. Make it executable by typing "sudo chmod +x /etc/init.d/modes.sh".

If you have already installed an older version, just change the filename
inside the script from modes.jar to modesfiltered.jar:

sudo nano /etc/init.d/modes.sh
exit with CTRL+O followed by CTRL+X

Configure

3. Edit variables.txt and add town and abbreviation for your country

location e.g.: Munich, DE

4. Check your local time by typing: date

5. Start the script with "sudo service modes start"

6. To always run the service at system start type "update-rc.d modes.sh defaults".


======================================================
   Install DESCRIPTION for PC with Microsoft Windows
======================================================

1. If not already done, install Java runtime (JRE 8 see https://www.java.com/de/download/).

2. Extract the zip to a new folder/directory.

3. Edit the file variables.txt by adding town and abbreviation for country.
e.g. Munich, DE

4. Start the program with run_modes.bat


=========================
   Changes
=========================

Release 26
- close, reopen sockets to dump1090-fa when no MSGs have been received for a while

Release 25
- open, close the connection to database for each report
- no autoreconnect
- Java Runtime 53 required, OpenJDK 11 JDK

Release 24
- use version 8 of mysql lib
- adapted script for check pid dump1090-fa

Release 23
- corrected time period for storing flights from 300 sec to 30 sec

Release 22

- adapted decoding of MSGs to new basestation output format of dump1090-fa

Release 21

- possible bug fixed with ban system
- improved evaluation of late type 1 and 5 messages with callsign
- removed aggressive option
- removed trimming of callsign
- database holds only messsages of type 1,  5 for callsign and 6 for squawk

Release 20

- MSG-5, 6 with callsign are reported as MSG-1
- fix: callsigns could have been copied to other reports
- minor changes to statistics report
- added limit for repeating reports and logging exceptions when lost connection to server

Release 19

only minor changes
- enhanced exception reporting
- used more brackets

Release 18

- fixed one bug regarding array index out of bounds

Release 17

- added check of pid dump1090 to start script
- slightly changed exception reports

Release 16

- improved startup order
- reduced timer rate to 2 s
- fixed possible deadlock

Release 15

- added parameter "-aggressive"
- reduced output to std.out
- increased message limit from 1000 to 10000 msg/s

Release 14

- removed debug output
- added batch file for Windows

Release 13

- fix: second filter stage, ignored callsigns with length > 3
- blacklist of callsigns updated
- added third port option
- some type 5 MSGs also contain callsign, if so use it
- hold back reports of type 5 messages up to 120 s to receive call sign

Release 12

- fixed an out of bounds error in filter stage 2

Release 11

- changed logging to std_out
- also report type 2 messages

Release 10

- use insert instead of update for MSG 7 altitude

Release 9

- removed TimeCreated from message type 3 reports

Release 8

- added parameter "-nosql" to log all reports to a local file when the station is off line

Release 7

- README
- default blacklist for call signs updated
- format check of MSG2 and MSG3 doesn't skip message anymore if geoAlt is missing

Release 5

- README
- sleep for 5 s when port exception has been thrown

Release 4

- README
- small changes of exceptions output

Release 3

- requeue Type5 MSGs only if SQLsyntaxErrorexception


Release 2

- use MLAT data of Piaware system (position data MSG type 3)
- added decoding of MSG type 2
- fixed decoding of some MSG types e.g. MSG 7 has no squawk
- added second filter stage based on callsigns

Goals:
- further reduce traffic from client to internet (interesting for mobile stations)


Release 1

modesfiltered.jar is based on modes.jar

- added arguments -host and -port
- logging option with argument -loginfo
- clear all MSG fields (altitude, squawk ...), when a new MSG arrived
- added filtering using a blacklist and a whitelist
- reworked ban system

Goals:
- reduce traffic from client to internet (interesting for mobile stations)
- reduce load of database server
- use saved resources to increase update interval for interesting flights

=========================
   Todo
=========================

- decode MSGs of types 4 and 8


=========================
  Detailed description
=========================

1) Filtering:

During start the program looks for the file named 'blacklist.txt'. It contains a list of comma separated HexIDs (first 3 positions of ICAO24 HexID).

Example: 3C4, 4CA, 484

You should adapt the list to your region!

If the first three symbols of a received message ICAO24 ID contains one of the IDs in the list, the message is ignored. This method can filter out a lot but not all of civil registrations.

For a station in Germany at Su 17-04-2016 from 20:00 to 22:00 hours 1301534 messages were received. With an adapted blacklist 773364 of it have been filtered out. This is nearly 60 percent.

Problem: false filtering of small government jets with civil registration. So be careful with adding HexIDs!

The second file is called 'whitelist.txt' and contains a list of comma separated HexIDs (first two positions of ICAO24 HexID) that we know of being interesting.

Example: 3E, 3F, AE, A3, AD, 3B, 4D, 43

You should adapt the list to your region!

Messages of type 3 (that contain position information) from planes whose IDs start with the symbols in the whitelist are sent to the server with a higher update rate of two minutes. For all other planes only the first message seen of each type (1, 3, 5, 6, 7) is sent to the server and all following messages are banned (ignored) for an hour. You can follow the behaviour of the ban system in the logs (if you redirect std-out or error-out to a log file).

The third file is called 'callsigns.txt' and contains a list of comma separated callsigns (first 3 positions of ICAO24 callsign) that will be filtered out.

Example: PGT, EZY, GWI, BER, NAX, AFL, KAL, KLM

After having received a message without callsign the program suspends processing of the message for 10 s. This procedure is repeated up to 6 times. So all in all the program waits 60 seconds for updates of the field callsign.
Just before sending the message to the SQL server, the program compares the value of this message to the callsigns list.

2) Statistics

Every 5 minutes there is a statistics output to stdout where you can check how many messages the station received.

3) Parameters

-host
usage = Host that provides the MSGs e.g. 127.0.0.1 for a local running dump1090. Default = 127.0.0.1
example: -host 192.168.0.13

-port
usage = port that provides MSGs e.g. for dump1090 it is 30003. Default = 30003
example: -port 30003

-port2
usage = second port that provides MSGs e.g. MLAT data from piaware dump1090 comes from 31003. Default = 30003
example: -port2 31003

-port3
usage = third port that provides MSGs e.g. MLAT data from adsb-exchange routed via 31004. Default = 30003
example: -port3 31004

-loginfo
usage = If set, program also logs INFO messages to stderr, otherwise only warnings. Default = false
example: -loginfo

-nosql
usage = If set, program logs type 1 and 5 messages to a file called loggedMSGs.csv. Default = false
example: -nosql



4) Forwarding Piaware MLAT position messages

If you want to forward Piaware MLAT positioning messages, you have to configure Piaware to open a port e.g. 31003:

sudo piaware-config -mlatResultsFormat "beast,connect,localhost:30104 basestation,listen,31003"

Restart piaware:

sudo service piaware restart

5) Permanently using certain options

edit line 12 of the start script "modes.sh" e.g.:

PROG="modesfiltered.jar -port 31003"

6) If you don't connect to DUMP1090 then replace the following lines in start script:

      if pidof dump1090; then
        echo "Checked dump1090 is running."
      else
        sleep 20
        # check one more time
        if pidof dump1090; then
          echo "Checked dump1090 is running."
        else
          # message only
          echo "No running dump1090 found."
        fi
      fi

by: sleep 20

7) Common error messages

"F: Connection refused"  a wrong port was supplied.

Forgot to open a port from piaware? Or maybe the program was started before dump1090?
Just restart with: "sudo service modes.sh restart"

"F: Connection timed out" a wrong host was supplied

"java: command not found" no Java installed. Try: "sudo apt-get update && sudo apt-get install oracle-java8-jdk" or openjdk-7-jre

8) Please give me feedback if you discover problems with modesfiltered! The forum would be the right place to do this.
