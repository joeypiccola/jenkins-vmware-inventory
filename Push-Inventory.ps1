$ErrorActionPreference = 'stop'

$vcenter_user = (Get-ChildItem -Path ('env:cred_vcenter_adpiccolaus_USR')).value
$vcenter_pass = (Get-ChildItem -Path ('env:cred_vcenter_adpiccolaus_PSW')).value

$secpasswd = ConvertTo-SecureString $vcenter_pass -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($vcenter_user, $secpasswd)

$path = '.\'
$files = Get-ChildItem -Path $path -Filter "vcen*"
$current = $files | Sort-Object -Property lastWriteTime | Select-Object -Last 1
Copy-Item -Path $current.fullname -Destination '\\nikkor\c$\scripts\vcenter_inventory\vcen_inventory.json' -Force -Credential $mycreds

if ($files.count -gt 5) {
    $lastThree = $files | Sort-Object -Property lastWriteTime | select -Last 3
    $olderFiles = Compare-Object -ReferenceObject $files -DifferenceObject $lastThree -PassThru
    foreach ($file in $olderFiles) {
        Remove-Item -Path $file.fullname
    }
}