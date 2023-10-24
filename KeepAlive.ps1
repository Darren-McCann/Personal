Clear-Host
Write-Host "Keep Alive Script Running"

$WShell = New-Object -ComObject "WScript.Shell"
while($true) {
    Get-Date -Format HH:mm:ss
    $WShell.sendkeys("{SCROLLLOCK}")
    Start-Sleep -Milliseconds 100
    $WShell.sendkeys("{SCROLLLOCK}")
    Start-Sleep -Seconds 240
}