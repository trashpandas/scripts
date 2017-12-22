# 1. Disables AD account
# 2. Moves account to Disabled OU
# 3. Deletes the account's home folder
# 4. Removes account's Office 365 licensing

# Define variables used for the script
$AdminCreds = Get-Credential -Message "Input Admin Account Password"
$Username = Read-Host "Username to Disable (ex. jdoe)"
$Domain = "contoso.com"
$UPN = (($Username) + "@" + ($Domain))
$OUPath = "OU=Disabled,DC=CONTOSO,DC=com"

# Disable AD account
Disable-ADAccount -Identity $Username

# Move account to disabled OU
Get-ADUser $Username | Move-ADObject -TargetPath $OUPath
# Delete home folder
$DirTest = Test-Path "\\CONTOSO-DC\Home\$Username"
If ($DirTest -eq $True) {Remove-Item -Path "\\CONTOSO-DC\Home\$Username"}

# Remove Office 365 license
Connect-MsolService -Credential $AdminCreds; Set-MsolUserLicense -UserPrincipalName "$UPN" -RemoveLicenses "contoso:EXCHANGESTANDARD"
