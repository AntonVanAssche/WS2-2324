$interface_config = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.23.3"
    PrefixLength = "24"
    DefaultGateway = "192.168.23.1"
}

$dns_config = @{
    InterfaceAlias = "Ethernet"
    ServerAddresses = @("192.168.23.2", "192.168.23.3")
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
        -ArgumentList "WS2-2324-anton\Administrator", (ConvertTo-SecureString -AsPlainText "Friday13th!" -Force)
    Add-Computer -ComputerName TurboTaco `
        -DomainName WS2-2324-anton.hogent `
        -Credential $login `
        -Force
} catch {
    Write-Error $("(Failed to join domain: "+ $_.Exception.Message)
}

try {
    $mount_path = "F:\"
    $config_path = "$mount_path\Files\Setup\config.xml"

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
    $db_config = @{
        DatabaseServer = "192.168.23.4"
        DatabaseName = "MSSQLSERVER"
        FarmCredentials = (Get-Credential)
        Passphrase = "$pass"
    }

    Connect-SPConfigurationDatabase -DatabaseServer "TofuTerminator" `
        -DatabaseName "MYSQLSERVER" `
        -Passphrase (ConvertTo-SecureString "$pass" -AsPlainText -Force)
    Start-Service SPTimerv4
} catch {
    Write-Error $("(Failed to configure SharePoint Server: "+ $_.Exception.Message)
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
