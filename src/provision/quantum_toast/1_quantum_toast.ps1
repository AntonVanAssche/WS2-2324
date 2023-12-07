$interface_config = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.23.2"
    PrefixLength = "24"
}
$pass = "Friday13th!"

try{
    New-NetIPAddress @interface_config

} catch {
    Write-Host $("(Configuring network settings failed: "+ $_.Exception.Message)
}

Install-WindowsFeature -ConfigurationFilePath Z:\quantum_toast\files\quantum_toast_role_install_config.xml
Import-Module ADDSDeployment
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "WS2-2324-anton.hogent" `
    -DomainNetbiosName "WS2-2324-ANTON" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "$pass" -Force) `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVO" `
    -Force:$true
