#!/bin/sh

##******************************************************************
## Revision date: 2024.03.21
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

# This is part 2 of a two part process.
# Note: altough this is not important, presume the script is located in
#		any location that is preserved across a firmware update (such as /shares/Public)
#
# Open an SSH session on the source server and execute this script.
# On a Western Digital My_Book, the ssh user is "sshd"
# (typical "ssh -l sshd <My_Book>" where <My_Book> is the host name of the device.
# 

# Locate the iSCSI targets and enumerate
iSCSIimages=$(find /mnt -name iscsi_images)
echo "iSCSI targets on this volume:"
ls -1 $iSCSIimages | sed -e s/.img// -e s/^/\ \ /
echo

# Enumerate the iSCSI targets in the Public
echo "iSCSI targets on this Public share:"
ls -1 /shares/Public/*.img | sed -e s?/shares/Public/?? -e s/.img// -e s/^/\ \ /
echo

#Select the iSCSI target to move
read -p "Target name to move: " Target
ls -l /shares/Public/$Target.img
if [ -f $iSCSIimages/$Target.img ]
  then echo "Target already exist on this server."
  exit 911
fi
echo

# Hash the source BEFORE the move
echo "Hash the destination BEFORE the move ..."
date
md5sum /shares/Public/$Target.img
date
echo

# Replace security attributes
chown root:root /shares/Public/$Target.img
chmod 666 /shares/Public/$Target.img

# Move this file and enumerate iSCSI targets
mv /shares/Public/$Target.img $iSCSIimages/
echo "iSCSI targets on this volume:"
ls -1 $iSCSIimages | sed -e s/.img// -e s/^/\ \ /
echo
