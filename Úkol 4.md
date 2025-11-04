**💬 1. V registru zjistěte, zda je pro přihlášení uživatele zapnuta klávesa Numlock. Pokud není, tak nastavte odpovídající položku registru na hodnotu 2.

    ⭐
    $Path = "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard"
    $Name = "InitialKeyboardIndicators"
    $TargetValue = 2

    try {
        $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name      
        Write-Host "Aktuální hodnota pro '$Name' je: $currentValue"

        if ($currentValue -ne $TargetValue) {
            Write-Host "Hodnota není $TargetValue. Nastavuji..."
            Set-ItemProperty -Path $Path -Name $Name -Value $TargetValue
            Write-Host "[OK] Hodnota 'InitialKeyboardIndicators' byla nastavena na $TargetValue." -ForegroundColor Green
        } else {
            Write-Host "Hodnota je již správně nastavena na $TargetValue. Není co měnit."
        }
    }
    catch [Microsoft.PowerShell.Commands.ItemPropertyNotFoundException] {
        Write-Warning "Hodnota '$Name' nebyla nalezena. Vytvářím ji..."
        New-ItemProperty -Path $Path -Name $Name -Value $TargetValue -PropertyType String
        Write-Host "[OK] Hodnota 'InitialKeyboardIndicators' byla vytvořena a nastavena na $TargetValue." -ForegroundColor Green
    }

**💬 2. Vytvořte podklíč registru HKEY_CURRENT_USER, který nazvete Hrátky s PowerShellem. V něm vytvořte hodnoty obsahující jméno vašeho uživatelského účtu, jméno počítače, aktuální datum a verzi PowerShellu. Pro potvrzení provedené akce si všechny tyto informace vypište.

    ⭐
    $Path = "HKCU:\Úkol 4"

    # Krok 1 a 2: Vytvoření klíče
    New-Item -Path $Path -Force | Out-Null
    Write-Host "Klíč '$Path' je připraven."

    # Krok 3 a 4: Shromáždění a nastavení hodnot
    Set-ItemProperty -Path $Path -Name "Uživatel" -Value $env:USERNAME
    Set-ItemProperty -Path $Path -Name "Počítač" -Value $env:COMPUTERNAME
    Set-ItemProperty -Path $Path -Name "DatumAkce" -Value (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Set-ItemProperty -Path $Path -Name "VerzePowerShell" -Value $PSVersionTable.PSVersion.ToString()

    # Krok 5: Ověření a výpis
    $vysledek = Get-ItemProperty -Path $Path

    # Formátovaný výpis pro kontrolu
    $vysledek | Format-List