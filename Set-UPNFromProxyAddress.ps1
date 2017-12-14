#Changes UPN from primary proxyAddress

$SearchBase = Read-Host "Input OU"

foreach ($user in (Get-ADUser -SearchBase $SearchBase -LdapFilter '(proxyAddresses=*)')) {
    # Grab the primary SMTP address
    $address = Get-ADUser $user -Properties proxyAddresses | Select -Expand proxyAddresses | Where {$_ -clike "SMTP:*"}
    # Remove the protocol specification from the start of the address
    $newUPN = $address.SubString(5)
    # Update the user with their new UPN
    Set-ADUser $user -UserPrincipalName $newUPN
    }