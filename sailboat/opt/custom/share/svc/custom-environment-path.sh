#!/bin/bash
# Add /opt/custom/bin to Environment PATH 


# Version="1.0.0";
# Revision="0b";
# Script="environment-path.sh";



set -o xtrace

. /lib/svc/share/smf_include.sh

cd /
PATH=/usr/sbin:/usr/bin:/opt/custom/bin:/opt/custom/sbin; export PATH;

case "$1" in
    'start')
	#### Insert code to execute on startup here.
	cat >> /root/.bash_profile <<EOF
export PATH=$PATH:/opt/custom/bin
EOF

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
