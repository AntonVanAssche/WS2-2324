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

$login = New-object `
    -TypeName System.Management.Automation.PSCredential `
    -ArgumentList "WS2-2324-anton.hogent\Administrator", (ConvertTo-SecureString -AsPlainText $pass -Force)

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
    Add-Computer -Domain "WS2-2324-anton.hogent" -Credential $login -Force
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
    D:setup.exe /q `
        /ACTION=Install `
        /FEATURES=SQL `
        /INSTANCENAME=MSSQLSERVER `
        /SQLSVCACCOUNT="WS2-2324-anton.hogent\Administrator" `
        /SQLSVCPASSWORD="$pass" `
        /SQLSYSADMINACCOUNTS="$pass" `
        /AGTSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE" `
        /SQLSVCINSTANTFILEINIT="True" `
        /IACCEPTSQLSERVERLICENSETERMS
} catch {
    Write-Error $("(Failed to install Exchange: "+ $_.Exception.Message)
}
