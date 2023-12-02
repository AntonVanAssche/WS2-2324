$interface_config = @{
    InterfaceAlias = "Ethernet adapter Ethernet 2"
    IPAddress = "192.168.23.3"
    PrefixLength = "24"
}

$dns_config = @{
    InterfaceAlias = "Ethernet"
    ServerAddresses = @("192.168.23.2")
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
    Add-Computer -ComputerName TurboTaco `
        -LocalCredential taco\Administrator `
        -DomainName WS2-2324-anton.hogent `
        -Credential WS2-2324-anton.hogent\Administrator `
        -Force
} catch {
    Write-Error $("(Failed to join domain: "+ $_.Exception.Message)
}

try {
    $mount_path = "F:\"
    $config_path = "$mount_path\Files\Setup\config.xml"

    $prerequisites = "$mount_path\PrerequisiteInstaller.exe"

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
        -Passphrase (ConvertTo-SecureString "MyP@ssw0rd" -AsPlainText -Force)
    Start-Service SPTimerv4
} catch {
    Write-Error $("(Failed to configure SharePoint Server: "+ $_.Exception.Message)
}
