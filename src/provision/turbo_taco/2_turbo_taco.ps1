
try {
    $mount_path = "F:\"
    Start-Process -FilePath "$mount_path\setup.cmd" `
        -ArgumentList "/config $config_path" `
        -Wait
} catch {
    Write-Error $("(Failed to install SharePoint Server: "+ $_.Exception.Message)
}

try {
    Add-PSSnapin Microsoft.SharePoint.PowerShell
    $pass = "Friday13th!"
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