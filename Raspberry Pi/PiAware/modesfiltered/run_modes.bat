set PROG=modesfiltered.jar

REM set logfile
set LOGFILE=modes.log

REM set list of arguments
set ARG=-host 127.0.0.1

REM If you have different versions of java installed in parallel,
REM use full path e.g. "C:\Program Files\Java\jdk1.8.0_151\bin\java".
REM This also simplifies configuring firewall.
java -jar %PROG% %ARG% 1> %LOGFILE% 2>&1