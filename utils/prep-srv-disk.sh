#!/bin/bash

# Configure an unused data disk to consume the full device and mount at /srv
MOUNT_POINT="/srv"
DATA_DISK_FS_TYPE="btrfs"

if [ "$EUID" -ne 0 ]; then
  SUDO="sudo"
else
  SUDO=""
fi

append_to_fstab() {
  local entry="$1"
  if [ -n "$SUDO" ]; then
    printf '%s\n' "$entry" | $SUDO tee -a /etc/fstab > /dev/null
  else
    printf '%s\n' "$entry" >> /etc/fstab
  fi
}

is_disk_available() {
  local disk="$1"

  if [ ! -b "$disk" ]; then
    return 1
  fi

  if lsblk -npo MOUNTPOINT "$disk" | grep -qv '^\s*$'; then
    return 1
  fi

  if lsblk -npo FSTYPE "$disk" | grep -qv '^\s*$'; then
    return 1
  fi

  return 0
}

find_unused_disk() {
  local attempt=0
  local max_attempts=30
  local disks

  while [ $attempt -lt $max_attempts ]; do
    mapfile -t disks < <(lsblk -dnpo NAME,TYPE | awk '$2 == "disk" {print $1}')

    for disk in "${disks[@]}"; do
      if is_disk_available "$disk"; then
        echo "$disk"
        return 0
      fi
    done

    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
      break
    fi

    echo "No unused data disk found. Retrying in 10 seconds..."
    sleep 10
  done

  echo "No unused data disk found after $max_attempts attempts. Exiting."
  return 1
}

DATA_DISK="$(find_unused_disk)"
if [ -z "$DATA_DISK" ]; then
  exit 1
fi

echo "Using data disk $DATA_DISK"

# Partition the disk if unpartitioned (use entire capacity)
if [ "$(lsblk -lnp "$DATA_DISK" | wc -l)" -le 1 ]; then
  echo "Creating a partition on $DATA_DISK"
  $SUDO parted "$DATA_DISK" --script mklabel gpt mkpart primary 0% 100%
  sleep 5
fi

PARTITION_NAME="$(lsblk -lnp "$DATA_DISK" | awk 'NR==2 {print $1}')"
if [ -z "$PARTITION_NAME" ]; then
  echo "Unable to determine partition name for $DATA_DISK"
  exit 1
fi

# Format the partition if it does not yet have a filesystem
if ! lsblk -lnf "$PARTITION_NAME" | awk '{if ($2 == "") exit 1}'; then
  echo "Formatting partition $PARTITION_NAME with $DATA_DISK_FS_TYPE"
  $SUDO mkfs.$DATA_DISK_FS_TYPE "$PARTITION_NAME"
fi

mkdir -p "$MOUNT_POINT"
if ! mountpoint -q "$MOUNT_POINT"; then
  $SUDO mount "$PARTITION_NAME" "$MOUNT_POINT"
fi

UUID=$(lsblk -no UUID "$PARTITION_NAME")
if [ -z "$UUID" ]; then
  echo "Unable to determine UUID for $PARTITION_NAME"
  exit 1
fi

if [ "$DATA_DISK_FS_TYPE" == "btrfs" ]; then
  $SUDO btrfs subvolume create "$MOUNT_POINT/subvolume"
  $SUDO umount "$MOUNT_POINT"
  $SUDO mount -o subvol=subvolume "$PARTITION_NAME" "$MOUNT_POINT"
  append_to_fstab "UUID=$UUID $MOUNT_POINT $DATA_DISK_FS_TYPE defaults,subvol=subvolume,nofail 0 2"
else
  append_to_fstab "UUID=$UUID $MOUNT_POINT $DATA_DISK_FS_TYPE defaults,nofail 0 2"
fi
