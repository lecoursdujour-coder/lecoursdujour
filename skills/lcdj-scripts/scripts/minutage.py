# -*- coding: utf-8 -*-
"""
Minutage d'un script Le Cours du Jour.

Usage :
    python minutage.py script.json
    python minutage.py            # lance l'exemple intégré

Format du JSON attendu :
{
  "titre": "LUNDI 21/09 - Debunk ETF",
  "format": "debunk",
  "blocs": [["hook", "texte dit..."], ["le point vrai", "texte dit..."]]
}

Le champ "format" fixe le débit. Valeurs possibles :
  debunk (155) | cours60 (158) | coursproduits (158) | geo (160)
  cours40 (165) | vraioufaux (165)
"""
import json
import re
import sys

DEBITS = {
    "debunk": 155,
    "cours60": 158,
    "coursproduits": 158,
    "geo": 160,
    "cours40": 165,
    "vraioufaux": 165,
}

# fourchettes cibles a l'ecran, en secondes
CIBLES = {
    "debunk": (60, 75),
    "cours60": (60, 75),
    "coursproduits": (60, 75),
    "geo": (60, 75),
    "cours40": (140, 160),
    "vraioufaux": (38, 48),
}

MOT = re.compile(r"[A-Za-zÀ-ÿ0-9'’-]+")


def compte_mots(texte):
    return len([m for m in MOT.findall(texte) if re.search(r"[A-Za-zÀ-ÿ0-9]", m)])


def minute(titre, blocs, fmt):
    wpm = DEBITS.get(fmt, 158)
    lo, hi = CIBLES.get(fmt, (60, 75))
    t0 = 0
    total = 0
    lignes = []
    alertes = []

    for label, texte in blocs:
        n = compte_mots(texte)
        total += n
        d = max(1, round(n / wpm * 60))
        debit = round(n / d * 60)
        lignes.append((f"{t0}-{t0 + d} s", label, n, debit))
        if debit > 175:
            alertes.append(f"  !! bloc « {label} » a {debit} mots/min : intenable, reecrire le bloc")
        t0 += d

    ecran = round(t0 * 0.9)
    print(f"\n=== {titre} ===")
    print(f"format {fmt} — debit {wpm} mots/min")
    print(f"{'TEMPS':<12}{'BLOC':<20}{'MOTS':>6}{'M/MIN':>8}")
    for tc, label, n, debit in lignes:
        print(f"{tc:<12}{label[:19]:<20}{n:>6}{debit:>8}")
    print(f"\nTOTAL : {total} mots | {t0} s dites | {ecran} s a l'ecran")

    if ecran < lo:
        print(f"  !! COURT — cible {lo}-{hi} s. Il manque un bloc : ajouter du fond, pas du remplissage.")
    elif ecran > hi:
        print(f"  !! LONG — cible {lo}-{hi} s. Couper, en protegeant la concession et la chute.")
    else:
        print(f"  OK — dans la cible {lo}-{hi} s.")
    for a in alertes:
        print(a)
    return ecran


EXEMPLE = {
    "titre": "EXEMPLE — Debunk",
    "format": "debunk",
    "blocs": [
        ["hook", "Les ETF vont faire exploser la Bourse. Cette idee tourne partout. Elle a raison sur un point. Et tort sur trois."],
        ["le point vrai", "Le point vrai, et il est enorme : la gestion indicielle a depasse la gestion active."],
    ],
}

if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1], encoding="utf-8") as f:
            data = json.load(f)
    else:
        data = EXEMPLE
        print("(aucun fichier fourni — exemple integre)")
    minute(data["titre"], data["blocs"], data.get("format", "cours60"))
