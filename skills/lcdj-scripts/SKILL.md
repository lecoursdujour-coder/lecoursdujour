---
name: lcdj-scripts
description: Écrire et auditer les scripts de tournage des vidéos « Le Cours du Jour » (chaîne finance/épargne verticale 9:16, une personne face caméra). À utiliser quand on demande de rédiger les scripts d'une semaine, d'auditer un script existant, de vérifier les chiffres d'une vidéo, ou de préparer un Débunk, un Cours 60, un Cours 40 entreprise, un Cours Produits, un Vrai ou Faux, une Géopolitique ou un Ton argent. Déclencheurs : « rédige la semaine N », « scripts semaine », « audit du script », « prépare la vidéo du lundi/mardi/…», « Cours 40 sur telle entreprise ».
---

# Scripts de tournage — Le Cours du Jour

## Ce qu'on livre

Un **document Google Docs par semaine**, dans le dossier Drive `Le cours du jour / PLANIFICATION / SEMAINES — détail des vidéos`. Titre : `Semaine N (dates) — SCRIPTS DE TOURNAGE`. C'est le document qu'on emmène sur le plateau : il doit se suffire à lui-même.

**Jamais de doc par vidéo** — un doc par semaine, sept vidéos dedans. Les versions périmées vont dans `PLANIFICATION / ARCHIVE`, renommées `ARCHIVE — … (raison)`, pour qu'on ne tourne jamais la mauvaise.

## Le processus, dans cet ordre

1. **Lire le brief** de la semaine dans `Semaines N à M — briefs figés`. Ne jamais partir de zéro : le brief porte l'arc éditorial, les renvois entre vidéos et les décisions de comité.
2. **Auditer tous les chiffres du brief** avant d'écrire. Voir `references/audit.md`. Les briefs datent de plusieurs semaines : sur les 14 vidéos des semaines 3 et 4, **dix chiffres étaient faux ou périmés**. C'est l'étape qui a le plus de valeur.
3. **Écrire les blocs parlés**, puis **calculer le minutage** avec `scripts/minutage.py`. Jamais l'inverse : les minutages écrits à la main sont systématiquement faux.
4. **Vérifier la durée cible** (voir `references/formats.md`). Si un script sort hors fourchette, on allonge en ajoutant un bloc qui manquait vraiment — jamais du remplissage.
5. **Rédiger les captures et les notes** « À ne pas rater ». Les notes sont la moitié de la valeur du document.

## La structure d'un script

Toujours ces cinq sections, dans cet ordre :

1. **Chapeau** — format, cible à l'écran, l'idée unique en une phrase, longueur écrite (mots, secondes dites, secondes à l'écran).
2. **Hooks — choisir un, tourner les trois.** Trois accroches, la meilleure en premier avec une parenthèse qui dit pourquoi.
3. **Le script** — tableau à trois colonnes : `TEMPS (dit)` · `CE QU'ON DIT` · `CE QU'ON VOIT`. Le texte dit est écrit **tel qu'il sera prononcé**, chiffres en toutes lettres. La colonne visuelle nomme les INCRUST, SCHÉMA, VISUEL, et se termine par la `Pastille :`.
4. **Les captures à faire** — sources nominatives, avec ce qu'il faut y surligner. Signaler celle qui « porte la vidéo ». Marquer ⚠️ les données mouvantes à relever le jour du tournage. Finir par `À FABRIQUER`.
5. **À ne pas rater** — une puce ⚠️ par piège. C'est ici qu'on met les nuances qu'on a volontairement sorties de l'oral, les formulations à ne pas glisser, les phrases qui ne se coupent jamais, et la conformité.

## Les règles qui ne se négocient pas

- **Une vidéo = une idée.** Si deux vidéos pourraient porter le même titre, c'est le même angle : il faut trancher.
- **La concession est l'argument**, pas une précaution. Un débunk qui ne concède rien n'est pas cru.
- **On corrige le fait, jamais la personne.** Ne jamais caricaturer la croyance de départ — on lui donne raison, puis on explique pourquoi elle se trompe d'objet.
- **Cohérence inter-vidéos.** Un chiffre ou un exemple utilisé une semaine ne doit pas être contredit la suivante.
- **Tout chiffre mouvant est daté à l'écran.** C'est la signature de la chaîne.
- **Conformité** : aucun nom d'assureur, de courtier, d'ETF, d'émetteur ni de plateforme. Les sociétés cotées peuvent être nommées — on décrit des comptes publics, on ne recommande jamais.

Le détail est dans `references/regles-editoriales.md`.

## Les outils

- `scripts/minutage.py` — calcule le nombre de mots, le minutage bloc par bloc, le débit en mots/minute et la durée à l'écran. **À lancer sur chaque script avant de publier.**
- `references/formats.md` — les sept formats, leurs durées, leurs débits, leurs gabarits.
- `references/regles-editoriales.md` — registre, conformité, renvois, pastilles.
- `references/audit.md` — la méthode de vérification des chiffres et les pièges déjà rencontrés.

## Ce qui fait la différence

Le document n'a pas de valeur parce qu'il contient un script. Il en a parce qu'il contient **ce qu'on a vérifié, ce qu'on a écarté, et pourquoi**. Une note « ⚠️ ne jamais dire X, parce que Y » vaut plus qu'un paragraphe de script.

Chercher systématiquement **l'alpha** : le chiffre ou l'angle que personne ne sort. Souvent il est dans la donnée qu'on a écartée comme trop technique — il suffit de la reformuler en langage ordinaire.
