$path = '.\'
$files = Get-ChildItem -Path $path -Filter "vcen*"

if ($files.count -gt 3) {
    $lastThree = $files | Sort-Object -Property lastWriteTime | select -Last 3
    $olderFiles = Compare-Object -ReferenceObject $files -DifferenceObject $lastThree -PassThru
    foreach ($file in $olderFiles) {
        Remove-Item -Path $file.fullname
    }
}