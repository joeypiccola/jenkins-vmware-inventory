$path = '.\'
$files = Get-ChildItem -Path $path -Filter "vcen*"
$current = $files | Sort-Object -Property lastWriteTime | Select-Object -Last 1
Copy-Item -Path $current.fullname -Destination '\\nikkor\c$\scripts\vcenter_inventory\vcen_inventory.json' -Force

if ($files.count -gt 5) {
    $lastThree = $files | Sort-Object -Property lastWriteTime | select -Last 3
    $olderFiles = Compare-Object -ReferenceObject $files -DifferenceObject $lastThree -PassThru
    foreach ($file in $olderFiles) {
        Remove-Item -Path $file.fullname
    }
}