# Nastavení
$intervalSekundy = 5   # Interval kontroly (v zadání bylo 20, pro testování doporučuji 5)
$klicovaSlova = @("password", "token", "heslo", "tajne", "key") # Hledaná slova

# Inicializace proměnné pro uchování posledního obsahu
$posledniObsah = ""

Write-Host "--- Monitoring schránky spuštěn ---" -ForegroundColor Cyan
Write-Host "Sleduji slova: $($klicovaSlova -join ', ')" -ForegroundColor DarkGray
Write-Host "Pro ukončení stiskněte Ctrl+C" -ForegroundColor DarkGray
Write-Host ""

while ($true) {
    try {
        # Získání obsahu schránky jako text
        $aktualniObsah = Get-Clipboard | Out-String
        
        if ($null -eq $aktualniObsah) { $aktualniObsah = "" }
        $aktualniObsah = $aktualniObsah.Trim()

        # Kontrola, zda se obsah změnil od posledního běhu
        if ($aktualniObsah -ne $posledniObsah -and $aktualniObsah -ne "") {
            
            # Projdeme všechna klíčová slova
            $nasloSe = $false
            foreach ($slovo in $klicovaSlova) {
                if ($aktualniObsah -match "$slovo") {
                    $nasloSe = $true
                    break
                }
            }

            # Pokud obsah obsahuje klíčové slovo, vypíšeme ho se zvýrazněním
            if ($nasloSe) {
                Write-Host "[!] ZACHYCENO KLÍČOVÉ SLOVO:" -ForegroundColor Yellow
                
                # Zvýraznění konkrétního slova v textu
                # Použijeme Regex split, který zachová oddělovače (klíčová slova)
                $pattern = "(" + ($klicovaSlova -join "|") + ")"
                $casti = [regex]::Split($aktualniObsah, $pattern, "IgnoreCase")

                foreach ($cast in $casti) {
                    if ($cast -match $pattern) {
                        # Toto je klíčové slovo -> ČERVENĚ
                        Write-Host $cast -NoNewline -ForegroundColor Red -BackgroundColor DarkRed
                    } else {
                        # Toto je běžný text -> BÍLE
                        Write-Host $cast -NoNewline -ForegroundColor Gray
                    }
                }
                Write-Host "" # Odřádkování na konci
                Write-Host "----------------------------------------" -ForegroundColor DarkGray
            }
            
            # Aktualizace posledního známého obsahu
            $posledniObsah = $aktualniObsah
        }
    }
    catch {
        # Schránka může být někdy zamknutá jiným procesem, chybu ignorujeme
    }

    # Čekání před další kontrolou
    Start-Sleep -Seconds $intervalSekundy
}