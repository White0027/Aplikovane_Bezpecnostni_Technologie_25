function Format-FileSize {
    param($bytes)
    $suffixes = "B", "KB", "MB", "GB", "TB", "PB"
    $index = 0
    while ($bytes -ge 1024 -and $index -lt ($suffixes.Length - 1)) {
        $bytes /= 1024
        $index++
    }
    return "{0:N2} {1}" -f $bytes, $suffixes[$index]
}

$currentPath = (Get-Location).Path

while ($true) {
    Clear-Host
    Write-Host "=================================================="
    Write-Host " Prohlížeč adresářů"
    Write-Host " Aktuální cesta: $currentPath"
    Write-Host "=================================================="

    $directories = @()
    $files = @()
    $smallestFile = $null
    $largestFile = $null

    try {
        $files = @(Get-ChildItem -Path $currentPath -File -ErrorAction Stop)
        $directories = @(Get-ChildItem -Path $currentPath -Directory -ErrorAction Stop)

        if ($files.Count -gt 0) {
            $sortedFiles = $files | Sort-Object Length
            $smallestFile = $sortedFiles[0]
            $largestFile = $sortedFiles[-1] 

            Write-Host "Celkem souborů: $($files.Count)"
            Write-Host "Nejmenší soubor: $($smallestFile.Name) ($(Format-FileSize $smallestFile.Length))"
            Write-Host "Největší soubor : $($largestFile.Name) ($(Format-FileSize $largestFile.Length))"
        } else {
            Write-Host "Celkem souborů: 0"
            Write-Host "Nejmenší soubor: N/A"
            Write-Host "Největší soubor : N/A"
        }
    }
    catch {
        Write-Host "CHYBA: Přístup k adresáři byl odepřen." -ForegroundColor Red
        Write-Host "Stiskněte 'U' pro návrat o úroveň výš." -ForegroundColor Yellow
    }

    Write-Host "--- Podadresáře ---"
    if ($directories.Count -eq 0) {
        Write-Host "(Tento adresář neobsahuje žádné podadresáře)"
    } else {
        for ($i = 0; $i -lt $directories.Count; $i++) {
            Write-Host "$($i + 1). $($directories[$i].Name)"
        }
    }

    Write-Host "--------------------------------------------------"
    Write-Host "[Číslo] - Vstoupit | [U] - O úroveň výš | [Q] - Konec"
    Write-Host "--------------------------------------------------"

    $input = Read-Host "Vaše volba"
    $inputLower = $input.ToLower() 

    switch ($inputLower) {
        "q" {
            Write-Host "Konec programu."
            break 
        }
        "u" {
            try {
                $parent = (Get-Item $currentPath).Parent
                
                if ($parent) {
                    $currentPath = $parent.FullName
                    Set-Location $currentPath
                } else {
                    Write-Host "Jste v kořenovém adresáři, nelze jít výš." -ForegroundColor Yellow
                    Start-Sleep -Seconds 1
                }
            } catch {
                Write-Host "CHYBA: Nelze přejít o úroveň výš." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }

        default {
            if ($input -match "^\d+$") {
                $choiceIndex = [int]$input - 1 
                
                if ($choiceIndex -ge 0 -and $choiceIndex -lt $directories.Count) {
                    $currentPath = $directories[$choiceIndex].FullName
                    Set-Location $currentPath
                } else {
                    Write-Host "Neplatné číslo. Zkuste to znovu." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            } else {
                Write-Host "Nerozumím příkazu '$input'. Zkuste to znovu." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    } 
} 