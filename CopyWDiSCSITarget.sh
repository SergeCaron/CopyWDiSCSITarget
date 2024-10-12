#!/bin/sh

##******************************************************************
## Revision date: 2024.10.11
##
## Copyright (c) 2022-2024 PC-Évolution enr.
## This code is licensed under the GNU General Public License (GPL).
##
## THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
## ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
## IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
## PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
##
##******************************************************************

# This is part 1 of a two part process.
# Note: altough this is not important, presume the script is located in
#		any location that is preserved across a firmware update (such as /shares/Public)
#
# Open an SSH session on the source server and execute this script.
# On a Western Digital My_Book, the ssh user is "sshd"
# (typical "ssh -l sshd <My_Book>" where <My_Book> is the host name of the device.
# 

# Is iSCSI daemon running?
if [ ! -d "/sys/kernel/config/target/" ]; then
	echo "Enable iSCSI targets in the WD NAS GUI before attempting a copy."
	exit 911
fi

# Locate the iSCSI targets and enumerate
iSCSIimages=$(find /mnt -name iscsi_images)
if [[ -z "$iSCSIimages" ]]; then
   echo "The expected iSCSI targets directory is not found on this system."
   exit 911
fi
nTargets=$(ls -l $iSCSIimages | wc -l)
if [ $nTargets -lt 1 ]; then
	echo "At least one iSCSI target should be defined on this system."
	exit 911
fi
echo "iSCSI targets on this volume:"
ls -1 $iSCSIimages | sed -e s/.img// -e s/^/\ \ /
echo

#Select the iSCSI target to copy
read -p "Target name to copy: " Target
ls -l $iSCSIimages/$Target.img
if [ ! -f $iSCSIimages/$Target.img ]
  then echo "Target not found on this volume."
  exit 911
fi
echo

# Name of the destination server
read -p "Fully qualified host name of the destination server: " Remote
Junk=$(ping -c 1 $Remote)
if [ $? -ne 0 ]
  then echo "Unable to contact this remote server."
  exit 911
fi

# Create a mount point and connect to the destination's Public directory
mkdir /mnt/$Remote
mount -t cifs -o rw,username=root //$Remote/Public /mnt/$Remote
echo

# Copy source to destination
echo "Copy in progress ..."
date
cp $iSCSIimages/$Target.img /mnt/$Remote/$Target.img
date
echo

# Remove the mount point
umount /mnt/$Remote
rmdir /mnt/$Remote

# Hash the source AFTER the copy
echo "Hash the source AFTER the copy ..."
date
md5sum $iSCSIimages/$Target.img
date
