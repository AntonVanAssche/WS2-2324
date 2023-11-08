$interface_config = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.23.3"
    PrefixLength = "24"
}
$pass = "Friday13th!"

try{
    New-NetIPAddress @interface_config

} catch {
    Write-Host $("(Configuring network settings failed: "+ $_.Exception.Message)
}
