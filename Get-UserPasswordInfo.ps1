# Creates CSV of all AD user's PasswordLastSet, LastLogonDate, PasswordNeverExpires

$PassInfo = Get-ADUser -Filter {Enabled -eq $true} -Properties PasswordLastSet, LastLogonDate, PasswordNeverExpires |

Sort-Object Name |

Select-Object Name, PasswordLastSet, LastLogonDate, PasswordNeverExpires |

Export-CSV -Path C:\Temp\user-password-info.csv -NoTypeInformation