#!/bin/sh
# Prints VMs with nic ip

vmadm list -o uuid,type,ram,state,nics.0.ip,alias
