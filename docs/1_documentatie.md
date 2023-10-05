# Windows Server II - Documentatie

## Inhoudsopgave

1. [Inleiding](#inleiding)
2. [Opstelling](#opstelling)
    1. [VMs](#vms)
    2. [Topologie](#topologie)

# Inleiding <a name="inleiding"></a>

<div class="page"/>

# Opstelling <a name="opstelling"></a>

## VMs <a name="vms"></a>

| Hostname       | IP-adres     | OS                  | RAM  | CPU | NICs | Software       |
| :------------- | :----------- | :------------------ | :--- | :-- | :--- | :------------- |
| QuantumToast   | 192.168.23.1 | Windows Server 2019 | 2 GB | 2   | 1    | AD, DNS, DHCP  |
| TurboTaco      | 192.168.23.2 | Windows Server 2019 | 4 GB | 4   | 1    | Sharepoint, CA |
| TofuTerminator | 192.168.23.3 | Windows Server 2019 | 2 GB | 2   | 1    | SQL, DNS       |
| PC-1           | DHCP         | Windows 10          | 2 GB | 2   | 1    |                |

QuantumToast is de Domain Controller, DNS en DHCP server. Doordat de Domain Controller rol standaar DNS bevat, heb ik ook DHCP te installeren. Zodat software i.v.m. het netwerk gegroepeeerd is.

TurboTaco is de Sharepoint en Certificate Authority server. Sharepoint is een webapplicatie, dus is het logisch dat deze op een webserver draait. De Certificate Authority is nodig om certificaten te maken voor de Sharepoint server. Doordat Sharepoint iets meer resources nodig heeft, heb ik deze server 4 GB RAM gegeven.

TofuTerminator is de SQL en DNS server. SQL is nodig voor Sharepoint, en DNS is slechts een backup voor QuantumToast.

PC-1 is een standaard Windows 10 machine, die via DHCP een IP-adres krijgt.

## Topologie <a name="topologie"></a>

![Topologie](./assets/topology.png)

De topologie bestaat uit 3 servers en 1 client, deze zijn verbonden aan een switch. Om ervoor te zorgen dat zowel de servers als de client kunnen surfen op het internet is deze switch verbonden aan een router, die op zijn beurt verbonden is aan de cloud/ISP.

| Hostname       | IP-adres     | Gateway      | Subnetmasker  |
| :------------- | :----------- | :----------- | :------------ |
| QuantumToast   | 192.168.23.1 | 192.168.23.1 | 255.255.255.0 |
| TurboTaco      | 192.168.23.2 | 192.168.23.1 | 255.255.255.0 |
| TofuTerminator | 192.168.23.3 | 192.168.23.1 | 255.255.255.0 |
| PC-1           | DHCP         | DHCP         | 255.255.255.0 |

<div class="page"/>
