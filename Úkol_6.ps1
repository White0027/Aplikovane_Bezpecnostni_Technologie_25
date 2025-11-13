# =================================================================
## 1. Náhodná čísla a jejich mocniny
# =================================================================

Write-Host "### 1. Náhodná čísla a jejich mocniny ###" -ForegroundColor Cyan
Write-Host ""

"{0,3}  {1,5}" -f "Č.", "Moc."
"{0,3}  {1,5}" -f "---", "-----"

1..10 | ForEach-Object {
    $num = Get-Random -Minimum 10 -Maximum 101
    $square = $num * $num
    "{0,3}  {1,5}" -f $num, $square
}
Write-Host ""

# =================================================================
## 2. Setřídění znaků v textu
# =================================================================

Write-Host "### 2. Setřídění znaků v textu ###" -ForegroundColor Cyan
Write-Host ""
$text = "Kobyla má malý bok"
Write-Host "Původní text: $text"

$culture = [System.Globalization.CultureInfo]::GetCultureInfo("cs-CZ")
$znaky = $text.ToLower($culture).ToCharArray()
$serazeneZnaky = $znaky | Where-Object { -not [char]::IsWhiteSpace($_) } | Sort-Object

Write-Host "Setříděné znaky: $($serazeneZnaky -join '')"
Write-Host ""

# =================================================================
## 3. Nejmenší a největší palindrom
# =================================================================

Write-Host "### 3. Nejmenší a největší palindrom (z násobků 3-cif. čísel) ###" -ForegroundColor Cyan
Write-Host ""

# Pomocná funkce pro test, zda je číslo palindrom
function Test-Palindrome($number) {
    $s = [string]$number
    $charArray = $s.ToCharArray()
    [array]::Reverse($charArray)
    $sReversed = -join $charArray
    return $s -eq $sReversed
}

Write-Host "Hledám palindromy... (může to chvíli trvat)"

# --- Hledání nejmenšího palindromu ---
$smallestPalindrome = $null
$factorsSmall = ""
try {
    # Použijeme 'try/catch' k rychlému opuštění obou smyček po nalezení
    for ($i = 100; $i -le 999; $i++) {
        # $j=$i -> optimalizace, abychom nekontrolovali 100*101 a 101*100
        for ($j = $i; $j -le 999; $j++) { 
            $prod = $i * $j
            if (Test-Palindrome $prod) {
                $smallestPalindrome = $prod
                $factorsSmall = "$i x $j"
                throw "Nalezen nejmenší palindrom."
            }
        }
    }
} catch {
    # Zachytíme výjimku a pokračujeme
}

# --- Hledání největšího palindromu ---
$largestPalindrome = 0
$factorsLarge = ""
for ($i = 999; $i -ge 100; $i--) {
    for ($j = $i; $j -ge 100; $j--) {
        $prod = $i * $j
        
        if ($prod -lt $largestPalindrome) {
            break
        }
        
        if (Test-Palindrome $prod) {
            $largestPalindrome = $prod
            $factorsLarge = "$i x $j"
            # Nepřerušujeme, protože (i-1)*(i-1) může být stále větší
        }
    }
}

Write-Host "VÝSLEDKY:"
Write-Host "Nejmenší palindrom: $smallestPalindrome (vznikl jako $factorsSmall)" -ForegroundColor Green
Write-Host "Největší palindrom: $largestPalindrome (vznikl jako $factorsLarge)" -ForegroundColor Green