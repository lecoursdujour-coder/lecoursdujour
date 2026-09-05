# Installer le plugin « lecoursdujour-skills »

Ce dépôt contient le fichier **`lecoursdujour-skills.plugin`** : il regroupe les skills
personnalisées du projet (finance / matrice LR + montage vidéo HyperFrames).
Une fois installé, Claude peut les utiliser.

## Pour l'installer (chaque personne, une fois)
1. Récupérer le dépôt à jour (dans GitHub Desktop : bouton **Pull / Fetch origin**).
2. Le fichier `lecoursdujour-skills.plugin` se trouve dans le dossier du dépôt.
3. Ouvrir ce fichier dans **Claude (application Cowork / bureau)** : il apparaît avec
   un bouton pour **accepter / installer** le plugin.
4. C'est fait — les skills sont disponibles dans tes conversations.

## Pour mettre à jour le plugin plus tard
La personne qui modifie les skills régénère le fichier `.plugin`, le remplace dans le
dépôt et pousse (**Commit** + **Push**). Les autres font **Pull** puis réinstallent
le nouveau fichier `.plugin`.

## ⚠️ Vérifier quelle version tu as VRAIMENT installée
Un **Pull** ne met pas à jour le plugin — il ne fait que télécharger le fichier.
Tant qu'on ne rouvre pas le `.plugin` dans Claude, on continue de tourner sur
l'ancienne version sans s'en rendre compte.

C'est arrivé le 1er sept. 2026 : machine encore en **0.1.0** alors que le dépôt
était en **0.7.0** — le skill `sous-titres-lcdj` n'existait tout simplement pas
côté Claude, et il a fallu le sortir du bundle à la main pour monter la vidéo 3.

Pour vérifier en 10 secondes : demander à Claude « **quels skills lecoursdujour
as-tu ?** ». Si `sous-titres-lcdj` n'est pas dans la liste, la réinstallation
n'a pas été faite.

Version actuelle du dépôt : **0.13.0**.

## Skills incluses
- Finance : comptabiliser-operations-retraitements, maj-reporting-trimestriel-lr,
  reinitialiser-matrice-trimestre, repliquer-trame-reporting-trimestriel
- Montage / vidéo : hyperframes-read-first, hyperframes-core, hyperframes-animation,
  hyperframes-cli, hyperframes-media, hyperframes-registry, general-video,
  embedded-captions, graphic-overlays, motion-graphics
- Contenu viral court format : viral-short-form, viral-short-form-ideas, viral-hooks,
  viral-captions-and-ctas, viral-tiktok-content, viral-instagram-reels,
  viral-youtube-shorts
- Sous-titres, visuels, fin de vidéo et MINIATURE : sous-titres-lcdj (moteur v08 pastille jaune + outro logo/Abonne-toi + miniature verticale 1080x1920 obligatoire + bibliothèque de cartes, cartes de pays et récupération de logos officiels — le standard verrouillé, assets inclus)
- Découverte de skills : find-skills

## L outil « supprimer les blancs » (hors plugin)

Il est dans le dossier **`outils/supprimer-blancs/`** du dépôt, pas dans le `.plugin` :
c est un script Windows, pas un skill.

1. Copier le dossier `outils/supprimer-blancs` dans **`D:Outils`**.
2. Double-cliquer sur **`Installer le menu clic droit.cmd`**.
3. Clic droit sur une vidéo → **Supprimer les blancs**.

⚠️ Le `.ps1` doit rester en **UTF-8 avec BOM** : sans lui, PowerShell 5.1 lit les
accents en ANSI et refuse le script. GitHub le préserve, une copie manuelle pas
toujours. Détails et dépannage : `outils/supprimer-blancs/LISEZ-MOI.md`.
