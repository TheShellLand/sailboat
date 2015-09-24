#!/usr/bin/env bash

function spec_kvm_iso_copy(){

  # Selects and copies an ISO to the KVM root for booting
  # e.g. Windows

  # Optional: Attaching virtio driver iso

  ISOS=/opt/custom/iso
  ISO=($(ls "$ISOS" | grep .iso))
  VIRTIOS=/opt/custom/iso/virtio
  VIRTIO=($(ls "$VIRTIOS" | grep .iso))

  while true; do
    vmadm list
    read -p "Set UUID of the new VM: " UUID
    if [ ! -z "$UUID" ]; then vmadm list | grep -w "$UUID"
      if [ $? == 0 ]; then
        vmadm stop "$UUID" -F
        break
        else echo "UUID not found. Check spelling and try again"; fi
    fi
  done
  echo ""

  echo "Select an ISO"
  select ANSWER in "${ISO[@]}"; do
    ISO="$ANSWER"
    echo ""
    echo Copying "$ISO" "==>" /zones/"$UUID"/root/
    echo ""
    rsync -ih --progress $ISOS/"$ISO" /zones/"$UUID"/root/
    break
  done
  echo ""

  echo "Boot?"
  select ANSWER in "Yes" "No"; do
    case $ANSWER in
      Yes)
        echo "Attach virtio ISO?"
        select ANSWER in "Yes" "No"; do
          case $ANSWER in
            Yes)
              echo "Select virtio iso"
              select ANSWER in "${VIRTIO[@]}"; do
                VIRTIO="$ANSWER"
                vmadm boot "$UUID" order=cd,once=d cdrom=/"$ISO",ide cdrom=/"$VIRTIO",ide
              done
              break ;;

            No) break ;;
          esac
        done

        vmadm boot "$UUID" order=cd,once=d cdrom=/"$ISO",ide
        break ;;
      No) break ;;
    esac
  done

  return $?

}

spec_kvm_iso_copy