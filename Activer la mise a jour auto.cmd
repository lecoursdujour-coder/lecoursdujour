@echo off
setlocal
cd /d "%~dp0"

echo.
echo   Le Cours du Jour - activation de la mise a jour automatique des skills
echo   ----------------------------------------------------------------------
echo.

git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
  echo   ERREUR : ce dossier n'est pas un depot git, ou git n'est pas installe.
  echo   Lance ce fichier depuis le dossier du depot lecoursdujour.
  echo.
  pause
  exit /b 1
)

echo   1/2  Activation des hooks...
git config core.hooksPath .githooks
if errorlevel 1 (
  echo   ERREUR : impossible d'ecrire la configuration git.
  echo.
  pause
  exit /b 1
)
echo        OK - a partir de maintenant, chaque pull reinstalle les skills.
echo.

echo   2/2  Premiere installation...

rem  On cherche le sh fourni par Git (GitHub Desktop ne met pas toujours bash dans le PATH).
set "SH="
for %%P in (sh.exe) do if not defined SH if exist "%%~$PATH:P" set "SH=%%~$PATH:P"
if not defined SH if exist "%ProgramFiles%\Git\bin\sh.exe" set "SH=%ProgramFiles%\Git\bin\sh.exe"
if not defined SH if exist "%ProgramFiles(x86)%\Git\bin\sh.exe" set "SH=%ProgramFiles(x86)%\Git\bin\sh.exe"
if not defined SH if exist "%LocalAppData%\Programs\Git\bin\sh.exe" set "SH=%LocalAppData%\Programs\Git\bin\sh.exe"
if not defined SH if exist "%LocalAppData%\GitHubDesktop\app-*\resources\app\git\bin\sh.exe" (
  for /d %%D in ("%LocalAppData%\GitHubDesktop\app-*") do (
    if exist "%%D\resources\app\git\bin\sh.exe" set "SH=%%D\resources\app\git\bin\sh.exe"
  )
)

if not defined SH (
  echo        sh introuvable - l'installation se fera toute seule au prochain pull.
) else (
  "%SH%" outils/installer-skills.sh
)

echo.
echo   Termine. Il reste UNE chose a faire : redemarrer Claude Code,
echo   sinon il continue de lire les anciennes skills.
echo.
pause
