#!/bin/env bash
# qemu-system-x86_64 \
#   -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
#   -smp 4 \
#   -enable-kvm \
#   -hda ~/win7x64.qcow \
#   -m 2048 \
#   -name "Windows" \
#   -net nic -net user,hostname=windowsvm,smb=$HOME/win \
#   "$@"
#  -boot d \
#  -cdrom ~/downloads/win7x64lite.iso \
#  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
#  -smp 4 \
#  -machine type=q35,accel=kvm \
#  -net nic -net user,hostname=windowsvm
#  -vga std \

qemu-system-x86_64 \
  -vga qxl \
  -device virtio-serial-pci \
  -spice port=5930,disable-ticketing=on \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -display spice-app \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 4 \
  -enable-kvm \
  -hda $HOME/win7x64.qcow2 \
  -m 2048 \
  -name "Windows" \
  -net nic -net user,hostname=windowsvm,smb=$HOME/samba \
  "$@"

