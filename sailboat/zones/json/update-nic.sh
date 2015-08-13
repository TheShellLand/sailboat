#!/bin/bash
# Update zone nic


function smartos_update_nic($TYPE){
    # UUID
    read -p "Enter UUID> " UUID

    # INTERFACE
    echo "[*] Existing interfaces"
    dladm show-vnic
    echo ""
    read -p "Enter existing (or new?) interface> " INTERFACE

    # MAC
    echo "[*] Current nics"
    vmadm get $UUID 2>/dev/null | json nics
    vmadm info $UUID 2>/dev/null | json nics
    echo ""
    read -p "Enter mac> " MAC

    # NIC_TAG
    echo "[*] Existing nic tags"
    nictagadm list
    echo ""
    read -p "Enter nic tag> " NIC_TAG


if [ $TYPE == DHCP ]; then
    # DHCP
    print '
        {
          "update_nics": [
            {
              "interface": "$INTERFACE",
              "mac": "$MAC",
              "nic_tag": "$NIC_TAG",
              "model": "virtio",
              "ip": "dhcp",
              "primary": true
            }
          ]
        }' | vmadm update $UUID
fi


if [ $TYPE == STATIC ]; then

    # IP
    read -p "IP Address> " IP_STATIC
    # NETMASK
    read -p "Netmask> " NETMASK
    # GATEWAY
    read -p "Gateway> " GATEWAY

    # Static IP
    print '
        {
          "update_nics": [
            {
              "interface": "$INTERFACE",
              "nic_tag": "$NIC_TAG",
              "ip": "$IP_STATIC",
              "netmask": "$NETMASK",
              "gateway": "$GATEWAY",
              "primary": true
            }
          ]
        }' | vmadm update $UUID
fi

}



# MAIN

select TYPE in "DHCP" "STATIC"; do
    case $TYPE in
        DHCP) smartos_update_nic(DHCP);;
        STATIC) smartos_update_nic(STATIC);;
    esac
done
