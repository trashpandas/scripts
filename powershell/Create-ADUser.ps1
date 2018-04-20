#   1. Creates AD user and syncs to Office 365
#   2. Creates Home folder
#   3. Assigns Office 365 licensing


# Set global variables and take user information input
$AdminCreds = Get-Credential -Message "Input Office 365 admin password" # Must be Domain Admin and Office 365 Admin
$Domains = @("contoso.com", "CONTOSO") # [0] in array is contoso.com format, [1] is NT format
$Path = "OU=Users,DC=CONTOSO,DC=com" # OU to create user in
$FirstName = Read-Host "First Name"
$LastName = Read-Host "Last Name"
$Password = Read-Host "Password" -AsSecureString
$SamAcctName = (($FirstName.Substring(0,1)) + ($LastName)) # Formats SAM name to JDoe
$UPN = (($SamAcctName) + '@' + ($Domains[0])) # Formats UPN to JDoe@contoso.com


# Create new user
Write-Output "Creating User..."
New-ADUser -Name "$FirstName $LastName" `
    -GivenName "$FirstName" `
    -Surname "$LastName" `
    -DisplayName "$FirstName $LastName" `
    -EmailAddress "$UPN" `
    -SamAccountName "$SamAcctName" `
    -UserPrincipalName "$UPN" `
    -Path "$Path" `
    -ChangePasswordAtLogon $true `
    -AccountPassword $Password `
    -Enabled $true `


# Set user ProxyAddress and UserPrincipalName
Write-Output "Setting User ProxyAddress & UPN..."
$NewUser = Get-ADUser $SamAcctName -Properties ProxyAddresses,UserPrincipalName
$NewUser.ProxyAddresses = ('SMTP:' + ($SamAcctName) + '@' + ($Domains[0]))
$NewUser.UserPrincipalName = $UPN 
Set-ADUser -instance $NewUser


# Sync user up to Office 365
Write-Output "Syncing User to Office 365..."
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Delta


# Create user home folder (parent folder of user home folders must already be created)
Write-Output "Creating Home Folder..."
# Create folder under parent directory
New-Item -ItemType Directory -Path "\\CONTOSO-DC\Home\$SamAcctName" # Network path to home folder share

# Define variable to grant user access to their home folder (Format: Domain\Username)
$UserAcct = (($Domains[1]) + '\' + ($SamAcctName))

# Define home folder properties
$FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None
$AccessControl =[System.Security.AccessControl.AccessControlType]::Allow 

# Define a new access rule to apply to user's folder
$NewAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule `
    ($UserAcct, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)

# Define the home folder for the user
$HomeFolder = "\\CONTOSO-DC\Home\$SamAcctName"

#Get current home folder ACL
$CurrentACL = Get-ACL -path $HomeFolder

#Add this access rule to the ACL
$CurrentACL.SetAccessRule($NewAccessRule)

#Write the changes to the user folder
Set-ACL -path $HomeFolder -AclObject $CurrentACL

# Set home drive letter
$HomeDrive = "H"

# Set home folder for new user
Set-ADUser -Identity $SamAcctName -Credential $AdminCreds -Replace @{HomeDirectory=$HomeFolder}
Set-ADUser -Identity $SamAcctName -Credential $AdminCreds -Replace @{HomeDrive=$HomeDrive}


# Option menu to create Office 365 mailbox
$Title = "Mailbox Creation"
$Message = "Create Office 365 Mailbox?"

$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Automatically creates mailbox for the user in Office 365."

$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Skips creation of Office 365 mailbox."

$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)

$Result = $Host.ui.PromptForChoice($Title, $Message, $Options, 0) 

switch ($Result)
    {
        0 {Write-Output "Creating Office 365 Mailbox..."; `
            Start-Sleep -s 60; ` # Sleep script for 60 sec to allow for AD Sync to complete
            Connect-MsolService -Credential $AdminCreds; `
            Set-MsolUser -UserPrincipalName "$UPN" -UsageLocation US; ` # Change usage location to your needs
            Set-MsolUserLicense -UserPrincipalName "$UPN" -AddLicenses "contoso:EXCHANGESTANDARD"} # This can be any Office 365 license SKU
        1 {Write-Output "Mailbox Creation Skipped"}
    }


Write-Output "User Creation Complete!"