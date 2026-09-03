# Supprimer les blancs

Clic droit sur une vidéo → **Supprimer les blancs**. L'outil détecte les silences,
te laisse choisir à quel point il doit être sévère, les coupe, et écrit
`<nom> - sans blancs.mp4` à côté. **L'original n'est jamais modifié.**

## Installation

Double-clic sur **`Installer le menu clic droit.cmd`**. Rien d'autre à installer :
ffmpeg est déjà sur la machine.

Deux accès sont posés :

- **clic droit → Afficher plus d'options → Supprimer les blancs**
  (sur Windows 11 le menu court est réservé aux applications signées ;
  **Maj + clic droit** ouvre directement le menu complet)
- **clic droit → Envoyer vers → Supprimer les blancs** — celui-là marche toujours,
  il ne dépend pas du cache de l'explorateur.

Formats : `.mp4 .mov .mkv .avi .m4v .webm .mts .m2ts`.
Pour retirer les entrées : `Desinstaller le menu clic droit.cmd`.

## Choisir la sévérité — le tableau

À chaque lancement, l'outil mesure la bande son et affiche ce que donnerait
chaque seuil sur **ce fichier précis** :

```
      seuil   blancs   retiré   durée finale
      -45 dB      8      2.1 s      117.0 s
      -40 dB     14      4.8 s      114.3 s
      -35 dB     23      9.2 s      109.9 s
      -30 dB     38     16.4 s      102.7 s  <- proposé
      -25 dB     51     24.9 s       94.2 s
      -20 dB     66     35.1 s       84.0 s

  Seuil en dB [-30] :
```

**Plus le seuil est haut (−25 plutôt que −40), plus il coupe.** C'est le réglage
qui règle ton problème de micro-bruits : à −40 dB une respiration ou un bruit de
bouche compte comme du son et empêche la coupe ; à −25 dB elle passe pour du blanc
et le passage est coupé.

Tu tapes la valeur que tu veux — **n'importe quelle valeur**, `-28`, `-31.5` — ou
Entrée pour prendre celle qui est proposée (calculée sur le niveau crête du fichier).
Deuxième question : la durée minimale d'un blanc pour qu'il soit coupé
(0,30 s par défaut ; baisse-la pour attraper les hésitations courtes).

Pour tout passer en ligne de commande et ne rien avoir à répondre :

```powershell
powershell -File "D:\Outils\supprimer-blancs\supprimer-blancs.ps1" "C:\ma video.mp4" -SeuilDb -28 -BlancMini 0.2
```

`-Auto` prend les valeurs par défaut sans rien demander.

## La marge autour des coupes

On garde **5 images avant** le blanc et **3 après**, pour que la voix ne reparte
pas au ras de la coupe. La marge est en **images**, donc elle s'adapte seule à
25, 30 ou 60 i/s.

```powershell
... -ImagesAvant 3 -ImagesApres 2     # plus sec
```

## La vitesse

L'encodage se fait sur le **GPU** (Radeon RX 7800 XT, encodeur `h264_amf`).
Mesuré sur 30 secondes de 1080×1920 :

| Encodeur | Temps | Qualité (SSIM) |
|---|---|---|
| Processeur, preset `slow` | 39 s | 0,9949 |
| **GPU AMD** | **3 s** | **0,9941** |

Treize fois plus rapide pour une différence de qualité invisible — et à débit
légèrement supérieur. Le processeur reste utilisé automatiquement si la source
est en 10 bits (le GPU ne sait pas encoder du H.264 10 bits), ou avec `-Cpu`.

## La qualité

Couper au milieu d'un plan **oblige à réencoder** : une coupe propre ne tombe
jamais sur une image-clé. L'outil est réglé pour que ça ne se voie pas :

- **QP 18 sur GPU** (ou CRF 16 sur processeur) — transparent à l'œil
- **le format de pixel de la source est conservé** (une source 10 bits le reste)
- **l'audio n'est jamais réencodé sous le débit de la source**

### « Mon fichier est plus léger, j'ai perdu de la qualité ? »

Non. On vise une **qualité**, pas une taille. Un export CapCut est à débit fixe,
donc généreux là où il n'y a rien à décrire et juste là où il en faudrait.
L'outil affiche la comparaison des débits à la fin pour que tu juges.

Si tu veux un fichier **au même débit que l'original** : ajoute `-DebitSource`.
Pour encoder encore plus large : `-Qp 14` (GPU) ou `-Crf 14 -Cpu`.

## Ce qu'il faut savoir

- **Sur un rush brut**, l'outil retire beaucoup — c'est là qu'il sert. Sur une
  vidéo déjà montée serré il ne trouvera presque rien : c'est normal.
- **Il ne coupe que d'après le son.** Si tu bouges pendant un blanc, la coupe se
  verra comme un jump cut. C'est le principe.
- L'outil **vérifie le fichier produit** avant de dire que c'est bon. Si le disque
  est plein, il le dit et supprime le fichier incomplet — ffmpeg, lui, sort en
  « succès » avec un fichier illisible.

## Si ça ne marche pas

| Symptôme | Cause |
|---|---|
| L'entrée n'apparaît pas au clic droit | Passe par **Envoyer vers**. Ou relance l'installeur : il redémarre l'explorateur. |
| « ffmpeg est introuvable » | L’outil repare le PATH tout seul. S’il n’y arrive pas, ffmpeg a ete desinstalle : `winget install Gyan.FFmpeg`. |
| « Unrecognized option filter_script » | Corrige le 2 septembre 2026 : ffmpeg 9 a supprime cette option, l’outil detecte la version et bascule sur `-/filter`. |
| « Error while parsing expression » ou « Cannot allocate memory » | Corrigé le 2 septembre 2026 : au-delà de 100 coupes ffmpeg refusait l'expression, elle est maintenant assemblée en arbre. |
| « Aucun blanc » | Monte le seuil (−25) ou baisse la durée mini (0,15). |
| La fenêtre se ferme aussitôt | Le `.ps1` doit rester en **UTF-8 avec BOM** — sinon PowerShell 5.1 lit les accents en ANSI et refuse le script. |
