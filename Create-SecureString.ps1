# Create encrypted string from input and outputs to txt file
$OutFile = Read-Host "Output File"
Read-Host "Input String" -AsSecureString | ConvertFrom-SecureString | Out-File $OutFile