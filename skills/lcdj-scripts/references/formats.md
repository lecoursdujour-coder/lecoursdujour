# Les formats — durées, débits, gabarits

## La règle de durée

**Formats courts : 1 min à 1 min 15 à l'écran.** En dessous de 60 s, le script est trop maigre : il manque un bloc. Au-dessus de 75 s, il faut couper.

**Cours 40 (mercredi, entreprise) : 2 min 30 à l'écran.** C'est le seul format long de la semaine.

**Vrai ou Faux (vendredi) : 40 à 45 s à l'écran.** Format à part, plus court par nature.

## Le débit réel

C'est le paramètre le plus souvent faux dans les briefs. Débits mesurés et tenables :

| Format | Débit | Pourquoi |
| :- | :-: | :- |
| Débunk (lundi) | **155 mots/min** | débit posé, on corrige une croyance, on ne court pas |
| Cours 60, Cours Produits | **158 mots/min** | pédagogique, chiffres qui doivent atterrir |
| Géopolitique (samedi) | **160 mots/min** | narratif |
| Cours 40 (mercredi) | **165 mots/min** | format long, rythme plus soutenu |
| Vrai ou Faux (vendredi) | **165 mots/min** | sec, coupes franches |

**Au-delà de 175 mots/min, ce n'est pas tenable face caméra.** Un bloc qui dépasse est un bloc à réécrire, pas à accélérer.

**Durée à l'écran ≈ durée dite × 0,9.** Le montage resserre d'environ 10 %.

## Formule

`durée d'un bloc (s) = nombre de mots ÷ débit × 60`

Utiliser `scripts/minutage.py`, jamais l'estimation à l'œil.

## Les sept formats de la semaine

### LUNDI — Débunk
Une croyance répandue, démontée. **La concession d'abord** : on donne raison au spectateur sur un point avant de reprendre sur les autres. Structure type : croyance → le point vrai → les torts, un par bloc → le vrai débat → chute qui oppose deux lectures.
Ne jamais caricaturer la croyance. La bonne ouverture donne raison au spectateur.

### MARDI — Cours 60
Une notion expliquée, avec un calcul chiffré. Hypothèses affichées en permanence pendant tout le calcul, mention « hors frais » ou « hors fiscalité » selon le cas. Toujours finir sur les limites — « deux limites, et on les dit ».

### MERCREDI — Cours 40 (entreprise), format mi-long
Six blocs : ouverture (croyance vs fait) → histoire et frise → les faits chiffrés du dernier exercice → le mécanisme économique (pricing power, ratio combiné, modèle) → un fait de contrôle ou de structure que personne ne raconte → fragilité et **carton VERDICT**.
Registre : **ni éloge ni procès**. Le verdict décrit une entreprise, il ne donne jamais d'avis sur l'action.
Logos : le logo de la société seul à l'image une seconde en ouverture, puis un logo par entreprise citée au moment où son nom est prononcé.

### JEUDI — Cours Produits
Un produit ou un mécanisme, décortiqué. Finir par un ou deux réflexes actionnables (un droit, un geste de vérification). Toujours une phrase qui empêche de lire la vidéo comme une recommandation.

### VENDREDI — Vrai ou Faux · miroir
**Quatre questions, une par vidéo de la semaine**, dans l'ordre lundi / mardi / mercredi / jeudi — sauf raison éditoriale explicite (ex. séparer deux questions du même sujet qui se suivent).
Réponse en un mot — **VRAI / FAUX / NUANCE** — suivie de la justification chiffrée.
**Zéro terme technique, zéro chiffre qui n'ait été dit dans la semaine.** Un miroir ne doit rien apprendre de neuf sur les faits : il doit faire re-comprendre.
Aucune capture nouvelle : on remonte les visuels déjà fabriqués. C'est ce qui permet de la tourner en dernier, très vite.
Compteur 1/4 à l'écran, coupe sèche entre chaque question, pastille qui claque sur la réponse, aucun silence.

### SAMEDI — Géopolitique
Un pays, un secteur ou une matière première. **Toujours une chaîne de transmission explicite** : le fait → le mécanisme → « ce que ça change pour VOTRE argent » (ETF, PEA, crédit, fonds euros).
Garder la chaîne à quatre ou cinq maillons maximum. Un indicateur ou un graphique daté à l'écran.
Souvent en tie-in avec le Cours 40 du mercredi.

### DIMANCHE — Ton argent · actu
Trois faits d'actualité argent maximum, arrêtés au comité du samedi. Pour chacun : le fait en une phrase → « pour vous, ça veut dire… » → qui est concerné. Zéro jargon.
Si une actu domine, basculer en mono-sujet.
**Règle d'or quand le sujet est législatif : rien n'est voté.** Bandeau à l'écran du début à la fin, distinction présenté / amendé / adopté dite au moins deux fois.

## Éléments communs

- Vertical 9:16, une personne face caméra.
- Hooks : **trois, on en tourne trois**, la meilleure annoncée en premier.
- Chaque bloc visuel se termine par une `Pastille :` en majuscules.
- Fin : `Abonne-toi.` puis carton de fin + disclaimer. Le Cours 40 ajoute « sources en description ».
- Sous-titres v08 sur les mots à pastiller.
