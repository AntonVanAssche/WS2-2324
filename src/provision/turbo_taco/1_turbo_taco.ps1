$interface_config = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.23.20"
    PrefixLength = "24"
    DefaultGateway = "192.168.23.1"
}

$dns_config = @{
    InterfaceAlias = "Ethernet"
    ServerAddresses = @("192.168.23.10", "192.168.23.30")
}

$pass = "Friday13th!"

try{
    New-NetIPAddress @interface_config
} catch {
    Write-Error $("(Failed to configuring network settings: "+ $_.Exception.Message)
}

try{
    Set-DnsClientServerAddress @dns_config
} catch {
    Write-Error $("(Failed to configuring DNS settings: "+ $_.Exception.Message)
}

try{
    $login = New-object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList "WS2-2324-anton.hogent\Administrator", (ConvertTo-SecureString -AsPlainText "Friday13th!" -Force)
    Add-Computer -hogentputerName TurboTaco `
        -DomainName WS2-2324-anton.hogent `
        -Credential $login `
        -Force
} catch {
    Write-Error $("(Failed to join domain: "+ $_.Exception.Message)
}

try {
    $mount_path = "F:\"
    # $config_path = "$mount_path\Files\Setup\config.xml"
    $config_path = "Z:\turbo_taco\files\config.xml"

    $prerequisites = "$mount_path\PrerequisiteInstaller.exe"

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

    Start-Process -FilePath "$prerequisites" `
        -Wait

    Start-Process -FilePath "$mount_path\setup.cmd" `
        -ArgumentList "/config $config_path" `
        -Wait
} catch {
    Write-Error $("(Failed to install SharePoint Server: "+ $_.Exception.Message)
}

try {
    Add-PSSnapin Microsoft.SharePoint.PowerShell

    $farm_config = @{
        DatabaseServer = "TofuTerminator"
        DatabaseName = "MSSQLSERVER"
        Passphrase = (ConvertTo-SecureString $pass -AsPlainText -force)
        AdministrationContentDatabaseName = "SharePoint_AdminContent"
        FarmCredentials = (Get-Credential "WS2-2324-anton\Administrator")
        LocalServerRole = "SingleServerFarm"
    }

    New-SPConfigurationDatabase @farm_config
} catch {
    Write-Error $("(Failed to create SharePoint Farm: "+ $_.Exception.Message)
}

try {
    Initialize-SPResourceSecurity
} catch {
    Write-Error $("(Failed to install SharePoint Resources: "+ $_.Exception.Message)
}

try {
    Install-SPService
} catch {
    Write-Error $("(Failed to install SharePoint Services: "+ $_.Exception.Message)
}

try {
    Install-SPFeature -AllExistingFeatures
} catch {
    Write-Error $("(Failed to install SharePoint Features: "+ $_.Exception.Message)
}

try {
    New-SPCentralAdministration -Port 2016 -WindowsAuthProvider NTLM
} catch {
    Write-Error $("(Failed to create Central Administration: "+ $_.Exception.Message)
}

try {
    Install-SPHelpCollection -All
} catch {
    Write-Error $("(Failed to install help: "+ $_.Exception.Message)
}

try {
    Install-SPApplicationContent
} catch {
    Write-Error $("(Failed to application content: "+ $_.Exception.Message)
}

try {
    New-NetFirewallRule -DisplayName "ICMPv4 Allow Ping" `
        -Direction Inbound `
        -Protocol ICMPv4 `
        -IcmpType 8 `
        -Action Allow
    New-NetFirewallRule -DisplayName "ICMPv6 Allow Ping" `
        -Direction Inbound `
        -Protocol ICMPv6 `
        -IcmpType 8 `
        -Action Allow
} catch {
    Write-Error $("(Failed to configure firewall: "+ $_.Exception.Message)
}

try {
    $AuthProvider = New-SPAuthenticationProvider `
        -UseWindowsIntegratedAuthentication `
        -DisableKerberos

    New-SPWebApplication `
        -Name "IntranetSite" `
        -Port 8080 `
        -HostHeader "intranet.WS2-2324-anton.hogent" `
        -URL "http://intranet.ws2-2324-anton.hogent/" `
        -ApplicationPool "IntranetAppPool" `
        -ApplicationPoolAccount (Get-SPManagedAccount "WS2-2324-ANTON\Administrator") `
        -DatabaseName "SP_ContentDB" `
        -DatabaseServer "TofuTerminator.WS2-2324-ANTON.hogent" `
        -AuthenticationProvider $AuthProvider `
        -Verbose
} catch {
    Write-Error $("(Failed to create web application: "+ $_.Exception.Message)
}

try {
    New-SPSite `
        -Url "http://intranet.ws2-2324-anton.hogent:8080/" `
        -OwnerAlias "WS2-2324-anton\Administrator" `
        -Template "STS#0" `
        -Verbose
} catch {
    Write-Error $("(Failed to create site collection: "+ $_.Exception.Message)
}
