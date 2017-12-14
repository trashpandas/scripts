#Force Azure ADSync Delta Sync
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Delta