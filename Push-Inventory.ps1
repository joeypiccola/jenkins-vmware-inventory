$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$WarningPreference = 'Continue'

$vcenter_user = (Get-ChildItem -Path ('env:cred_vcenter_adpiccolaus_USR')).value
$vcenter_pass = (Get-ChildItem -Path ('env:cred_vcenter_adpiccolaus_PSW')).value

$secpasswd = ConvertTo-SecureString $vcenter_pass -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($vcenter_user, $secpasswd)

$path = '.\'
$files = Get-ChildItem -Path $path -Filter "vcen*"
$current = $files | Sort-Object -Property lastWriteTime | Select-Object -Last 1
New-PSDrive -PSProvider FileSystem -Name 'toolRoot' -Root '\\nikkor.ad.piccola.us\c$\scripts\vcenter_inventory' -Credential $mycreds
Copy-Item -Path $current.fullname -Destination 'toolRoot:\vcen_inventory.json' -Force
Remove-PSDrive -Name 'toolRoot'