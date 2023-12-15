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
    Add-Computer -ComputerName TurboTaco `
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
} catch {
    Write-Error $("(Failed to install SharePoint Server Prerequisites: "+ $_.Exception.Message)
}
