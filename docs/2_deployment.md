# Windows Server II - Deployment

Deze handleiding beschrijft het proces om Windows Server VMs automatisch aan te maken en configureren met behulp van het `unattended_install` script.

## Vereisten

-   Windows Server 2019 ISO
-   VirtualBox Guest Additions ISO

## Unattended Install

### 1.  Download ISO bestanden

Download het Windows Server ISO-bestand en het VirtualBox Guest Additions ISO-bestand en plaats ze op een toegankelijke locatie op de host machine.

### 2. Bewerk `.env` bestand

Creër een `.env` bestan in de `src/` folder en vul de volgende variabelen in:

**Opmerking**: Onderstaande configuratie is een voorbeeld voor de machine `QuantumToast`.

```console
# QuantumToast VM Configuration

VM_NAME="QuantumToast"
USER_NAME="toaster"
USER_PASSWORD="Friday13th!"

ISO_PATH="/home/anton/isos/en_windows_server_2019_x64_dvd_4cb967d8.iso"
GUEST_ADDITION_ISO_PATH="/home/anton/isos/VBoxGuestAdditions_7.0.6.iso"

CPUS="2"
MEMORY="2048"
DISK_SIZE="50000"
GUI="1"
```

**Opmerking**: Je kan de GUI parameter in het `.env` bestand aanpassen om te bepalen of de VM een desktopomgeving moet hebben (`GUI="1"`) of niet (`GUI="0"`).

### 3. Uitvoeren `unattended_install.sh`

Dit script zal een nieuwe VM aanmaken en configureren met behulp van de variabelen in het `.env` bestand.

```console
$ cd src/
$ ./unattended_install.sh
```

## Provisioning QuantumToast Server

Na het succesvol aanmaken van de QuantumToast VM, moet je de machine voorzien van de benodigde configuraties en software door de volgende stappen uit te voeren.

Zorg ervoor dat de execution policy van PowerShell is ingesteld op `unrestricted`:


```console
PS1> Set-ExecutionPolicy -ExecutionPolicy unrestricted
```

### 1. Navigeer naar de Provision Directory:

Navigeer naar de `Z` schijf van de VM en vervolgens de corresponderende folder, in dit geval `quantum_toast`. Dit is een sharedfoler die direct gelinkt staat aan de `provision` folder op de host machine.

```console
PS1> cd Z:\quantum_toast\
```

### 2. Uitvoeren `1_quantum_toast.ps1`

Voer het eerste provisioning script uit:

```console
PS1> .\1_quantum_toast.ps1
```

Dit script zal initiële configuraties uitvoeren en de machine opnieuw opstarten.

**Opmerking**: Zorg ervoor dat je de scripts uitvoert met administratieve privileges.

### 3. Herhaal de Stappen na de Reboot:

Nadat de machine opnieuw is opgestart, herhaal dezelfde stappen en navigeer naar `Z:\quantum_toast\`:

```console
PS1> cd Z:\quantum_toast\
```

### 4. Uitvoeren `2_quantum_toast.ps1`

Voer het tweede provisioning script uit:

```console
PS1> .\2_quantum_toast.ps1
```

Dit script zal aanvullende configuraties doorvoeren en de QuantumToast-server volledig provisionen.

**Opmerking**: Zorg ervoor dat je de scripts uitvoert met administratieve privileges.

## Provisioning TurboTaco Server

**WIP**

Standard trial product key: `F2DPD-HPNPV-WHKMK-G7C38-2G22J`

## Provisioning TofuTerminator Server

**WIP**
