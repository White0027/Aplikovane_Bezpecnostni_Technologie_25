$realDocPath = [Environment]::GetFolderPath("MyDocuments")
$realDesktopPath = [Environment]::GetFolderPath("Desktop")
$scriptPath = "$realDocPath\Get-Temperature.ps1"
$logFile = "$realDesktopPath\teploty.txt"

$scriptContent = @"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

`$logFile = "$logFile"

try {
    `$url = "http://wttr.in/Brno?format=%t"
    `$temperature = (Invoke-RestMethod -Uri `$url -Method Get -UserAgent "curl").Trim()
} catch {
    `$temperature = "CHYBA: " + `$_.Exception.Message
}

`$date = Get-Date -Format "dd.MM.yyyy HH:mm"
Add-Content -Path `$logFile -Value "`$date - Brno: `$temperature" -Encoding UTF8
"@

try {
    $scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force
    Write-Host "Skript byl vytvořen." -ForegroundColor Green
} catch {
    Write-Host "Nelze vytvořit skript: $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host "Spouštím skript..."
& $scriptPath

Write-Host "Podívejte se do souboru 'teploty.txt' na ploše." -ForegroundColor Yellow