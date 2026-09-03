# =====================================================================
#  Supprimer les blancs — Le Cours du Jour
#  Coupe les silences d'une vidéo en gardant une marge d'images autour.
#  Encodage sur le GPU AMD quand c'est possible (13x plus rapide que le CPU).
#
#  Usage : clic droit sur une vidéo -> « Supprimer les blancs »
#          ou  powershell -File supprimer-blancs.ps1 "C:\video.mp4" -SeuilDb -30
# =====================================================================

param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path,

  # --- la marge gardée autour de chaque blanc, EN IMAGES ---------------
  # 3 = très sec · 6 = confortable
  [int]$ImagesAvant = 5,
  [int]$ImagesApres = 3,

  # --- ce qui compte comme un blanc ------------------------------------
  # Si tu passes -SeuilDb, la question n'est pas posée. Sinon le script
  # mesure et propose un tableau de seuils.
  # Plus le seuil est HAUT (-25 plutôt que -40), plus il coupe : les
  # respirations et les petits bruits de bouche passent alors pour du blanc.
  [double]$SeuilDb   = -35,
  [double]$BlancMini = 0.30,   # durée mini d'un blanc pour être coupé (s)

  # --- qualité ---------------------------------------------------------
  [int]$Qp          = 18,      # qualité GPU (bas = mieux). 16 = large, 20 = léger
  [int]$Crf         = 16,      # qualité CPU si -Cpu
  [string]$Preset   = 'slow',
  [int]$Threads     = 0,       # 0 = tous les cœurs
  [switch]$Cpu,                # forcer l'encodage processeur
  [switch]$DebitSource,        # caler la sortie sur le débit de la source

  [switch]$Auto,               # ne rien demander, prendre les valeurs par défaut
  [switch]$NoPause
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

function Fin($code) {
  # on libere toujours le verrou, meme en cas d'erreur
  if ($script:verrou -and (Test-Path -LiteralPath $script:verrou)) {
    Remove-Item -LiteralPath $script:verrou -Force -ErrorAction SilentlyContinue
  }
  if (-not $NoPause) {
    Write-Host ''
    Write-Host 'Appuie sur Entrée pour fermer...' -ForegroundColor DarkGray
    try { [void][System.Console]::ReadLine() } catch { }
  }
  exit $code
}
function Info($m)  { Write-Host $m }
function Bien($m)  { Write-Host $m -ForegroundColor Green }
function Souci($m) { Write-Host $m -ForegroundColor Yellow }
function Erreur($m){ Write-Host $m -ForegroundColor Red }
$inv = [Globalization.CultureInfo]::InvariantCulture
function D([double]$v, [int]$n = 2) { $v.ToString("0." + ('#' * $n), $inv) }

# ffmpeg : winget le range dans un dossier qui porte le numero de version.
# A chaque mise a jour le dossier change de nom et l'entree du PATH meurt.
# On repare donc le PATH tout seul avant d'abandonner.
function Reparer-Ffmpeg {
  $base = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'
  if (-not (Test-Path $base)) { return $null }
  $exe = Get-ChildItem $base -Directory -ErrorAction SilentlyContinue |
         Where-Object Name -match 'FFmpeg' |
         ForEach-Object { Get-ChildItem $_.FullName -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue } |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $exe) { return $null }
  $bin = $exe.Directory.FullName
  $env:PATH = "$bin;$env:PATH"
  # on nettoie aussi le PATH permanent : entrees ffmpeg mortes retirees, la bonne ajoutee
  $u = ([Environment]::GetEnvironmentVariable('Path','User') -split ';') | Where-Object { $_ }
  $garde = $u | Where-Object { $_ -notmatch 'ffmpeg' -or (Test-Path (Join-Path $_ 'ffmpeg.exe')) }
  if ($garde -notcontains $bin) { $garde += $bin }
  if (($garde -join ';') -ne (($u) -join ';')) {
    [Environment]::SetEnvironmentVariable('Path', ($garde -join ';'), 'User')
    Souci "  ffmpeg avait bouge — PATH repare vers $bin"
  }
  return $bin
}
foreach ($exe in 'ffmpeg', 'ffprobe') {
  if (-not (Get-Command $exe -ErrorAction SilentlyContinue)) {
    if (-not (Reparer-Ffmpeg) -or -not (Get-Command $exe -ErrorAction SilentlyContinue)) {
      Erreur "$exe est introuvable."
      Erreur "Installe-le : winget install Gyan.FFmpeg   puis relance."
      Fin 1
    }
  }
}
if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { Erreur "Fichier introuvable : $Path"; Fin 1 }

$src = Get-Item -LiteralPath $Path
$dst = Join-Path $src.DirectoryName ($src.BaseName + ' - sans blancs' + $src.Extension)

# --- verrou : deux lancements sur la meme video s'ecrasaient l'un l'autre et
# --- laissaient un fichier sans en-tete, illisible par les lecteurs.
$verrou = "$dst.encours"
if (Test-Path -LiteralPath $verrou) {
  $age = (Get-Date) - (Get-Item -LiteralPath $verrou).LastWriteTime
  if ($age.TotalMinutes -lt 180) {
    Erreur "  Cette video est deja en cours de traitement (depuis $([int]$age.TotalMinutes) min)."
    Erreur "  Ferme l'autre fenetre, ou attends qu'elle finisse."
    Erreur "  Si tu es sur qu'aucune ne tourne : supprime $verrou"
    $verrou = $null   # ce verrou appartient a l'autre instance, on n'y touche pas
    Fin 1
  }
  Remove-Item -LiteralPath $verrou -Force -ErrorAction SilentlyContinue
}
# --- sortie deja presente : on ne l'ecrase pas en silence, on numerote
if (Test-Path -LiteralPath $dst) {
  $n = 2
  do { $alt = Join-Path $src.DirectoryName ($src.BaseName + ' - sans blancs (' + $n + ')' + $src.Extension); $n++ }
  while (Test-Path -LiteralPath $alt)
  Souci "  $(Split-Path $dst -Leaf) existe deja — j'ecris $(Split-Path $alt -Leaf)"
  $dst = $alt
  $verrou = "$dst.encours"
}
New-Item -ItemType File -Path $verrou -Force | Out-Null

$tmp = Join-Path $env:TEMP ("sb_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null

Write-Host ''
Write-Host '  SUPPRIMER LES BLANCS' -ForegroundColor Cyan
Write-Host '  --------------------' -ForegroundColor Cyan
Info "  Source : $($src.Name)"

try {
  # ---------- caractéristiques ----------------------------------------
  $l = @(& ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate `
           -show_entries format=duration -of default=nw=1:nk=1 -- "$($src.FullName)") |
       Where-Object { $_ -match '\S' }
  if ($l.Count -lt 2) { Erreur "Impossible de lire la vidéo (pas de piste vidéo ?)."; Fin 1 }
  $fps = if ($l[0] -match '^\s*(\d+)\s*/\s*(\d+)\s*$' -and [double]$Matches[2] -ne 0) {
           [double]$Matches[1] / [double]$Matches[2] } else { [double]($l[0] -replace ',', '.') }
  if ($fps -le 0) { $fps = 30 }
  $duree = [double](($l[1]) -replace ',', '.')
  if ($duree -le 0) { Erreur "Durée illisible."; Fin 1 }

  if (-not (@(& ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 -- "$($src.FullName)") |
            Where-Object { $_ -match '\S' }).Count) {
    Erreur "Cette vidéo n'a pas de piste audio — il n'y a pas de blancs à détecter."; Fin 1
  }

  $pixSrc = @(& ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 -- "$($src.FullName)")[0]
  $pixOk  = @('yuv420p','yuvj420p','yuv422p','yuvj422p','yuv444p','yuvj444p','yuv420p10le','yuv422p10le','yuv444p10le')
  $PixFmt = if ($pixSrc -and $pixOk -contains "$pixSrc".Trim()) { "$pixSrc".Trim() } else { 'yuv420p' }
  $dixBits = $PixFmt -like '*10le'

  $aBrSrc = @(& ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of csv=p=0 -- "$($src.FullName)")[0]
  $ABr = 192; if ("$aBrSrc" -match '^\d+$') { $ABr = [Math]::Min(320, [Math]::Max(192, [int]([int]$aBrSrc/1000))) }
  $vBrSrc = @(& ffprobe -v error -show_entries format=bit_rate -of csv=p=0 -- "$($src.FullName)")[0]
  $mbSrc  = if ("$vBrSrc" -match '^\d+$') { [double]$vBrSrc / 1e6 } else { 0 }

  # ---------- choix de l'encodeur --------------------------------------
  $gpu = $false
  if (-not $Cpu -and -not $dixBits) {
    $gpu = [bool](& ffmpeg -hide_banner -encoders 2>$null | Select-String -SimpleMatch 'h264_amf')
  }
  $nomEnc = if ($gpu) { 'GPU AMD (h264_amf)' }
            elseif ($dixBits) { "processeur (libx264) — source 10 bits, le GPU ne sait pas" }
            else { 'processeur (libx264)' }

  Info ("  Durée  : {0} s à {1} images/s · {2}" -f (D $duree), (D $fps), $PixFmt)
  Info  "  Encodeur : $nomEnc"
  Write-Host ''

  # ---------- audio extrait une fois, l'analyse est alors instantanée ---
  Info '  [1/3] Analyse de la bande son...'
  $wav = Join-Path $tmp 'a.wav'
  & ffmpeg -hide_banner -v error -y -i "$($src.FullName)" -map 0:a:0 -vn -ac 1 -ar 16000 "$wav" 2>$null | Out-Null
  if (-not (Test-Path $wav)) { Erreur "Extraction audio impossible."; Fin 1 }

  # niveau crête, pour proposer un seuil adapté au fichier
  $vlog = Join-Path $tmp 'vol.txt'
  Start-Process ffmpeg -ArgumentList @('-hide_banner','-nostats','-i',$wav,'-af','volumedetect','-f','null','-') `
    -NoNewWindow -Wait -RedirectStandardError $vlog -RedirectStandardOutput (Join-Path $tmp 'n1.txt') | Out-Null
  $vtxt = Get-Content -LiteralPath $vlog -Raw
  $crete = if ($vtxt -match 'max_volume:\s*(-?[\d\.]+)') { [double]$Matches[1] } else { 0 }
  $propose = [Math]::Round([Math]::Max(-50, [Math]::Min(-18, $crete - 28)))

  # --- détection à un seuil donné -> liste des blancs -------------------
  function Blancs([double]$db) {
    $log = Join-Path $tmp ("s_" + [Math]::Abs($db) + ".txt")
    Start-Process ffmpeg -ArgumentList @('-hide_banner','-nostats','-i',$wav,
        '-af', ("silencedetect=n={0}dB:d={1}" -f (D $db 1), (D $BlancMini 3)), '-f','null','-') `
      -NoNewWindow -Wait -RedirectStandardError $log -RedirectStandardOutput (Join-Path $tmp 'n2.txt') | Out-Null
    $t = Get-Content -LiteralPath $log -Raw
    $st = [regex]::Matches($t, 'silence_start:\s*(-?[\d\.]+)') | ForEach-Object { [double]$_.Groups[1].Value }
    $en = [regex]::Matches($t, 'silence_end:\s*([\d\.]+)')     | ForEach-Object { [double]$_.Groups[1].Value }
    $r = @()
    for ($i = 0; $i -lt $st.Count; $i++) {
      $s = [Math]::Max(0.0, $st[$i]); $e = if ($i -lt $en.Count) { $en[$i] } else { $duree }
      if ($e -gt $s) { $r += ,@($s, $e) }
    }
    return ,$r
  }
  # --- blancs -> zones réellement coupées (on garde les marges) ---------
  $padA = $ImagesAvant / $fps; $padB = $ImagesApres / $fps
  function Coupes($blancs) {
    $c = @()
    foreach ($b in $blancs) {
      $a = $b[0] + $padA; $z = $b[1] - $padB
      if (($z - $a) -gt 0.05) { $c += ,@($a, $z) }
    }
    return ,$c
  }
  function Retire($coupes) { $s = 0.0; foreach ($c in $coupes) { $s += ($c[1] - $c[0]) }; return $s }

  # ---------- tableau des seuils ---------------------------------------
  if (-not $Auto -and -not $PSBoundParameters.ContainsKey('SeuilDb')) {
    Write-Host ''
    Info  "        seuil   blancs   retiré   durée finale"
    foreach ($db in @(-45, -40, -35, -30, -25, -20)) {
      $bl = Blancs $db; $co = Coupes $bl; $re = Retire $co
      $mk = if ($db -eq $propose) { '  <- proposé' } else { '' }
      $co3 = if ($db -eq $propose) { 'Green' } else { 'Gray' }
      Write-Host ("      {0,5} dB   {1,4}   {2,6} s   {3,8} s{4}" -f `
        $db, $co.Count, (D $re 1), (D ($duree - $re) 1), $mk) -ForegroundColor $co3
    }
    Write-Host ''
    Info  "  Plus le seuil est haut (-25 plutôt que -40), plus il coupe :"
    Info  "  les respirations et les bruits de bouche passent pour du blanc."
    Write-Host ''
    $rep = Read-Host "  Seuil en dB [$propose]"
    if ("$rep".Trim() -eq '') { $SeuilDb = $propose }
    elseif ("$rep".Replace(',', '.') -match '^-?\d+(\.\d+)?$') { $SeuilDb = [double](("$rep".Replace(',', '.'))) }
    else { Souci "  Valeur non comprise, on garde $propose dB."; $SeuilDb = $propose }

    $rep2 = Read-Host ("  Durée mini d'un blanc, en secondes [{0}]" -f (D $BlancMini 3))
    if ("$rep2".Trim() -ne '' -and "$rep2".Replace(',', '.') -match '^\d+(\.\d+)?$') {
      $BlancMini = [double](("$rep2".Replace(',', '.')))
    }
    Write-Host ''
  }

  # ---------- calcul définitif -----------------------------------------
  $blancs = Blancs $SeuilDb
  if ($blancs.Count -eq 0) {
    Souci "  Aucun blanc à $(D $SeuilDb 1) dB avec des blancs d'au moins $(D $BlancMini 3) s."
    Souci "  Relance en montant le seuil (par exemple -25) ou en baissant la durée mini."
    Fin 0
  }
  $coupes = Coupes $blancs
  if ($coupes.Count -eq 0) {
    Souci "  Les blancs sont trop courts pour être coupés avec cette marge."
    Souci "  Réduis -ImagesAvant / -ImagesApres, ou monte -BlancMini."
    Fin 0
  }

  $garder = @(); $curseur = 0.0
  foreach ($c in $coupes) {
    if ($c[0] -gt $curseur + 0.02) { $garder += ,@($curseur, $c[0]) }
    $curseur = [Math]::Max($curseur, $c[1])
  }
  if ($duree -gt $curseur + 0.02) { $garder += ,@($curseur, $duree) }
  if ($garder.Count -eq 0) { Erreur "Tout serait coupé — vérifie les réglages."; Fin 1 }

  $gardee = 0.0; foreach ($g in $garder) { $gardee += ($g[1] - $g[0]) }
  $retire = $duree - $gardee
  Info ("  [2/3] {0} dB · {1} coupe(s) · {2} s retirées sur {3} s ({4} %)" -f `
        (D $SeuilDb 1), $coupes.Count, (D $retire), (D $duree), [Math]::Round(100*$retire/$duree))

  # ---------- filtres (fichier : l'expression peut être très longue) ----
  # L'analyseur d'expressions de ffmpeg plafonne a 100 termes dans une somme a plat
  # (garde-fou anti-debordement de pile : au 101e il rend ENOMEM et le filtre ne
  # s'initialise pas). On assemble donc la somme en arbre equilibre : la profondeur
  # tombe a log2(n) — teste jusqu'a 3 000 segments.
  $termes = @($garder | ForEach-Object {
              "between(t,{0},{1})" -f $_[0].ToString('0.####', $inv), $_[1].ToString('0.####', $inv) })
  function Somme-Arbre([string[]]$t) {
    if ($t.Count -eq 1) { return $t[0] }
    $m = [int]($t.Count / 2)
    return '(' + (Somme-Arbre $t[0..($m-1)]) + '+' + (Somme-Arbre $t[$m..($t.Count-1)]) + ')'
  }
  $expr = Somme-Arbre $termes
  $fv = Join-Path $tmp 'v.txt'; $fa = Join-Path $tmp 'a.txt'
  # Lire le filtre depuis un fichier : « -filter_script:v » jusqu'a ffmpeg 8,
  # remplace par « -/filter:v » a partir de ffmpeg 9 (l'ancienne option a disparu).
  if (@(& ffmpeg -hide_banner -h full 2>$null | Select-String -SimpleMatch -Quiet 'filter_script')) {
    $optFiltreV = '-filter_script:v'; $optFiltreA = '-filter_script:a'
  } else {
    $optFiltreV = '-/filter:v';       $optFiltreA = '-/filter:a'
  }
  [IO.File]::WriteAllText($fv, "select='$expr',setpts=N/FRAME_RATE/TB", [Text.UTF8Encoding]::new($false))
  [IO.File]::WriteAllText($fa, "aselect='$expr',asetpts=N/SR/TB",       [Text.UTF8Encoding]::new($false))

  # ---------- encodage --------------------------------------------------
  Info '  [3/3] Encodage...'
  Write-Host ''
  $vTargetK = if ($mbSrc -gt 0) { [int](($mbSrc * 1000) - $ABr) } else { 0 }
  if ($DebitSource -and $vTargetK -lt 500) { $DebitSource = $false }

  if ($gpu) {
    $enc = if ($DebitSource) {
             @('-c:v','h264_amf','-quality','quality','-rc','vbr_peak',
               '-b:v',"${vTargetK}k",'-maxrate',"$([int]($vTargetK*1.4))k")
           } else {
             @('-c:v','h264_amf','-quality','quality','-rc','cqp',
               '-qp_i',"$Qp",'-qp_p',"$Qp",'-qp_b',"$($Qp+2)")
           }
  } else {
    $enc = @('-c:v','libx264','-preset',$Preset)
    $enc += if ($DebitSource) {
              @('-b:v',"${vTargetK}k",'-maxrate',"$([int]($vTargetK*1.4))k",'-bufsize',"$([int]($vTargetK*2.5))k")
            } else { @('-crf',"$Crf") }
    if ($Threads -gt 0) { $enc += @('-threads', "$Threads") }
  }

  $args2 = @('-hide_banner','-y','-i', $src.FullName,
             $optFiltreV, $fv, $optFiltreA, $fa,
             '-map','0:v:0','-map','0:a:0') + $enc + @(
             '-pix_fmt',$PixFmt,'-fps_mode','cfr',
             '-c:a','aac','-b:a',"${ABr}k",'-ar','48000',
             '-movflags','+faststart', $dst)
  $t0 = Get-Date
  & ffmpeg @args2
  $ok = $?
  $secs = ((Get-Date) - $t0).TotalSeconds

  # ---------- contrôle : le code de retour de ffmpeg ne suffit pas ------
  $frames = & ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of csv=p=0 -- "$dst" 2>$null
  $dOut   = & ffprobe -v error -show_entries format=duration -of csv=p=0 -- "$dst" 2>$null
  Write-Host ''
  if (-not $ok -or -not $dOut -or [double](("$dOut" -replace ',','.')) -lt ($gardee * 0.9)) {
    Erreur '  L''encodage a échoué ou le fichier est incomplet.'
    Erreur '  Cause la plus fréquente : plus de place sur le disque de sortie.'
    if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Force }
    Fin 1
  }

  Bien ("  Terminé en {0} s — {1} s -> {2} s ({3} s de blancs retirés)" -f `
        [Math]::Round($secs), (D $duree), (D ([double](("$dOut" -replace ',','.')))), (D $retire))
  Bien ("  $frames images · " + (Split-Path $dst -Leaf))

  $vBrOut = @(& ffprobe -v error -show_entries format=bit_rate -of csv=p=0 -- "$dst" 2>$null)[0]
  if ($mbSrc -gt 0 -and "$vBrOut" -match '^\d+$') {
    $mbOut = [double]$vBrOut / 1e6
    $ecart = 100 * ($mbOut - $mbSrc) / $mbSrc
    Info ("  Débit : {0} -> {1} Mbit/s ({2:+0;-0} %)" -f (D $mbSrc 1), (D $mbOut 1), $ecart)
    if ($ecart -lt -25 -and -not $DebitSource) {
      Info "  (normal : le codeur est plus efficace que l'export CapCut."
      Info "   Pour un fichier au même débit qu'avant : -DebitSource.)"
    }
  }
  Info  "  Dossier : $($src.DirectoryName)"
  Fin 0
}
catch {
  Write-Host ''
  Erreur "  Erreur : $($_.Exception.Message)"
  Fin 1
}
finally {
  if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}
