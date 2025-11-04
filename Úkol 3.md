**💬 1. K řešení následujících úloh použijte CIM rozhraní. Zjistěte vlastnosti třídy umožňující spravovat tiskárny. Změňte umístění faxu.

    ⭐
    $printerClass = Get-CimClass -ClassName Win32_Printer

    $printerClass.CimClassProperties | Select-Object Name, CimType

    Get-CimInstance -ClassName Win32_Printer -Filter "Name = 'Fax'" | Set-CimInstance -Property @{Location = 'Serverovna'}


**💬 2. V informačních systémech MO se disk C: nazývá "Systém" a disk D: "Data". Zjistěte, jak se nazývá váš disk C: a případně ho přejmenujte na "Systém".

    ⭐
    $diskC = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'"

    Write-Host "Aktuální název disku C: je '$($diskC.VolumeName)'"

    Get-CimInstance -ClassName Win32_Volume -Filter "DriveLetter = 'C:'" | Set-CimInstance -Property @{Label = 'Systém'}


**💬 3. Vypište seznam nepoužitých účtů (účtů, ke kterým se nikdo nikdy nepřihlásil) a seznam uzamčených účtů.
Použijte vhodný cmdlet a poté totéž udělejte pomocí CIM rozhraní.

    ⭐
    Search-ADAccount -LockedOut

    Get-ADUser -Filter 'LastLogonTimestamp -notlike "*"' -Properties LastLogonTimestamp

    Get-CimInstance -ClassName Win32_UserAccount -Filter "Lockout = 'True'"

    Get-CimInstance -ClassName Win32_UserAccount | Where-Object { -not $_.LastLogin }