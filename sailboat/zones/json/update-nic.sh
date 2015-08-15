#!/bin/bash
# SmartOS script for updating zone nic


function smartos_update_nic(){

    TYPE=$1

    # UUID
    echo "[*] List of VMs"
    vmadm list -o uuid,type,ram,state,nics.0.ip,alias
    read -p "Enter UUID> " UUID

    # INTERFACE
    echo "[*] Existing interfaces"
    dladm show-vnic
    INTERFACE=
    INTERFACE1=
    INTERFACE=$(vmadm get $UUID 2>/dev/null | json nics | json -a interface)
    INTERFACE1=$(vmadm get $UUID 2>/dev/null | json nics | json -a interface)
    if [ ! -z "$INTERFACE" ]; then INTERFACE=$INTERFACE; fi
    if [ ! -z "$INTERFACE1" ]; then INTERFACE=$INTERFACE1; fi
    echo ""
    read -p "Enter existing (or new) interface> ($INTERFACE) " NEWINTERFACE
    if [ ! -z "$NEWINTERFACE" ]; then INTERFACE=$NEWINTERFACE; fi

    # MAC
    echo "[*] Current nics"
    vmadm get $UUID 2>/dev/null | json nics
    vmadm info $UUID 2>/dev/null | json nics
    MAC=
    MAC1=
    MAC=$(vmadm get $UUID 2>/dev/null | json nics | json -a mac)
    MAC1=$(vmadm info $UUID 2>/dev/null | json nics | json -a mac)
    echo ""
    if [ ! -z "$MAC" ]; then MAC=$MAC; fi
    if [ ! -z "$MAC1" ]; then MAC=$MAC1; fi
    read -p "Enter mac> ($MAC) " NEWMAC
    if [ ! -z "$NEWMAC" ]; then MAC=$NEWMAC; fi

    # NIC_TAG
    echo "[*] Existing nic tags"
    nictagadm list
    NIC_TAG=
    NIC_TAG1=
    NIC_TAG=$(vmadm get $UUID 2>/dev/null | json nics | json -a nic_tag)
    NIC_TAG1=$(vmadm info $UUID 2>/dev/null | json nics | json -a nic_tag)
    echo ""
    if [ ! -z "$NIC_TAG" ]; then NIC_TAG=$NIC_TAG; fi
    if [ ! -z "$NIC_TAG1" ]; then NIC_TAG=$NIC_TAG1; fi 
    read -p "Enter nic tag> ($NIC_TAG) " NEWNIC_TAG
    if [ ! -z "$NEWNIC_TAG" ]; then NIC_TAG=$NEWNIC_TAG; fi


if [ $TYPE == DHCP ]; then
    # DHCP
    print "
        {
          \"update_nics\": [
            {
              \"interface\": \"$INTERFACE\",
              \"mac\": \"$MAC\",
              \"nic_tag\": \"$NIC_TAG\",
              \"model\": \"virtio\",
              \"ip\": \"dhcp\",
              \"primary\": true
            }
          ]
        }" | vmadm update $UUID
fi


if [ $TYPE == STATIC ]; then

    # IP
    read -p "IP Address> " IP_STATIC
    # NETMASK
    read -p "Netmask> " NETMASK
    # GATEWAY
    read -p "Gateway> " GATEWAY

    # Static IP
    print "
        {
          \"update_nics\": [
            {
              \"interface\": \"$INTERFACE\",
              \"nic_tag\": \"$NIC_TAG\",
              \"ip\": \"$IP_STATIC\",
              \"netmask\": \"$NETMASK\",
              \"gateway\": \"$GATEWAY\",
              \"primary\": true
            }
          ]
        }" | vmadm update $UUID
fi

echo "[*] New nic"
vmadm get $UUID 2>/dev/null | json nics
vmadm info $UUID 2>/dev/null | json nics

exit 0

}



# MAIN

select TYPE in "DHCP" "STATIC"; do
    case $TYPE in
        DHCP) smartos_update_nic DHCP ;;
        STATIC) smartos_update_nic STATIC ;;
    esac
done
