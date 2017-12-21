# Deploys shorcut to the public desktop of all computers in a specified OU

$SearchBase = Read-Host "OU distinguishedName"
$SourceFile = Read-Host "Shortcut File Location"

# Pull computer names
$Computers = Get-ADComputer -Filter * -SearchBase $SearchBase | Select-Object -Expand Name

# Set the file destination as the public desktop
$Destination = "Users\Public\Desktop"

# Copy shorcut to all computers in $Computers
$Computers | ForEach-Object {Copy-Item $SourceFile -Destination \\$_\c$\$Destination}