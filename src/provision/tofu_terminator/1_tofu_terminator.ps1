$interface_config = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.23.4"
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
    Add-Computer -ComputerName TofuTerminator `
        -LocalCredential terminator\Administrator `
        -DomainName WS2-2324-anton.hogent `
        -Credential WS2-2324-anton.hogent\Administrator `
        -Force
} catch {
    Write-Error $("(Failed to join domain: "+ $_.Exception.Message)
}

try {
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Install-Module -Name DnsServer
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Install-DnsServer -NoReboot -Force

    Add-DnsServerPrimaryZone `
        -Name "WS2-2324-anton.hogent" `
        -ZoneFile "WS2-2324-anton.hogent.dns" `
        -ReplicationScope "Forest"

    Set-DnsServerPrimaryZone `
        -Name "WS2-2324-anton.hogent" `
        -MasterServers $dns_config.ServerAddresses `
        -ReplicationScope "Forest"
} catch {
    Write-Error $("(Failed to configure server as secondary DNS: "+ $_.Exception.Message)
}

try {
    D:setup.exe /QS `
        /SQLSVCPASSWORD=$pass `
        /ASSVCPASSWORD=$pass `
        /ACTION=Install `
        /ConfigurationFile="Z:\tofu_terminator\files\sql_server_config.ini"
} catch {
    Write-Error $("(Failed to install Exchange: "+ $_.Exception.Message)
}

try {
    New-NetFirewallRule -DisplayName "SQLServer default instance" `
        -Direction Inbound `
        -LocalPort 1433 `
        -Protocol TCP `
        -Action Allow
    New-NetFirewallRule -DisplayName "SQLServer Browser service" `
        -Direction Inbound `
        -LocalPort 1434 `
        -Protocol UDP `
        -Action Allow
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
