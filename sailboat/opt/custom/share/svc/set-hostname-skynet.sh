#!/bin/bash

# Simple Ad Hoc SmartOS Set Hostname Service
 
set -o xtrace
 
. /lib/svc/share/smf_include.sh
 
cd /
PATH=/usr/sbin:/usr/bin:/opt/custom/bin:/opt/custom/sbin; export PATH
 
case "$1" in
'start')
    #### Insert code to execute on startup here.
 
    hostname "smartos.bethesda.us.hq.skynet" && hostname > /etc/nodename
 
    ;;
 
'stop')
    ### Insert code to execute on shutdown here.
    ;;
 
*)
    echo "Usage: $0 { start | stop }"
    exit $SMF_EXIT_ERR_FATAL
    ;;
esac
exit $SMF_EXIT_OK
