#Force Azure ADSync Initial Sync
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Initial