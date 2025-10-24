**💬 1. Modifikujte profil Powershellu tak, aby se po spuštění vypsala žlutou barvou informace o aktuální "execution policy" a zelenou barvou cesta k tomuto profilu.**

    ⭐
    Do powershellu napíšeme: 
    -> notepad $PROFILE
    
    Otevře se nám notepad do kterého vložíme: 
    -> Write-Host "Aktuální Execution Policy: $(Get-ExecutionPolicy)" -ForegroundColor Yellow
    -> Write-Host "Cesta k tomuto profilu: $PROFILE" -ForegroundColor Green

    Restartujeme powershell a máme hotovo


**💬 2. Vytvořte alias np (notepad.exe) a ct (control.exe). Exportujte je do formátu JSON. Potom oba aliasy smažte a obnovte je z JSON souboru.**

    ⭐
    Nejprve vytvoříme dva nové aliasy (ct pro Ovládací panely, np pro Poznámkový blok):
    -> New-Alias -Name np -Value notepad.exe
    -> New-Alias -Name ct -Value control.exe

    Nyní vybrané aliasy exportujeme do souboru aliasy.json, definujeme cestu k souboru
    -> $cesta = "$HOME/aliasy.json"

    Najdeme aliasy, převedeme je na JSON a uložíme do souboru
    -> Get-Alias -Name np, ct | ConvertTo-Json | Out-File -FilePath $cesta
    -> Write-Host "Aliasy byly exportovány do $cesta" -ForegroundColor Cyan

    Oba aliasy odstraníme
    -> Remove-Alias -Name np, ct

    Obnovení aliasů z JSON
    -> Get-Content -Path $cesta | ConvertFrom-Json | ForEach-Object {New-Alias -Name $_.Name -Value $_.Definition}
    -> Write-Host "Aliasy byly obnoveny ze souboru." -ForegroundColor Green
    
    Finální ověření:
    -> Get-Alias np, ct