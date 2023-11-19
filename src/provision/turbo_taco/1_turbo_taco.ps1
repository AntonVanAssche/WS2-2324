$interface_config = @{
    InterfaceAlias = "Ethernet"
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
