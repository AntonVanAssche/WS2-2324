$interface_config = @{
    InterfaceAlias = "Ethernet adapter Ethernet 2"
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
    New-Item -Path C:\SQLServerDownload -ItemType Directory
    Copy-Item -Path D:\* -Destination C:\SQLServer\ -Recurse
} catch {
    Write-Error $("(Failed to copy SQL Server installation files: "+ $_.Exception.Message)
}

try {
    Get-PackageProvider -Name NuGet –ForceBootstrap
    Install-Module -Name SqlServerDsc -Force
} catch {
    Write-Error $("(Failed to install SQL Server DSC: "+ $_.Exception.Message)
}

# try {
#     z:\tofu_terminator\files\sql_server_config.ps1
# } catch {
#     Write-Error $("(Failed to configure SQL Server: "+ $_.Exception.Message)
# }

try {
    Start-DscConfiguration -Path z:\tofu_terminator\files\sql_server_config.ps1 -Wait -Verbose
} catch {
    Write-Error $("(Failed to install SQL Server: "+ $_.Exception.Message)
}
