#!/usr/bin/env bash

set -o errexit # Abort on nonzero exit code.
set -o nounset # Abort on unbound variable.
set -o pipefail # Don't hide errors within pipes.
# set -o xtrace   # Enable for debugging.

# Script to install Windows Server 2019 on Virtualbox

# Add Virtual Box bin-path to PATH environment variable if necessary:
command -v virtualbox &> /dev/null || {
    printf 'Virtualbox not found in PATH. Adding Virtualbox bin-path to PATH environment variable.\n'
    export PATH=${PATH}:/usr/local/bin
}

# Variables
read -r -p "Enter the name of the VM: " VM_NAME
read -r -p "Enter the name of the user: " USER_NAME
read -r -s -p "Enter the password of the user: " USER_PASSWORD1

printf '\n'
read -r -s -p "Enter the password of the user again: " USER_PASSWORD2
[[ "${USER_PASSWORD1}" == "${USER_PASSWORD2}" ]] || {
    printf 'Passwords do not match. Exiting.\n' >&2
    exit 1
}
printf '\n'

readonly USER_PASSWORD="${USER_PASSWORD1}"

read -r -p "Enter the path to the ISO file: " ISO_PATH
read -r -p "Enter the path to the GUEST ADDITION ISO file: " GUEST_ADDITION_ISO_PATH

# Create VM
[[ -d "${HOME}/VirtualBox VMs/${VM_NAME}" ]] && {
    printf 'VM already exists. Exiting.\n' >&2
    exit 1
}

[[ -f "${ISO_PATH}" ]] || {
    printf 'ISO file not found. Exiting.\n' >&2
    exit 1
}

readonly VM_PATH="${HOME}/VirtualBox VMs/${VM_NAME}"

printf 'Creating VM...\n'
command -v vboxmanage &> /dev/null || {
    printf 'vboxmanage not found. Exiting.\n' >&2
    exit 1
}

vboxmanage createvm --name "${VM_NAME}" --ostype Windows2019_64 --register

# Configure VM
printf 'Configuring VM...\n'
vboxmanage modifyvm "${VM_NAME}" --cpus 2 --memory 2048 --boot1=disk --boot2=dvd

# Create disk
printf 'Creating disk...\n'
vboxmanage createmedium disk --filename "${VM_PATH}/${VM_NAME}.vdi" --size 50000

# Attach disk
printf 'Attaching disk...\n'
vboxmanage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VM_PATH}/${VM_NAME}.vdi"

# Add Internal Network
printf 'Adding Internal Network...\n'
vboxmanage modifyvm "${VM_NAME}" --nic2 intnet --intnet2 "intnet"

# Attach ISO
printf 'Attaching ISO...\n'
vboxmanage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
vboxmanage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"

# Create Shared Folder
printf 'Creating Shared Folder...\n'

[[ -d "${HOME}/Shared" ]] || {
    printf 'Shared folder not found. Creating Shared folder...\n'
    mkdir -p "${HOME}/Shared"
}
vboxmanage sharedfolder add "${VM_NAME}" --name "Shared" --hostpath "${HOME}/Shared" --automount

# Unattended Install
printf 'Starting Unattended Install...\n'
vboxmanage unattended install "${VM_NAME}" --iso="${ISO_PATH}" --user="${USER_NAME}" --password="${USER_PASSWORD}" --additions-iso="${GUEST_ADDITION_ISO_PATH}" --install-additions --start-vm="gui" --post-install-command="shutdown /r /t 2"

# Start VM
printf 'Starting VM...\n'
vboxmanage startvm "${VM_NAME}" --type headless