param (
    [string]$Url,
    [int]$Delka
)

# Kontrola parametrů - pokud chybí, vypiš nápovědu
if (-not $Url -or -not $Delka) {
    Write-Host "`n--- NÁPOVĚDA K POUŽITÍ ---" -ForegroundColor Yellow
    Write-Host "Tento skript extrahuje unikátní slova o zadané délce z webové stránky."
    Write-Host "`nPoužití:"
    Write-Host ".\Extract-Words.ps1 -Url <adresa> -Delka <číslo>"
    Write-Host "`nPříklad:"
    Write-Host ".\Extract-Words.ps1 -Url 'https://cs.wikipedia.org/wiki/Brno' -Delka 5"
    Write-Host "--------------------------`n"
    exit
}

try {
    Write-Host "Stahuji obsah z: $Url" -ForegroundColor Cyan
    
    # 1. Stažení webové stránky
    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
    
    # 2. Odstranění HTML tagů a CSS/JS (extrahuje jen text viditelný pro uživatele)
    # Použijeme regulární výraz pro odstranění všeho mezi < a >
    $cleanText = $response.Content -replace "<script[\s\S]*?<\/script>", "" -replace "<style[\s\S]*?<\/style>", ""
    $cleanText = $cleanText -replace "<[^>]*>", " "

    # 3. Rozdělení na slova
    # Odstraníme interpunkci a rozdělíme text podle mezer a netisknutelných znaků
    $words = $cleanText -split '[\s\p{P}]+'

    # 4. Filtrace slov:
    # - Pouze slova o zadané délce
    # - Odstranění duplicit (Unique)
    # - Seřazení abecedně
    $filteredWords = $words | Where-Object { $_.Length -eq $Delka } | 
                    Sort-Object -Unique

    # Výpis výsledků
    if ($filteredWords) {
        Write-Host "Nalezena unikátní slova o délce $Delka znaků ($($filteredWords.Count)):`n" -ForegroundColor Green
        $filteredWords | ForEach-Object { Write-Host " - $_" }
    } else {
        Write-Host "Na zadané adrese nebyla nalezena žádná slova o délce $Delka znaků." -ForegroundColor Red
    }
}
catch {
    Write-Error "Chyba při stahování nebo zpracování stránky: $($_.Exception.Message)"
}