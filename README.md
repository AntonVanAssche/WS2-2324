# Assignment Windows Server II - 2023-2024

**.env file**:

Here is an example of an `.env` file that will be used by the `unattended_install.sh` script, to create a new Windows virtual machine.

```bash
VM_NAME=""
USER_NAME=""
USER_PASSWORD=""

ISO_PATH=""
GUEST_ADDITION_ISO_PATH=""

CPUS="2"
MEMORY="2048"
DISK_SIZE="50000"
GUI="0"                     # Select 1 for a "Desktop Experience" VM
```
