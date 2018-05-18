#!/bin/bash
# nodemon 2.0

#Processing command line params
client=$1
client+=-cli
dir=$1
dir+=core
cd $1
if [ -z $2 ]; then datadir="/$USER/.$dir"; else datadir=.$2; fi   # Default datadir is /root/.coincore. Insert path if needed

if [ -z $3 ]; then dly=1; else dly=$3; fi   # Default refresh time is 1 sec


 
# Install jq if it's not present
dpkg -s jq 2>/dev/null >/dev/null || sudo apt-get -y install jq

#It is a one-liner script for now
watch -ptn $dly "echo '===========================================================================
Outbound connections to other nodes [datadir: $datadir]
===========================================================================
Node IP               Ping    Rx/Tx     Since  Hdrs   Height  Time   Ban
Address               (ms)   (KBytes)   Block  Syncd  Blocks  (min)  Score
==========================================================================='
./$client -datadir=$datadir getpeerinfo | jq -r '.[] | select(.inbound==false) | \"\(.addr),\(.pingtime*1000|floor) ,\
\(.bytesrecv/1024|floor)/\(.bytessent/1024|floor),\(.startingheight) ,\(.synced_headers) ,\(.synced_blocks)  ,\
\((now-.conntime)/60|floor) ,\(.banscore)\"' | column -t -s ',' && 
echo '==========================================================================='
uptime
echo '==========================================================================='
echo 'Masternode Status: \n# ./$client masternode status' && ./$client -datadir=$datadir masternode status
echo '==========================================================================='
echo 'Sync Status: \n# ./$client mnsync status' &&  ./$client -datadir=$datadir mnsync status
echo '==========================================================================='
echo 'Masternode Information: \n# ./$client getinfo' && ./$client -datadir=$datadir getinfo
echo '==========================================================================='
echo 'Usage: nodemonall.sh [coin] [refresh delay]'
echo 'Example: nodemonall.sh reef 10 will run every 10 seconds and query reefd in /$USER/.reefcore'
echo '\n\nPress Ctrl-C to Exit...'"
