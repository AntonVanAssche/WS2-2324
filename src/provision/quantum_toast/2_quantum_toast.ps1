$interface_config = @{
    InterfaceAlias = "Ethernet adapter Ethernet 2"
    IPAddress = "192.168.23.10"
    SubnetMask = "255.255.255.0"
}
$dns_forward_lookup_config = @{
    Name = "WS2-2324-anton.hogent"
    ReplicationScope = "Forest"
    ZoneFile = "WS2-2324-anton.hogent.dns"
    PassThru = $true
}
$dns_reverse_lookup_config = @{
    Name = "23.168.192.in-addr.arpa"
    ReplicationScope = "Forest"
    ZoneFile = "23.168.192.in-addr.arpa.dns"
    NetworkID = "192.168.23.0/24"
}
$forwarder = "8.8.8.8"
$dhcp_scope = @{
    Name = "scope-WS2-2324-anton.hogent"
    IPAddress = "192.168.23.10"
    SubnetMask = "255.255.255.0"
    Description = "DHCP Scope for WS2-2324-anton.hogent"
    StartRange = "192.168.23.51"
    EndRange = "192.168.23.100"
}

Add-DhcpServerInDC `
    -DnsName "WS2-2324-anton.hogent" `
    -IPAddress $interface_config.IPAddress

Add-DhcpServerv4Scope `
    -Name "ScopeWS2-2324-anton.hogent" `
    -StartRange $dhcp_scope.StartRange `
    -EndRange $dhcp_scope.EndRange `
    -SubnetMask $interface_config.SubnetMask `
    -Description $dhcp_scope.Description `
    -State Active `

Set-DhcpServerV4OptionValue `
    -ComputerName "WS2-2324-anton.hogent" `
    -ScopeId "192.168.23.0" `
    -DnsServer @("192.168.23.10", "192.168.23.30") `
    -Router "192.168.23.1"

Set-DnsServerForwarder `
    -IPAddress $forwarder `
    -PassThru

Add-DnsServerPrimaryZone `
    -NetworkID $dns_reverse_lookup_config.NetworkID `
    -ReplicationScope $dns_reverse_lookup_config.ReplicationScope `
    -DynamicUpdate "Secure" `
    -Verbose

Set-DnsServerPrimaryZone `
    -Name $dns_reverse_lookup_config.Name `
    -SecondaryServers "192.168.23.20" `
    -SecureSecondaries "TransferAnyServer"

Set-DnsServerPrimaryZone `
    -Name $dns_forward_lookup_config.Name `
    -SecondaryServers "192.168.23.20" `
    -SecureSecondaries "TransferAnyServer"

Add-DnsServerResourceRecord `
    -ZoneName $dns_forward_lookup_config.Name `
    -Name "." `
    -NS `
    -NameServer "TofuTerminator.WS2-2324-anton.hogent" `
    -IPv4Address "192.168.23.30" `
    -AllowUpdateAny `
    -Verbose

# Records for QuantumToast, TurboTaco and TofuTerminator.
$machine_names = @("QuantumToast", "TurboTaco", "TofuTerminator")
$machine_ips = @("192.168.23.10", "192.168.23.20", "192.168.23.30")
foreach ($machine_name in $machine_names) {
    Add-DnsServerResourceRecordA `
        -Name $machine_name `
        -ZoneName $dns_forward_lookup_config.Name `
        -IPv4Address $machine_ips[$machine_names.IndexOf($machine_name)] `
        -AllowUpdateAny
    Add-DnsServerResourceRecordPtr `
        -PtrDomainName "$($machine_name).$($dns_forward_lookup_config.Name)" `
        -Name $machine_name `
        -ZoneName $dns_reverse_lookup_config.Name `
        -AllowUpdateAny
}

$dns_config = @{
    InterfaceAlias = "Ethernet"
    ServerAddresses = @("192.168.23.10", "192.168.23.30")
}

Set-DnsClientServerAddress @dns_config

# Install Standalone Root
Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools

$ca_params = @{
    CAType = "StandaloneRootCA"
    KeyLength = 2048
    HashAlgorithmName = "SHA256"
    CACommonName = "WS2-2324-anton-QUANTUMTOAST-CA"
    ValidityPeriod = "Years"
    ValidityPeriodUnits = 3
}

Install-AdcsCertificationAuthority @ca_params

certutil -setreg CA\ValidityPeriod "Years"
certutil -setreg CA\ValidityPeriodUnits 30
certutil -setreg CA\DSConfigDN "CN=Configuration,DC=WS2-2324-anton,DC=hogent"
certutil -setreg CA\DSDomainDN "DC=WS2-2324-anton,DC=hogent"

$users = @(
    "Anton Van Assche",
    "Johnny Deere",
    "Tessa Twinkletoes"
)
foreach ($user in $users) {
    $name_parts = $user -split ' '
    $first_name = $name_parts[0]
    $last_name_initials = ($name_parts[1..$name_parts.Count] | ForEach-Object { $_.Substring(0,1) }) -join ''
    $username = $first_name + $last_name_initials

    Write-Host "User: $user"
    Write-Host "Username: $username"

    try {
        New-ADUser -Name $user `
            -SamAccountName $username `
            -Path "CN=Users,DC=WS2-2324-anton,DC=hogent" `
            -AccountPassword (ConvertTo-SecureString -AsPlainText "Friday13th!" -Force) `
            -Enabled $true
    } catch {
        Write-Error $("Failed to create user: $user " + $_.Exception.Message)
    }
}
