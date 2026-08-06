#!/bin/bash

echo 'Deleting old partitions in 5 seconds!!'
echo
echo 5
sleep 1
echo 4
sleep 1
echo 3
sleep 1
echo 2
sleep 1
echo 1
sleep 1
echo Wiping
wipefs -a /dev/nvme0n1
echo Wiped!
sync; sync

echo Creating new partition table
fdisk /dev/nvme0n1 << EOF
g
EOF
