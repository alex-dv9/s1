#!/bin/bash

if [ "$(whoami)" != "root" ]; then echo "[PERMISSIONS ERROR] PLEASE RUN THIS SCRIPT AS ROOT"; exit 1; fi
read -p "ARE YOU SURE? THIS SCRIPT IS UGLY HARD-CODED AND DANGEROUS!!! (Y/N): " u; [[ $u =~ ^[Yy]$ ]] || { exit 1; }

# ----------------------------------------------
echo "REMOVING FILESYSTEM(S) AND PARTITION TABLE(S) SIGNATURES USING WIPEFS"
wipefs --all /dev/sdc /dev/sda /dev/sdb /dev/nvme0n1

# ----------------------------------------------
echo "ZEROING FIRST AND LAST 5GB OF /DEV/SDC USING DD"
dd if=/dev/zero of=/dev/sdc bs=1M count=$(( 5*1024 ))
dd if=/dev/zero of=/dev/sdc bs=1M seek=$(( $(blockdev --getsize64 /dev/sdc)/1024/1024 - 5*1024 )) count=$(( 5*1024 ))

# ----------------------------------------------
echo "FORMATING REMAIN SOLID-STATE DRIVES USING BLKDISCARD"
blkdiscard --verbose /dev/sda
blkdiscard --verbose /dev/sdb
blkdiscard --verbose /dev/nvme0n1

# ----------------------------------------------
echo "FORMATING /DEV/NVME0N1 USING NVME (SECURE ERASE) JUST BECAUSE WE CAN"
nvme format /dev/nvme0 -s 2 -n 1
