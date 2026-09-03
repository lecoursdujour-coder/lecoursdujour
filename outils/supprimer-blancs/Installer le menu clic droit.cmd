@echo off
chcp 65001 >nul
setlocal
set "SCRIPT=%~dp0supprimer-blancs.ps1"

echo.
echo   Installation de « Supprimer les blancs »
echo   ---------------------------------------
echo   Script : %SCRIPT%
echo.

if not exist "%SCRIPT%" (
  echo   ERREUR : supprimer-blancs.ps1 est introuvable a cote de ce fichier.
  pause & exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$exts='.mp4','.mov','.mkv','.avi','.m4v','.webm','.mts','.m2ts';" ^
 "$s='%SCRIPT%';" ^
 "foreach($e in $exts){$o=\"HKCU:\Software\Classes\SystemFileAssociations\$e\shell\LcdjSupprimerBlancs\"; if(Test-Path $o){Remove-Item -LiteralPath $o -Recurse -Force}};" ^
 "$k='HKCU:\Software\Classes\*\shell\LcdjSupprimerBlancs';" ^
 "New-Item -Path $k -Force ^| Out-Null;" ^
 "Set-ItemProperty -LiteralPath $k -Name '(default)' -Value 'Supprimer les blancs';" ^
 "Set-ItemProperty -LiteralPath $k -Name 'Icon' -Value \"$env:SystemRoot\System32\shell32.dll,137\";" ^
 "Set-ItemProperty -LiteralPath $k -Name 'AppliesTo' -Value ((($exts ^| ForEach-Object {'System.ItemType:\"'+$_+'\"'}) -join ' OR '));" ^
 "New-Item -Path \"$k\command\" -Force ^| Out-Null;" ^
 "Set-ItemProperty -LiteralPath \"$k\command\" -Name '(default)' -Value ('powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"'+$s+'\" \"%%1\"');" ^
 "$st=[Environment]::GetFolderPath('ApplicationData')+'\Microsoft\Windows\SendTo';" ^
 "$w=New-Object -ComObject WScript.Shell; $l=$w.CreateShortcut((Join-Path $st 'Supprimer les blancs.lnk'));" ^
 "$l.TargetPath=\"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe\";" ^
 "$l.Arguments='-NoProfile -ExecutionPolicy Bypass -File \"'+$s+'\"';" ^
 "$l.IconLocation=\"$env:SystemRoot\System32\shell32.dll,137\"; $l.Save();" ^
 "Write-Host '  Menu et Envoyer vers installes.'"

echo.
echo   Redemarrage de l'explorateur pour rafraichir le menu...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe

echo.
echo   C'est installe. Deux acces :
echo     - clic droit ^> Afficher plus d'options ^> Supprimer les blancs
echo     - clic droit ^> Envoyer vers ^> Supprimer les blancs  (toujours dispo)
echo.
pause
