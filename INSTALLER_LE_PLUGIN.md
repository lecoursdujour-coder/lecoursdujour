# Installer le plugin « lecoursdujour-skills »

## ⚡ La mise à jour automatique — À FAIRE UNE FOIS PAR MACHINE

> Version détaillée, écrite pour être suivie par Claude sur une machine neuve :
> le document « SKILLS — Installation sur une nouvelle machine » à la racine du Drive
> « Le cours du jour ». Il couvre le clonage, le dépannage et ce qu il ne faut pas faire.


Depuis le 9 septembre 2026, **un simple pull suffit** pour avoir les skills à jour.
Plus besoin de rouvrir le `.plugin` dans Claude à chaque version.

**Une seule manipulation, une seule fois :**

1. Récupérer le dépôt (GitHub Desktop : **Pull / Fetch origin**).
2. Double-cliquer sur **`Activer la mise a jour auto.cmd`**, à la racine du dépôt.
3. Redémarrer Claude Code.

C'est tout. À partir de là, **chaque pull réinstalle les skills tout seul** : un hook
git recopie les skills du bundle dans `~/.claude/skills/`, d'où Claude les lit
directement. Le message `[LCDJ] N skill(s) a jour...` s'affiche après chaque pull.

**Il reste une seule chose à faire à la main : redémarrer Claude Code après un pull.**
Les fichiers sont posés, mais Claude ne les relit qu'au lancement.

### Ce qui est installé automatiquement, et ce qui ne l'est pas

La liste est dans **`outils/skills-a-installer.txt`** — une skill par ligne, modifiable
sans toucher au code. On n'y met que les skills **qu'on écrit nous-mêmes** :
`sous-titres-lcdj`, `lcdj-scripts`, `watch`, `find-skills`.

Les skills tierces (hyperframes-*, viral-*, embedded-captions, general-video,
graphic-overlays, motion-graphics) restent servies par le `.plugin` : elles ne changent
jamais, et les installer des deux côtés les ferait **apparaître en double**.

⚠️ Si une skill apparaît deux fois dans Claude — une fois sous son nom seul, une fois
sous `lecoursdujour-skills:nom` — c'est qu'elle est à la fois dans la liste et dans le
plugin installé. Retirer la ligne du fichier, ou désinstaller le plugin dans Claude.

### Pourquoi ce changement

Le 9 septembre 2026, cette machine tournait avec un plugin si ancien que
`sous-titres-lcdj` n'y était même pas — alors que le dépôt était en 0.17.0. Le symptôme
est silencieux : Claude ne signale pas qu'il lui manque une skill, il fait sans. C'est
exactement ce que ce mécanisme supprime.

### Si ça ne marche pas

- Vérifier que les hooks sont actifs : `git config core.hooksPath` doit répondre
  `.githooks`. Sinon, relancer le `.cmd`.
- Lancer l'installation à la main : `sh outils/installer-skills.sh` depuis le dépôt.
- Le script ne fait **jamais** échouer un pull : en cas de problème il prévient et
  s'arrête là.

---


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

Version actuelle du dépôt : **0.17.0**.

## Skills incluses
- **Scripts de tournage : lcdj-scripts** — écrire et auditer les scripts. Les sept formats
  et leurs durées, le débit réel mesuré (155-165 mots/min), `minutage.py` pour le minutage
  bloc par bloc, les règles éditoriales, la méthode d'audit des chiffres et où chercher
  un chiffre (sources primaires par famille de sujet, sociétés cotées, règle de fraîcheur).
- Finance : comptabiliser-operations-retraitements, maj-reporting-trimestriel-lr,
  reinitialiser-matrice-trimestre, repliquer-trame-reporting-trimestriel
- Montage / vidéo : hyperframes-read-first, hyperframes-core, hyperframes-animation,
  hyperframes-cli, hyperframes-media, hyperframes-registry, general-video,
  embedded-captions, graphic-overlays, motion-graphics
- Contenu viral court format : viral-short-form, viral-short-form-ideas, viral-hooks,
  viral-captions-and-ctas, viral-tiktok-content, viral-instagram-reels,
  viral-youtube-shorts
- Sous-titres, visuels, fin de vidéo et MINIATURE : sous-titres-lcdj — le standard de
  montage verrouillé (moteur v08 pastille jaune, cartes sources, logos officiels et
  contours de pays, outro logo/Abonne-toi) **et la miniature 1080×1920**, désormais
  fusionnée dedans. Une seule demande de montage sort la vidéo nommée, sa miniature
  et le titre ; la miniature se fait aussi seule, pour une vidéo ou toute une semaine.
  *(Le skill séparé `miniatures-lcdj` a disparu en 0.16.0 : sa méthode est dans
  `MINIATURES.md`, et le moteur qui existait en double n'a plus qu'un exemplaire.)*
- Analyse vidéo : watch (regarder une vidéo, en extraire frames et transcription)
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

## ⚠️ Deux pièges pour qui reconstruit le `.plugin`

Le fichier `.plugin` est une **archive TAR**. On l'extrait, on modifie, on repacke —
et deux choses cassent silencieusement.

**1. Le chemin de sortie du `tar` doit être en POSIX.** Sous Git Bash, un chemin de
la forme `C:/Users/...` est interprété comme un **hôte distant** :

```
tar: Cannot connect to C: resolve failed
```

Le tar échoue, mais la commande enchaînée derrière (`git add`, `git commit`) réussit.
Résultat : un commit qui annonce une nouvelle version et ne contient que la doc.
C'est arrivé le 8 septembre 2026 — il a fallu un second commit pour livrer le bundle.

```bash
cd <build> && tar -cf /c/Users/zianm/.../lecoursdujour-skills.plugin \
  ".claude-plugin" "README.md" "skills"     # /c/... et jamais C:/...
```

**Contrôle d'aller-retour obligatoire** avant de committer : réextraire l'archive,
compter les fichiers, et vérifier la version dans `plugin.json`.

**2. Il y a deux clones du dépôt sur la machine de Zian.**

```
C:\Users\zianm\Documents\GitHub\lecoursdujour            <- celui de GitHub Desktop
C:\Users\zianm\OneDrive\Documents\GitHub\lecoursdujour   <- un second, distinct
```

Ce ne sont pas le même dossier (inodes différents), malgré la redirection OneDrive
habituelle. Travailler dans l'un pendant que l'autre est en retard, c'est se préparer
un écrasement. **Toujours `git fetch` et vérifier `git status -sb` dans le clone
qu'on s'apprête à modifier**, et pousser depuis celui-là seulement.
