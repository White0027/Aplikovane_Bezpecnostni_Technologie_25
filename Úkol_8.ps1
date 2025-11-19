<#
.SYNOPSIS
    Vypíše seznam nainstalovaného softwaru bez použití WMI/CIM.
    Kombinuje 3 zdroje: Registry, Appx (Store Apps) a Windows Installer COM.

.DESCRIPTION
    1. Zdroj: Registry (HKLM 32/64bit + HKCU) - Klasické desktopové aplikace.
    2. Zdroj: Get-AppxPackage - Moderní Windows aplikace (kalkulačka, fotky, store apps).
    3. Zdroj: Windows Installer COM Object - Hlubší pohled do MSI databáze.
#>

Write-Host "Zahajuji inventarizaci softwaru (to může chvíli trvat)..." -ForegroundColor Cyan

$SoftwareList = [System.Collections.Generic.List[PSObject]]::new()

# ---------------------------------------------------------
# ZDROJ 1: REGISTRY (Klasické aplikace)
# ---------------------------------------------------------
Write-Host "1/3 Prohledávám Registry (HKLM a HKCU)..." -ForegroundColor Yellow

# Definice cest k odinstalačním klíčům
$RegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",         # 64-bit systémové
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", # 32-bit na 64-bit OS
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"          # Uživatelské (per-user)
)

foreach ($path in $RegistryPaths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path | ForEach-Object {
            $props = Get-ItemProperty -Path $_.PSPath
            
            if ($props.DisplayName) {
                $SoftwareList.Add([PSCustomObject]@{
                    Name      = $props.DisplayName.Trim()
                    Version   = if ($props.DisplayVersion) { $props.DisplayVersion } else { "N/A" }
                    Publisher = if ($props.Publisher) { $props.Publisher } else { "N/A" }
                    Source    = "Registry"
                })
            }
        }
    }
}

# ---------------------------------------------------------
# ZDROJ 2: APPX (Moderní Windows Aplikace)
# ---------------------------------------------------------
Write-Host "2/3 Prohledávám Windows Store Apps (Appx)..." -ForegroundColor Yellow

try {
    # -AllUsers vyžaduje admin práva, získá i aplikace ostatních uživatelů
    Get-AppxPackage -AllUsers | ForEach-Object {
        $SoftwareList.Add([PSCustomObject]@{
            Name      = $_.Name
            Version   = $_.Version
            Publisher = $_.PublisherId
            Source    = "Appx/Store"
        })
    }
} catch {
    Write-Warning "Nepodařilo se načíst Appx balíčky. Spusťte skript jako Administrátor."
}

# ---------------------------------------------------------
# ZDROJ 3: WINDOWS INSTALLER COM OBJECT (MSI Databáze)
# ---------------------------------------------------------
Write-Host "3/3 Dotazuji se Windows Installer COM objektu..." -ForegroundColor Yellow

try {
    $Installer = New-Object -ComObject WindowsInstaller.Installer
    $Products = $Installer.ProductsEx("", "", 7)

    foreach ($Product in $Products) {
        try {
            $Name = $Product.InstallProperty("ProductName")
            $Version = $Product.InstallProperty("VersionString")
            $Publisher = $Product.InstallProperty("Publisher")

            if ($Name) {
                $SoftwareList.Add([PSCustomObject]@{
                    Name      = $Name.Trim()
                    Version   = if ($Version) { $Version } else { "N/A" }
                    Publisher = if ($Publisher) { $Publisher } else { "N/A" }
                    Source    = "WinInstallerCOM"
                })
            }
        } catch {
            continue
        }
    }
} catch {
    Write-Warning "Nepodařilo se vytvořit COM objekt WindowsInstaller."
}

# ---------------------------------------------------------
# ZPRACOVÁNÍ: Odstranění duplicit a výpis
# ---------------------------------------------------------
Write-Host "Zpracovávám data a odstraňuji duplicity..." -ForegroundColor Cyan

# Sjednocení, seřazení a odstranění duplicit
$FinalList = $SoftwareList | 
    Sort-Object Name | 
    Select-Object Name, Version, Publisher, Source -Unique

# Výpis do tabulky
$FinalList | Format-Table -AutoSize

# Volitelně: Výpis statistiky
Write-Host "------------------------------------------------"
Write-Host "Nalezeno unikátních aplikací: $($FinalList.Count)" -ForegroundColor Green
Write-Host "------------------------------------------------"