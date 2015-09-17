#!/bin/bash
# Change SmartOS to use Static IP


# Version="1.0.0";
# Revision="0a";
# Script="change-to-static-ip.sh";


set -o xtrace

. /lib/svc/share/smf_include.sh

cd /
PATH=/usr/sbin:/usr/bin:/opt/custom/bin:/opt/custom/sbin; export PATH;

case "$1" in
    'start')
	#### Insert code to execute on startup here.
	# [*] $Script : Changing to Static IP
	ipadm delete-if e1000g0 && ipadm create-if e1000g0 && ipadm create-addr -T static -a 10.0.1.7/24 e1000g0/v4 && route add default 10.0.1.1 && echo "[OK]" || exit $SMF_EXIT_ERR_FATAL;
	;;
    
    'stop')
	### Insert code to execute on shutdown here.
	# [*] $Script : Changing to DHCP
	ipadm delete-if e1000g0 && ipadm create-if -t e1000g0 && ifconfig e1000g0 dhcp && echo "[OK]" || exit $SMF_EXIT_ERR_FATAL;
	;;
    
    *)
	echo "Usage: $0 { start | stop }"
	exit $SMF_EXIT_ERR_FATAL
	;;
esac
exit $SMF_EXIT_OK
