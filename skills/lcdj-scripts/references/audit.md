# Auditer les chiffres — méthode et pièges connus

L'audit est l'étape qui a le plus de valeur. Sur les 14 vidéos des semaines 3 et 4, **dix chiffres du brief étaient faux ou périmés**. Un brief a en général plusieurs semaines : la moitié de ses chiffres a bougé.

## La méthode

1. **Lister tous les chiffres du brief**, y compris ceux marqués ✅.
2. **Remonter à la source primaire.** Communiqué de l'émetteur, texte de loi, publication d'autorité. Jamais un article de presse comme source unique : recouper deux sources par chiffre, et **prendre le chiffre de l'émetteur** quand il diffère de la presse (AXA publie 116 Md€ et +6 %, la presse a repris 115,5 et +5 %).
3. **Recalculer soi-même** toute simulation, avec un script, jamais à la main. Sauvegarder les hypothèses.
4. **Recompter les mots case par case** — les minutages fournis sont régulièrement impossibles (deux cases exigeaient 253 et 256 mots/min).
5. **Écrire ce qu'on a corrigé** dans une section « ⚠️ CE QUE L'AUDIT A CORRIGÉ » en tête du document, avec le chiffre faux, le bon, et pourquoi ça change quelque chose.

## Les six pièges récurrents

**1. La donnée a changé depuis le brief.** Réflexe : pour toute donnée fiscale, réglementaire ou de marché, vérifier la dernière loi de finances et la dernière LFSS. Exemple : la LFSS 2026 a porté la CSG sur les revenus du capital de 9,2 % à 10,6 %, donc les prélèvements sociaux de 17,2 % à 18,6 % — **sauf l'assurance-vie, les PEL/CEL, les revenus fonciers et les plus-values immobilières, qui restent à 17,2 %**. Un brief écrit avant janvier 2026 porte les anciens taux.

**2. Le chiffre d'une entreprise généralisé à un marché.** AXA a un ratio combiné de 90,6 % (9,40 € de marge sur 100 €), le marché français non-vie est à 95,3 % (moins de 5 €). Utiliser le premier pour parler « des assureurs » est une faute. **Toujours vérifier le périmètre avant de généraliser.**

**3. Deux notions qui portent le même nom.** « La clientèle chinoise du luxe » vaut 12 % (marché de Chine continentale) ou ~30 % (consommateurs chinois où qu'ils achètent). Les deux sont vrais et ne mesurent pas la même chose. **Utiliser celui de la capture, et écrire la distinction dans les notes.**

**4. Plusieurs périmètres officiels coexistent.** La charge de la dette française vaut 74 Md€ (toutes APU), ~58 Md€ (État, comptabilité budgétaire) ou ~60 Md€ (mission budgétaire). **Chaque chiffre affiché porte son périmètre à l'écran, et on ne mélange jamais deux périmètres dans une phrase.** Dans le doute, formulation prudente : « l'un des deux premiers budgets » plutôt que « le premier budget ».

**5. Un résultat net gonflé par un exceptionnel.** Le bénéfice net d'AXA bondit de 26 % en 2025 parce qu'il contient la plus-value de cession d'AXA IM. **Pour une marge courante, prendre le résultat opérationnel**, jamais le net.

**6. La prémisse du brief est contredite par les comptes.** « Pourquoi tout le monde veut l'action LVMH » alors que 2025 fait −1 % de ventes et −13 % de bénéfice. **Quand ça arrive, retourner l'angle sur l'écart lui-même** — c'est presque toujours une meilleure vidéo.

## Les données à relever le jour du tournage

Marquer ⚠️ dans les captures, et **tourner une prise alternative sans les décimales** :

- taux souverains (Bund, OAT), spreads — quotidien
- taux moyens de crédit immobilier — mensuel
- pondérations d'indice (poids d'un pays, d'une valeur, d'un secteur) — quotidien
- compteurs de dette publique — continu
- registres AMF (prestataires agréés, listes noires) — continu
- nombre de clients, de salariés, de pays d'un groupe — à chaque publication

**Un chiffre mouvant sans sa date affichée est un chiffre en l'air.**

## Quand un chiffre n'est pas sourçable

Ne pas l'inventer, ne pas le reprendre du brief. Deux options :
- **le remplacer par un ordre de grandeur qualitatif** (« une minorité » plutôt qu'un pourcentage de 2021),
- **ou changer de chiffre** pour un plus fort et parfaitement sourcé (la base de clients du luxe passée de 400 à 340 millions vaut mieux qu'un pourcentage discutable).

Et l'écrire dans les notes : « X n'est pas sourçable, voici ce qui l'est ».

## Le contrôle de vraisemblance des durées

Lancer `scripts/minutage.py` sur chaque script. Signaux d'alerte :
- un bloc au-dessus de **175 mots/min** → intenable, réécrire le bloc
- un total à l'écran **sous 60 s** (formats courts) → il manque un bloc
- un total à l'écran **au-dessus de 75 s** → couper, en protégeant la concession et la chute

## Vérifier aussi la cohérence de la semaine

- Deux vidéos qui pourraient porter le même titre → collision, à trancher.
- Un exemple utilisé lundi contredit par mardi → cohérence cassée. Cas réel : l'assurance-vie ne peut pas servir d'exemple d'argent immobilisé longtemps dans une semaine où le lundi affirme qu'elle se rachète à tout moment.
- Un renvoi daté vers une vidéo qui n'existe plus → supprimer et reloger l'idée.
- Le même chiffre affiché deux jours de suite pour deux périmètres différents → l'erreur saute d'une vidéo à l'autre.
