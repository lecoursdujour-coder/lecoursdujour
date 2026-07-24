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

## Skills incluses
- Finance : comptabiliser-operations-retraitements, maj-reporting-trimestriel-lr,
  reinitialiser-matrice-trimestre, repliquer-trame-reporting-trimestriel
- Montage / vidéo : hyperframes-read-first, hyperframes-core, hyperframes-animation,
  hyperframes-cli, hyperframes-media, hyperframes-registry, general-video,
  embedded-captions, graphic-overlays, motion-graphics
