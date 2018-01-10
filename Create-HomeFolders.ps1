# Pre-Script steps
# 1. Create root home folder
# 2. Give SYSTEM and Domain Admins full control over root home folder,
#    and propigate their permissions to all subfolder and subfiles
# 3. Share root home folder out and give SYSTEM and Domain Admins
#    full control over share 

# Import Active Directory Module
Import-Module ActiveDirectory

# Get Admin account credentials
$AdminCreds = Get-Credential 

# Initialize script variables (manually set variables on lines 15-18)
$ADServer = 'CONTOSO-DC1' # Change to the name to your DC
$HomeRoot = "\\CONTOSO-DC1\Home$" # Set this to the share path to your home share no trailing \
$searchbase = "OU=Users,DC=CONTOSO,DC=com" # Set this to the distinguishedName of the users OU you want to modify
$Domain = 'CONTOSO' # Domain name to use in the $NTUsername variable
$NTUsername = "$Domain\$($ADUser.sAMAccountname)" # Variable to declate NT username format for file rights
$FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl" # Home folder access control
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit" # Home folder Inheritance
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None # Home folder rights propigation from home folder root
$AccessControl =[System.Security.AccessControl.AccessControlType]::Allow  # Home folder access type
$Userfolder = "$HomeRoot\$($ADUser.sAMAccountname)" # Define user's home folder
$HomeDirectory = "$HomeRoot\$($ADUser.sAMAccountname)" # This maps the folder for each user 
$HomeDrive = "H" # This maps $HomeDirectory to a drive letter

# Search for AD users to modify
$ADUsers = Get-ADUser -server $ADServer -Filter * -Credential $AdminCreds -searchbase $searchbase -Properties *

# Begin foreach loop that makes changes to each user
ForEach ($ADUser in $ADUsers) {

# Checks if a folder for the user already exists
# If there is none it will create one using the SAM acount name
$DirTest = Test-Path "$HomeRoot\$($ADUser.sAMAccountname)"
If ($DirTest -eq $False) {New-Item -ItemType Directory -Path "$HomeRoot\$($ADUser.sAMAccountname)"}

# Define a new access rule to apply to users folders
$NewAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule `
($NTUsername, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl) 

# Get ACL for each user folder
$CurrentACL = Get-ACL -path $Userfolder

# Set new access rules
$CurrentACL.SetAccessRule($NewAccessRule)

# Write the changes to the user's home folder
Set-ACL -path $Userfolder -AclObject $CurrentACL

# Update the HomeDirectory and HomeDrive info for each user
Set-ADUser -server $ADServer -Credential $AdminCreds -Identity $ADUser.sAMAccountname -Replace @{HomeDirectory=$HomeDirectory}
Set-ADUser -server $ADServer -Credential $AdminCreds -Identity $ADUser.sAMAccountname -Replace @{HomeDrive=$HomeDrive}

}
#END SCRIPT