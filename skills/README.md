# Skills en source claire

Ce dossier contient les skills **en source lisible**, une par sous-dossier. Le dépôt
distribue par ailleurs `lecoursdujour-skills.plugin`, qui est le bundle installable.
Les deux doivent rester cohérents : **on modifie ici, puis on régénère le bundle.**

## Ce qu'il y a dedans

- **`lcdj-scripts/`** — écrire et auditer les scripts de tournage des vidéos.
  Formats et durées, débits de parole réels, règles éditoriales, méthode d'audit des
  chiffres, et un outil de minutage. Écrit le 3 septembre 2026 après la rédaction des
  semaines 3 et 4.

## Installer sans attendre le bundle

Le plus simple pour tester tout de suite, sans régénérer le `.plugin` :

```
cp -r skills/lcdj-scripts ~/.claude/skills/
```

Sur Windows, copier le dossier `skills\lcdj-scripts` dans `C:\Users\<vous>\.claude\skills\`.
Le skill est disponible à la conversation suivante — vérifier en demandant à Claude
« quels skills as-tu ? ».

## L'ajouter au bundle

Quand on régénère `lecoursdujour-skills.plugin`, inclure ce dossier pour que Franz et
les autres l'aient au prochain **Pull + réinstallation**. Rappel du piège documenté dans
`INSTALLER_LE_PLUGIN.md` : **un Pull ne met pas à jour le plugin**, il faut rouvrir le
`.plugin` dans Claude.

## Structure d'un skill

```
nom-du-skill/
  SKILL.md            frontmatter (name, description avec ses déclencheurs) + le processus
  references/*.md     ce qu'on charge à la demande, pas au démarrage
  scripts/*.py        les outils exécutables
```

Le `SKILL.md` reste court : il dit quoi faire et dans quel ordre, et renvoie aux
références pour le détail. La `description` du frontmatter doit contenir les phrases
qui déclenchent le skill — c'est elle qui décide s'il se charge ou non.
