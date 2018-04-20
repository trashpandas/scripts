#Change proxyAddress and mail from UPN

$SearchBase = Read-Host "Input OU"

Get-ADUser -SearchBase $SearchBase -Filter * -Properties mail,ProxyAddresses | Foreach {
  $_.ProxyAddresses = ("SMTP:" + $_.UserPrincipalName)
  $_.mail = $_.UserPrincipalName
 Set-ADUser -instance $_
}