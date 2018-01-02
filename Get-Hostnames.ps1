# Pulls the hostname of every computer under a specified OU.

# Run script from a domain controller

Import-Module ActiveDirectory

$SearchBase = Read-Host "OU distinguishedName"

$OutputFile = Read-Host "Output File Location"

# Pull computer names
$Computers = Get-ADComputer -Filter * -SearchBase "$SearchBase" | Select-Object Name

# Export CSV to path set in $OutputFile parameter
$Computers | Export-CSV -NoTypeInformation -Path "$OutputFile"