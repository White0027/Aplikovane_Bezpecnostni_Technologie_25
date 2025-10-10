**💬 1. Vypište z logu System události typu "Chyba" z posledních 10 dní. Pokud v logu žádnou chybu nemáte, zkuste "Upozornění".**

    ⭐ 
    Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-10)

**💬 2. Proveďte konverzi hexadecimální hodnoty řetězce do ascii. $s = "506f7765727368656c6c20697320617765736f6d6521"**

    ⭐ 
    $s="506f7765727368656c6c20697320617765736f6d6521";($s -split '([0-9A-Fa-f]{2})' | Where-Object {$_ -match '^[0-9A-Fa-f]{2}$'} | ForEach-Object {[char][byte]::Parse($_,'HexNumber')}) -join ''

* ✅ Výsledek = Powershell is awesome!