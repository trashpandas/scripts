# Creates CSV of all AD users PasswordLastSet, LastLogonDate, PasswordNeverExpires
Get-ADUser -Filter {Enabled -eq $true} -Properties PasswordLastSet, LastLogonDate, PasswordNeverExpires |
Sort-Object Name |
Select-Object Name, PasswordLastSet, LastLogonDate, PasswordNeverExpires |
Export-CSV -Path C:\Temp\password_report_$(get-date -f MM-yyyy).csv -NoTypeInformation