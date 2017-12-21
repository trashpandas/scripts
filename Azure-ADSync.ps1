$Title = "Azure AD Sync"
$Message = "Initial or Delta Sync?"

$Initial = New-Object System.Management.Automation.Host.ChoiceDescription "&Initial", `
    "Runs through the steps to execute the initial synchronization to the cloud."

$Delta = New-Object System.Management.Automation.Host.ChoiceDescription "&Delta", `
    "Runs through the steps to execute a delta synchronization to the cloud."

$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Initial, $Delta)

$Result = $Host.ui.PromptForChoice($Title, $Message, $Options, 1) 

switch ($Result)
    {
        0 {Write-Output "Running initial AD sync..."; Import-Module ADSync; Start-ADSyncSyncCycle -PolicyType Initial}
        1 {Write-Output "Running delta AD sync..."; Import-Module ADSync; Start-ADSyncSyncCycle -PolicyType Delta}
    }