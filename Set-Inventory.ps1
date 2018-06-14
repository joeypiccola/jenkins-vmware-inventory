$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$WarningPreference = 'Continue'

$path = '.\'
$files = Get-ChildItem -Path $path -Filter "vcen*"

if ($files.count -gt 3) {
    $lastThree = $files | Sort-Object -Property lastWriteTime | Select-Object -Last 3
    $olderFiles = Compare-Object -ReferenceObject $files -DifferenceObject $lastThree -PassThru
    foreach ($file in $olderFiles) {
        Write-Host "removing $($file.fullname)"
        Remove-Item -Path $file.fullname
    }
}

Write-Information 'Begin ghprb env dump'
Write-Information $env:ghprbActualCommit
Write-Information $env:ghprbActualCommitAuthor
Write-Information $env:ghprbActualCommitAuthorEmail
Write-Information $env:ghprbPullDescription
Write-Information $env:ghprbPullId
Write-Information $env:ghprbPullLink
Write-Information $env:ghprbPullTitle
Write-Information $env:ghprbSourceBranch
Write-Information $env:ghprbTargetBranch
Write-Information $env:ghprbCommentBody
Write-Information $env:sha1
Write-Information 'End ghprb env dump'

# c