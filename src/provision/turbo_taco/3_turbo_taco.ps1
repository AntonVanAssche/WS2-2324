try {
    $AuthProvider = New-SPAuthenticationProvider `
        -UseWindowsIntegratedAuthentication `
        -DisableKerberos

    New-SPWebApplication `
        -Name "IntranetSite" `
        -Port 8080 `
        -HostHeader "intranet.WS2-2324-anton.hogent" `
        -URL "http://intranet.ws2-2324-anton.hogent/" `
        -ApplicationPool "IntranetAppPool" `
        -ApplicationPoolAccount (Get-SPManagedAccount "WS2-2324-ANTON\Administrator") `
        -DatabaseName "SP_ContentDB" `
        -DatabaseServer "TofuTerminator.WS2-2324-ANTON.hogent" `
        -AuthenticationProvider $AuthProvider `
        -Verbose
} catch {
    Write-Error $("(Failed to create web application: "+ $_.Exception.Message)
}

try {
    New-SPSite `
        -Url "http://intranet.ws2-2324-anton.hogent:8080/" `
        -OwnerAlias "WS2-2324-anton\Administrator" `
        -Template "STS#0" `
        -Verbose
} catch {
    Write-Error $("(Failed to create site collection: "+ $_.Exception.Message)
}
