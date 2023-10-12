#!/usr/bin/env bash

set -o errexit # Abort on nonzero exit code.
set -o nounset # Abort on unbound variable.
set -o pipefail # Don't hide errors within pipes.
# set -o xtrace   # Enable for debugging.

command -v virtualbox &> /dev/null || {
    printf 'Virtualbox not found in PATH. Adding Virtualbox bin-path to PATH environment variable.\n'
    export PATH=${PATH}:/usr/local/bin
}

[[ -f .env ]] && {
    printf 'Sourcing .env file...\n'
    # shellcheck disable=SC1091
    source .env
}

[[ -d "${HOME}/VirtualBox VMs/${VM_NAME}" ]] && {
    printf 'VM already exists. Exiting.\n' >&2
    exit 1
}

[[ -f "${ISO_PATH}" ]] || {
    printf 'ISO file not found. Exiting.\n' >&2
    exit 1
}

[[ -f "${GUEST_ADDITION_ISO_PATH}" ]] || {
    printf 'Guest Addition ISO file not found. Exiting.\n' >&2
    exit 1
}

[[ "${CPUS}" =~ ^[1-9]([0-9])?+$ ]] || {
    printf 'CPUS must be a positive integer. Exiting.\n' >&2
    exit 1
}

[[ "${MEMORY}" =~ ^[1-9]([0-9])?+$ ]] || {
    printf 'MEMORY must be a positive integer. Exiting.\n' >&2
    exit 1
}

[[ "${DISK_SIZE}" =~ ^[1-9]([0-9])?+$ ]] || {
    printf 'DISK_SIZE must be a positive integer. Exiting.\n' >&2
    exit 1
}

readonly VM_PATH="${HOME}/VirtualBox VMs/${VM_NAME}"

command -v vboxmanage &> /dev/null || {
    printf 'vboxmanage not found. Exiting.\n' >&2
    exit 1
}

vboxmanage createvm --name "${VM_NAME}" --ostype Windows2019_64 --register
vboxmanage modifyvm "${VM_NAME}" --cpus "${CPUS}" --memory "${MEMORY}" --boot1=disk --boot2=dvd
vboxmanage createmedium disk --filename "${VM_PATH}/${VM_NAME}.vdi" --size "${DISK_SIZE}"
vboxmanage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VM_PATH}/${VM_NAME}.vdi"
vboxmanage modifyvm "${VM_NAME}" --nic2 intnet --intnet2 "intnet"
vboxmanage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
vboxmanage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"

[[ -d "${HOME}/Shared" ]] || {
    printf 'Shared folder not found. Creating Shared folder...\n'
    mkdir -p "${HOME}/Shared"
}
vboxmanage sharedfolder add "${VM_NAME}" --name "Shared" --hostpath "${HOME}/Shared" --automount
vboxmanage unattended install "${VM_NAME}" --iso="${ISO_PATH}" --user="${USER_NAME}" --password="${USER_PASSWORD}" --additions-iso="${GUEST_ADDITION_ISO_PATH}" --install-additions --start-vm="gui" --post-install-command="shutdown /r /t 2"
vboxmanage startvm "${VM_NAME}" --type headless
