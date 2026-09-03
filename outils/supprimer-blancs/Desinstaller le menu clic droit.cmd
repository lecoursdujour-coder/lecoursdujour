@echo off
chcp 65001 >nul
echo.
echo   Retrait de « Supprimer les blancs »
echo   ----------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$k='HKCU:\Software\Classes\*\shell\LcdjSupprimerBlancs'; if(Test-Path $k){Remove-Item -LiteralPath $k -Recurse -Force; Write-Host '  menu clic droit retire'};" ^
 "foreach($e in '.mp4','.mov','.mkv','.avi','.m4v','.webm','.mts','.m2ts'){$o=\"HKCU:\Software\Classes\SystemFileAssociations\$e\shell\LcdjSupprimerBlancs\"; if(Test-Path $o){Remove-Item -LiteralPath $o -Recurse -Force}};" ^
 "$l=[Environment]::GetFolderPath('ApplicationData')+'\Microsoft\Windows\SendTo\Supprimer les blancs.lnk'; if(Test-Path $l){Remove-Item -LiteralPath $l -Force; Write-Host '  Envoyer vers retire'}"
echo.
echo   Le dossier et le script restent en place.
echo.
pause
