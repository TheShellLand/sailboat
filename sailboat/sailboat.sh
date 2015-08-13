#!/bin/bash
#
# Launch the sailboat!
#

# Version="1.0.0";
# Revision="0a";
# Script="sailboat.sh";



rootZone="zones"
requiredZones=("json" "iso")
sailboat="/usbkey/sailboat"



function _precheck() {

	cd $(dirname $0)

	# Check if sailboat does not exist
	if [ ! -d $sailboat ];
		then
			rsync -r ../sailboat /usbkey/ && cd .. && rm -r sailboat
			echo "[*] sailboat installed to /usbkey/sailboat"
			exit 0
	fi

	# Check if curr dir is sailboat
	if [ "$(pwd)" == $sailboat ];
		then
			return 0
	fi

	# Check if sailboats are the same
	if [ -d $sailboat ];
	then
		if [ ! "$(pwd)" == $sailboat ];
		then
			answer=
			read -p "$sailboat exists! replace? [y/N/overwrite]: " answer
			case $answer in
				y|Y) rsync -r --delete ../sailboat /usbkey/ && cd .. && rm -r sailboat
				echo "[*] Replaced $sailboat"
				exit 1
				;;

				overwrite|OVERWRITE) rsync -r ../sailboat /usbkey/ && cd .. && rm -r sailboat
				echo "[*] Overwrote $sailboat"
				exit 0
				;;

				n|N|*)
					echo "[*] exiting"
					exit 1
				;;
			esac;
			exit 1
		fi
	fi

}

function _go() {


	for (( index=0 ; index < ${#requiredZones[@]} ; index++ ));				# check for zfs dataset
		do if [ `zfs list $rootZone/${requiredZones[$index]} 2>/dev/null >/dev/null; echo $?` == 1 ]; 		# create dataset if not exist
				then zfs create $rootZone/${requiredZones[$index]};
					echo "[*] ${requiredZones[$index]} created"; fi; done;

	if [ -d $sailboat/zones ];												# copy zones
		then rsync -r $sailboat/zones/ /zones/;
			echo "[*] $sailboat/zones copied";

		else echo "[ERROR]"; exit 1; fi;


	if [ -d $sailboat/opt ];												# copy services
		then rsync -r $sailboat/opt/ /opt/;
			chmod o+x /opt/custom/share/svc/*
			echo "[*] $sailboat/opt copied";

		else echo "[ERROR]"; exit 1; fi;

}

function _gather() {


	if [ -d /$rootZone/json ];
		then if [ -d $sailboat ];
			then rsync -r --delete /$rootZone/json $sailboat/zones/;
				echo "[*] /$rootZone/json copied";

			else echo "[ERROR] $sailboat not found"; fi;

		else echo "[ERROR]"; exit 1; fi;

	if [ -d /opt/custom ];
		then if [ -d $sailboat ];
			then rsync -r --delete /opt $sailboat/;
				echo "[*] /opt copied";

			else echo "[ERROR]"; exit 1; fi;

		else echo "[ERROR]"; exit 1; fi;

}


_precheck

case $1 in
	go) _go
	;;

	get) _gather
	;;

	*)
	echo "usage $0 go get";
	echo ""
	echo "go	run script";
	echo "get	copy out";
	echo ""
	;;
esac;