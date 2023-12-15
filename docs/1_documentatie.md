# Windows Server II - Documentatie

**Naam**: Anton Van Assche</br>
**Klas**: G3B

## Inhoudsopgave

1. [Opstelling](#opstelling)
    1. [VMs](#vms)
    2. [Topologie](#topologie)
2. [Ondervonden Problemen](#ondervonden-problemen)
3. [Huidige Status](#huidige-status)
4. [Conclusie](#conclusie)

# Opstelling <a name="opstelling"></a>

## VMs <a name="vms"></a>

| Hostname       | IP-adres      | OS                  | RAM  | CPU | NICs | Software           |
| :------------- | :------------ | :------------------ | :--- | :-- | :--- | :----------------- |
| QuantumToast   | 192.168.23.10 | Windows Server 2019 | 2 GB | 2   | 1    | AD, CA, DNS, DHCP  |
| TurboTaco      | 192.168.23.20 | Windows Server 2019 | 4 GB | 4   | 1    | Sharepoint         |
| TofuTerminator | 192.168.23.30 | Windows Server 2019 | 2 GB | 2   | 1    | SQL, DNS           |
| PC-1           | DHCP          | Windows 10          | 2 GB | 2   | 1    |                    |

QuantumToast is de Domain Controller, DNS en DHCP server. Doordat de Domain Controller rol standaar DNS bevat, heb ik ook DHCP te installeren. Zodat software i.v.m. het netwerk gegroepeeerd is.

TurboTaco is de Sharepoint en Certificate Authority server. Sharepoint is een webapplicatie, dus is het logisch dat deze op een webserver draait. De Certificate Authority is nodig om certificaten te maken voor de Sharepoint server. Doordat Sharepoint iets meer resources nodig heeft, heb ik deze server 4 GB RAM gegeven.

TofuTerminator is de SQL en DNS server. SQL is nodig voor Sharepoint, en DNS is slechts een backup voor QuantumToast.

PC-1 is een standaard Windows 10 machine, die via DHCP een IP-adres krijgt.

## Topologie <a name="topologie"></a>

![Topologie](./assets/topology.png)

De topologie bestaat uit 3 servers en 1 client, deze zijn verbonden aan een switch. Om ervoor te zorgen dat zowel de servers als de client kunnen surfen op het internet is deze switch verbonden aan een router, die op zijn beurt verbonden is aan de cloud/ISP.

| Hostname       | IP-adres      | Gateway       | Subnetmask    |
| :------------- | :------------ | :------------ | :------------ |
| QuantumToast   | 192.168.23.10 | 192.168.23.1  | 255.255.255.0 |
| TurboTaco      | 192.168.23.20 | 192.168.23.1  | 255.255.255.0 |
| TofuTerminator | 192.168.23.30 | 192.168.23.1  | 255.255.255.0 |
| PC-1           | DHCP          | DHCP          | 255.255.255.0 |

<div class="page"/>

# Ondervonden Problemen <a name="ondervonden-problemen"></a>

## Nat Network

Initieel gaf `ipconfig /all` na het configureren van `192.168.23.2` als statische IP-adres op QuantumToast aan dat het een `duplicate address` was.
Na het proberen van een hoger IP-adres (`192.168.23.11`), bleek het opgelost te zijn.

## Secondary DNS

Na het configureren van de secondary DNS op TofuTerminator, bleek dat de DNS server niet meer werkte.
Dit kwam doordat de Zone Transfer Policy niet correct was ingesteld.
Deze stond op `None`, maar moest op `Allow zone transfers` staan.

```powershell
Set-DnsServerPrimaryZone `
    -Name $dns_reverse_lookup_config.Name `
    -SecureSecondaries "TransferAnyServer"

Set-DnsServerPrimaryZone `
    -Name $dns_forward_lookup_config.Name `
    -SecureSecondaries "TransferAnyServer"
```

## SharePoint Server 2019 Prerequisites

### IIS Role

Tijdens het installeren van de prerequisites van SharePoint Server, kreeg ik steeds de volgende error, na het lezen van de logs:

```
2023-11-27 13:50:49 - Operating System: Windows 10
2023-11-27 13:50:49 - Processor architecture is (9)
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 - Common Startup
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
2023-11-27 13:50:49 - The value is...
2023-11-27 13:50:49 - C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
2023-11-27 13:50:49 - Trying to remove the startup task if there is any.
2023-11-27 13:50:49 - C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\SharePointServerPreparationToolStartup_0FF1CE14-0000-0000-0000-000000000000.cmd
2023-11-27 13:50:49 - Error: Startup task doesn't exist. This is not a continuation after a restart.
2023-11-27 13:50:49 - Locating the following command line arguments file:
2023-11-27 13:50:49 - F:\PrerequisiteInstaller.Arguments.txt
2023-11-27 13:50:49 - Error: This file does not exist
2023-11-27 13:50:49 - Details of the current operating system:
2023-11-27 13:50:49 - Major version number of the operating system:  (10)
2023-11-27 13:50:49 - Minor version number of the operating system:  (0)
2023-11-27 13:50:49 - Build number of the operating system:  (0X4563=17763)
2023-11-27 13:50:49 - Major version number of the latest Service Pack:  (0)
2023-11-27 13:50:49 - Minor version number of the latest Service Pack:  (0)
2023-11-27 13:50:49 - Platform ID of the operating system:  (2)
2023-11-27 13:50:49 - Product suites available on the operating system:  (0X110=272)
2023-11-27 13:50:49 - Product type of the operating system: VER_NT_SERVER
2023-11-27 13:50:49 - Product type:  (7)
2023-11-27 13:50:49 - OS type:  (0)
2023-11-27 13:50:49 - Configuring the application's property sheet...
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Microsoft .NET Framework 4.7.2
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 - Version
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Microsoft\Net Framework Setup\NDP\V4\full
2023-11-27 13:50:49 - The value is...
2023-11-27 13:50:49 - 4.7.03190
2023-11-27 13:50:49 - A higher version of the prerequisite above is already installed
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Microsoft Sync Framework Runtime v1.0 SP1 (x64)
2023-11-27 13:50:49 - Reading version of the following file...
2023-11-27 13:50:49 - C:\Windows\assembly\GAC_MSIL\Microsoft.Synchronization\1.0.0.0__89845dcd8080cc91\Microsoft.Synchronization.dll
2023-11-27 13:50:49 - GetFileVersionInfoSize failed (-2147024894)
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Microsoft SQL Server 2012 SP4 Native Client
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 - Version
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Microsoft\Microsoft SQL Server\SQLNCLI11\CurrentVersion
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Windows Server AppFabric
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 - ProductVersion
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Microsoft\AppFabric\V1.0
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Microsoft Identity Extensions
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 -
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Microsoft\Microsoft Identity Extensions\Setup\1.0
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Microsoft Information Protection and Control Client 2.1
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 -
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Microsoft\MSIPC\CurrentVersion
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Microsoft WCF Data Services 5.6
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 - Version
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Wow6432Node\Microsoft\Microsoft WCF Data Services\5.6
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Cumulative Update Package 7 for Microsoft AppFabric 1.1 for Windows Server (KB3092423)
2023-11-27 13:50:49 - Reading the following DWORD value/name...
2023-11-27 13:50:49 - IsInstalled
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Wow6432Node\Microsoft\Updates\AppFabric 1.1 for Windows Server\KB3092423
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Visual C++ Redistributable Package for Visual Studio 2012
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 - Version
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0\VC\Runtimes\x64
2023-11-27 13:50:49 - Check whether the following prerequisite is installed:
2023-11-27 13:50:49 - Visual C++ Redistributable Package for Visual Studio 2017
2023-11-27 13:50:49 - Reading the following string value/name...
2023-11-27 13:50:49 - Version
2023-11-27 13:50:49 - from the following registry location...
2023-11-27 13:50:49 - SOFTWARE\Wow6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64
2023-11-27 13:50:54 - Beginning download/installation
2023-11-27 13:50:54 - Created thread for installer
2023-11-27 13:50:54 - Installing windows server roles and features.
2023-11-27 13:50:54 - Preparing to run the following commands:
2023-11-27 13:50:54 - Param(
 [String]$logFile
)
Import-Module Servermanager
Start-Transcript -path $logFile
$operation = Install-WindowsFeature NET-HTTP-Activation,NET-Non-HTTP-Activ,NET-WCF-Pipe-Activation45,NET-WCF-HTTP-Activation45,Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-App-Dev,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-Net-Ext45,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Http-Tracing,Web-Security,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Mgmt-Tools,Web-Mgmt-Console,WAS,WAS-Process-Model,WAS-NET-Environment,WAS-Config-APIs,Windows-Identity-Foundation,Xps-Viewer -IncludeManagementTools -verbose
if ($operation.ExitCode -eq 'SuccessRestartRequired') {
  Stop-Transcript
  $host.SetShouldExit(3010)
}
elseif (!$operation.Success){
  Stop-Transcript
  $host.SetShouldExit(1000)
  exit
}
2023-11-27 13:50:54 - Logs for these operations will be available at:
2023-11-27 13:50:54 - "C:\Users\taco\AppData\Local\Temp\PreE6EA.tmp.PS1.log"
2023-11-27 13:50:54 - Executing PowerShell command:
2023-11-27 13:50:54 - "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass "C:\Users\taco\AppData\Local\Temp\PreE6EA.tmp.PS1 -logFile C:\Users\taco\AppData\Local\Temp\PreE6EA.tmp.PS1.log"
2023-11-27 13:50:55 - Request for install time of Web Server (IIS) Role
2023-11-27 13:50:56 - Request for install time of Web Server (IIS) Role
2023-11-27 13:50:57 - Request for install time of Web Server (IIS) Role
2023-11-27 13:50:58 - Request for install time of Web Server (IIS) Role
2023-11-27 13:50:59 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:00 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:01 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:02 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:02 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:03 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:04 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:05 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:06 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:07 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:08 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:09 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:10 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:11 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:11 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:12 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:13 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:14 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:15 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:16 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:17 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:18 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:19 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:20 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:21 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:22 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:23 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:24 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:25 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:26 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:27 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:28 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:29 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:30 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:31 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:32 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:33 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:34 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:36 - Request for install time of Web Server (IIS) Role
2023-11-27 13:51:36 - Install process returned (0X3E8=1000)
2023-11-27 13:51:36 - [In HRESULT format] (0X800703E8=-2147023896)
2023-11-27 13:51:36 - Last return code (0X3E8=1000)
2023-11-27 13:51:36 - Reading the following DWORD value/name...
2023-11-27 13:51:36 - Flags
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Microsoft\Updates\UpdateExeVolatile
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 - PendingFileRenameOperations
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SYSTEM\CurrentControlSet\Control\Session Manager
2023-11-27 13:51:36 - Reading the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired
2023-11-27 13:51:36 - Error: The tool was unable to install Web Server (IIS) Role.
2023-11-27 13:51:36 - Last return code (0X3E8=1000)
2023-11-27 13:51:36 - Options for further diagnostics: 1. Look up the return code value 2. Download the prerequisite manually and verify size downloaded by the prerequisite installer. 3. Install the prerequisite manually from the given location without any command line options.
2023-11-27 13:51:36 - Cannot retry
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Microsoft .NET Framework 4.7.2
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 - Version
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Microsoft\Net Framework Setup\NDP\V4\full
2023-11-27 13:51:36 - The value is...
2023-11-27 13:51:36 - 4.7.03190
2023-11-27 13:51:36 - A higher version of the prerequisite above is already installed
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Microsoft Sync Framework Runtime v1.0 SP1 (x64)
2023-11-27 13:51:36 - Reading version of the following file...
2023-11-27 13:51:36 - C:\Windows\assembly\GAC_MSIL\Microsoft.Synchronization\1.0.0.0__89845dcd8080cc91\Microsoft.Synchronization.dll
2023-11-27 13:51:36 - GetFileVersionInfoSize failed (-2147024894)
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Microsoft SQL Server 2012 SP4 Native Client
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 - Version
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Microsoft\Microsoft SQL Server\SQLNCLI11\CurrentVersion
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Windows Server AppFabric
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 - ProductVersion
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Microsoft\AppFabric\V1.0
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Microsoft Identity Extensions
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 -
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Microsoft\Microsoft Identity Extensions\Setup\1.0
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Microsoft Information Protection and Control Client 2.1
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 -
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Microsoft\MSIPC\CurrentVersion
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Microsoft WCF Data Services 5.6
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 - Version
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Wow6432Node\Microsoft\Microsoft WCF Data Services\5.6
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Cumulative Update Package 7 for Microsoft AppFabric 1.1 for Windows Server (KB3092423)
2023-11-27 13:51:36 - Reading the following DWORD value/name...
2023-11-27 13:51:36 - IsInstalled
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Wow6432Node\Microsoft\Updates\AppFabric 1.1 for Windows Server\KB3092423
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Visual C++ Redistributable Package for Visual Studio 2012
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 - Version
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0\VC\Runtimes\x64
2023-11-27 13:51:36 - Check whether the following prerequisite is installed:
2023-11-27 13:51:36 - Visual C++ Redistributable Package for Visual Studio 2017
2023-11-27 13:51:36 - Reading the following string value/name...
2023-11-27 13:51:36 - Version
2023-11-27 13:51:36 - from the following registry location...
2023-11-27 13:51:36 - SOFTWARE\Wow6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64
2023-11-27 13:51:43 - Opening log file
2023-11-27 13:51:43 - Opened action for user
2023-11-27 13:51:43 - C:\Users\taco\AppData\Local\Temp\PrerequisiteInstaller.2023.11.27-13.50.49.log
2023-11-27 13:52:52 - Opening log file
2023-11-27 13:52:52 - Opened action for user
2023-11-27 13:52:52 - C:\Users\taco\AppData\Local\Temp\PrerequisiteInstaller.2023.11.27-13.50.49.log
```

Dit was op te lossen door de volgende commando's uit te voeren in PowerShell:

```powershell
Add-WindowsFeature NET-WCF-HTTP-Activation45, `
    NET-WCF-TCP-Activation45, `
    NET-WCF-Pipe-Activation45
Import-Module ServerManager
Add-WindowsFeature Net-Framework-Features, `
    Web-Server, `
    Web-WebServer, `
    Web-Common-Http, `
    Web-Static-Content, `
    Web-Default-Doc, `
    Web-Dir-Browsing, `
    Web-Http-Errors, `
    Web-App-Dev, `
    Web-Asp-Net, `
    Web-Net-Ext, `
    Web-ISAPI-Ext, `
    Web-ISAPI-Filter, `
    Web-Health, `
    Web-Http-Logging, `
    Web-Log-Libraries, `
    Web-Request-Monitor, `
    Web-Http-Tracing, `
    Web-Security, `
    Web-Basic-Auth, `
    Web-Windows-Auth, `
    Web-Filtering, `
    Web-Digest-Auth, `
    Web-Performance, `
    Web-Stat-Compression, `
    Web-Dyn-Compression, `
    Web-Mgmt-Tools, `
    Web-Mgmt-Console, `
    Web-Mgmt-Compat, `
    Web-Metabase, `
    WAS, `
    WAS-Process-Model, `
    WAS-NET-Environment, `
    WAS-Config-APIs, `
    Web-Lgcy-Scripting, `
    Windows-Identity-Foundation, `
    Server-Media-Foundation, `
    Xps-Viewer `
    –Source D:\sources\sxs
```

Oplossing gevonden op: [https://vladtalkstech.com/2017/08/the-tool-was-unable-to-install-web-server-iis-role-sharepoint-2016-on-windows-server-2016.html](https://vladtalkstech.com/2017/08/the-tool-was-unable-to-install-web-server-iis-role-sharepoint-2016-on-windows-server-2016.html)

# Huidige Status <a name="huidige-status"></a>

Op QuantumToast is de Active Directory en de primaire DNS succesvol geïnstalleerd en gecofnigureerd.
De server zal zich gedragen als DNS forwarder, met als forwarder `8.8.8.8` (Google), en zal enkel zone transfers doen met TofuTerminator.
De DHCP server is geïnstalleerd, maar heeft een manuele configuratie nodig op het einde om alles door te voeren, na het automatisch configureren.
Deze zal de adressen `192.168.23.51` tot `192.168.23.100` uitdelen aan clients binnen het Nat Netwerk, zelfs als ze niet binnen het domein zitten.
De server zal ook de rol van CA op zich nemen, alleen is het mij niet gelukt om een SSL Certificate naar TurboTaco te sturen.

TofuTerminator is volledig geautomatiseerd, dit wil zeggen dat zowel SQL Server als de secundaire-DNS server gecofnigureerd worden tijdens het uitvoeren van het provision script.
TofuTerminator zal ook tijdens het uitvoeren van het script het domein: `WS2-2324-ANTON.hogent` joinen.
Het is mogelijk om via Microsoft SQL Server Management Studio te connecteren met de SQL server.

QuantumToast heeft wat meer dingen die niet werken, zo kan ik niet aan de aangemaakte site, ookal gebruik ik de juiste credentials.
De installatie van SharePoint werkt wel automatisch, al dan niet met enkele manuele interventies nodig.
Er wordt een Site en Site Collection volledig automatich aangemaakt, maar is helaas niet volledig correct aangezien ik er niet aan kan.
Zelfs niet na het toevoegen van de `CNAME` record op QuantumToast.
Bij het connecteren blijf ik in een oneindige lus zitten waar ik mijn inloggegevens moet ingeven.

Clients kunnen ook het domein joinen, maar dit moet manueel gebeuren.

# Conclusie <a name="conclusie"></a>

Ik vond het een tamelijk moeilijke opdracht, vooral het laatste deel (SharePoint).
Het aanmaken en automatiseren van een domein en primaire DNS-server is vrij straightforward, maar het configureren van de SharePoint server was een hele uitdaging.
Dit komt vooral doordat de documentatie van Microsoft niet altijd even duidelijk is, en het internet ook niet altijd even duidelijk is i.v.m. het onderwerp.
Ik heb ook het gevoel dat veel fixes nodig zijn om de vereisten te installeren vooraleer je SharePoint kan installeren.
Uiteindelijk heb ik dan eens geprobeerd om AutoSPInstaller te gebruiken, maar ook hier was er weinig documentatie over te vinden naar mijn mening.
Waardoor ik terug overgeschakeld ben naar zelf geschreven scripts.

De opdracht was wel handig om terug wat meer bezig te zijn mij PowerShell, iets wat ik vrij weinig doe.
Zo heeft het me iets meer details geleerd over de werking van een DNS forwarder en een DNS zone transfer.
Ook heb ik veel bijgelereerd over de werking van SharePoint, en hoe je deze kan installeren en configureren.
Ookal werkt dit deel niet 100% bij mij.

Tijdens het maken van deze opdracht heb ik veel tijd verloren aan SharePoint, maar ook aan een probleem i.v.m. NAT Netwerk binnen VirtualBox.
Initieel had ik niet goed genoeg de opdracht gelezen en dacht ik dat je een NAT adapter gecomineerd met een internal adapter netwerk moest gebruiken.
Wanneer ik dit doorhad en aangepast had, bleek dat ik IP-adresse had gekozen dat volgens de Network Address Duplicate detection van Windows al in gebruik waren, wat niet het geval was.
Dit heeft veel tijd gekost om uit te zoeken wat het probleem was en hoe ik het makkelijk kon oplossen.
