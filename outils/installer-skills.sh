#!/bin/sh
# Installe les skills LCDJ dans ~/.claude/skills à partir du bundle du dépôt.
#
# Appelé automatiquement après chaque pull par les hooks de .githooks/, et
# manuellement par « Activer la mise a jour auto.cmd ».
#
# Ne fait JAMAIS échouer un pull : en cas de problème, on prévient et on sort en 0.
#
# RÈGLE DE SÛRETÉ : on ne supprime une skill installée que si elle a été retirée
# VOLONTAIREMENT de skills-a-installer.txt. Une skill absente du bundle ou dont la
# copie échoue est CONSERVÉE telle quelle et signalée — jamais effacée. Tout est
# consigné dans .lcdj-journal.txt pour qu'un problème reste lisible après le pull.

DEPOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE="$DEPOT/lecoursdujour-skills.plugin"
LISTE="$DEPOT/outils/skills-a-installer.txt"
DEST="$HOME/.claude/skills"
MANIFESTE="$DEST/.lcdj-installe.txt"
JOURNAL="$DEST/.lcdj-journal.txt"

PROBLEMES=0

# Écrit à l'écran ET dans le journal.
dire() {
  echo "  [LCDJ] $1"
  [ -n "$JOURNAL_PRET" ] && echo "$(date '+%Y-%m-%d %H:%M:%S')  $1" >> "$JOURNAL"
}
# Comme dire(), mais compte un problème et le rend voyant.
alerter() {
  PROBLEMES=$((PROBLEMES + 1))
  echo "  [LCDJ] /!\\ $1"
  [ -n "$JOURNAL_PRET" ] && echo "$(date '+%Y-%m-%d %H:%M:%S')  /!\\ $1" >> "$JOURNAL"
}

echo ""
echo "  [LCDJ] mise a jour des skills..."

mkdir -p "$DEST" 2>/dev/null
if [ -d "$DEST" ] && : >> "$JOURNAL" 2>/dev/null; then
  JOURNAL_PRET=1
  # On garde le journal court : les 400 dernières lignes suffisent.
  if [ "$(wc -l < "$JOURNAL" 2>/dev/null || echo 0)" -gt 400 ]; then
    tail -n 200 "$JOURNAL" > "$JOURNAL.tmp" 2>/dev/null && mv "$JOURNAL.tmp" "$JOURNAL" 2>/dev/null
  fi
  echo "" >> "$JOURNAL"
  echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$JOURNAL"
fi

if [ ! -f "$BUNDLE" ]; then
  alerter "bundle introuvable ($BUNDLE) - rien n'a ete touche."
  echo ""
  exit 0
fi
if [ ! -f "$LISTE" ]; then
  alerter "liste introuvable ($LISTE) - rien n'a ete touche."
  echo ""
  exit 0
fi

TMP="$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/lcdj-skills-$$")"
mkdir -p "$TMP" || { alerter "dossier temporaire impossible - rien n'a ete touche."; echo ""; exit 0; }

if ! tar -xf "$BUNDLE" -C "$TMP" 2>/dev/null; then
  alerter "extraction du bundle impossible - rien n'a ete touche."
  rm -rf "$TMP"
  echo ""
  exit 0
fi

# L'extraction normalise le prefixe des chemins : un bundle en « skills/… » comme
# un bundle en « ./skills/… » donnent tous deux $TMP/skills/. On ne lit donc JAMAIS
# l'archive directement, sinon un changement de prefixe casse tout en silence.
if [ ! -d "$TMP/skills" ]; then
  alerter "le bundle ne contient pas de dossier skills/ - rien n'a ete touche."
  rm -rf "$TMP"
  echo ""
  exit 0
fi

VERSION="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
           "$TMP/.claude-plugin/plugin.json" 2>/dev/null | head -1)"
if [ -z "$VERSION" ]; then
  VERSION="?"
  alerter "version du bundle illisible dans .claude-plugin/plugin.json."
fi

VOULUES="$TMP/.voulues"    # ce que la liste demande
POSEES="$TMP/.posees"      # ce qui est effectivement en place a la fin
: > "$VOULUES"
: > "$POSEES"

# On lit la liste en ignorant commentaires, lignes vides et retours chariot Windows.
sed -e 's/\r$//' -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$LISTE" \
  | grep -v '^$' > "$VOULUES"

if [ ! -s "$VOULUES" ]; then
  alerter "la liste ne demande aucune skill - rien n'a ete touche."
  rm -rf "$TMP"
  echo ""
  exit 0
fi

while IFS= read -r NOM; do
  [ -z "$NOM" ] && continue
  SRC="$TMP/skills/$NOM"

  if [ ! -d "$SRC" ]; then
    if [ -d "$DEST/$NOM" ]; then
      alerter "'$NOM' absent du bundle v$VERSION : la copie installee est CONSERVEE telle quelle."
      echo "$NOM" >> "$POSEES"   # on la garde : elle reste au manifeste
    else
      alerter "'$NOM' absent du bundle v$VERSION et pas installe - rien a faire."
    fi
    continue
  fi

  # Copie atomique : on pose a cote, et on ne remplace qu'une fois la copie reussie.
  NEUF="$DEST/.$NOM.neuf.$$"
  rm -rf "$NEUF" 2>/dev/null
  if ! cp -r "$SRC" "$NEUF" 2>/dev/null; then
    rm -rf "$NEUF" 2>/dev/null
    if [ -d "$DEST/$NOM" ]; then
      alerter "copie de '$NOM' impossible : la version installee est CONSERVEE."
      echo "$NOM" >> "$POSEES"
    else
      alerter "copie de '$NOM' impossible et rien d'installe - skill MANQUANTE."
    fi
    continue
  fi

  VIEUX="$DEST/.$NOM.vieux.$$"
  if [ -d "$DEST/$NOM" ] && ! mv "$DEST/$NOM" "$VIEUX" 2>/dev/null; then
    rm -rf "$NEUF" 2>/dev/null
    alerter "'$NOM' verrouille (Claude est peut-etre ouvert) : version installee CONSERVEE."
    echo "$NOM" >> "$POSEES"
    continue
  fi
  if mv "$NEUF" "$DEST/$NOM" 2>/dev/null; then
    rm -rf "$VIEUX" 2>/dev/null
    echo "$NOM" >> "$POSEES"
  else
    # Bascule ratee : on remet l'ancienne en place plutot que de laisser un trou.
    [ -d "$VIEUX" ] && mv "$VIEUX" "$DEST/$NOM" 2>/dev/null
    rm -rf "$NEUF" 2>/dev/null
    alerter "mise en place de '$NOM' impossible : ancienne version restauree."
    [ -d "$DEST/$NOM" ] && echo "$NOM" >> "$POSEES"
  fi
done < "$VOULUES"

# Retirer ce qu'on avait pose avant et qui a ete RETIRE DE LA LISTE (volontaire).
# On ne touche pas a ce qui a seulement echoue : ces noms sont dans $POSEES.
if [ -f "$MANIFESTE" ]; then
  while IFS= read -r ANCIEN; do
    [ -z "$ANCIEN" ] && continue
    if grep -qxF "$ANCIEN" "$VOULUES" 2>/dev/null; then
      continue   # toujours demande : on n'y touche pas
    fi
    if [ -d "$DEST/$ANCIEN" ]; then
      rm -rf "$DEST/$ANCIEN" && dire "retire : $ANCIEN (retire de la liste)"
    fi
  done < "$MANIFESTE"
fi

# Menage d'eventuels restes d'une execution interrompue.
rm -rf "$DEST"/.*.neuf.* "$DEST"/.*.vieux.* 2>/dev/null

cp "$POSEES" "$MANIFESTE" 2>/dev/null || alerter "ecriture du manifeste impossible ($MANIFESTE)."
NB="$(wc -l < "$POSEES" | tr -d ' ')"
NB_VOULUES="$(wc -l < "$VOULUES" | tr -d ' ')"
rm -rf "$TMP"

if [ "$PROBLEMES" -eq 0 ]; then
  dire "$NB/$NB_VOULUES skill(s) a jour depuis le bundle v$VERSION -> $DEST"
  dire "redemarre Claude Code pour qu'il les relise."
else
  dire "$NB/$NB_VOULUES skill(s) en place depuis le bundle v$VERSION -> $DEST"
  echo ""
  echo "  [LCDJ] ============================================================"
  echo "  [LCDJ]  $PROBLEMES PROBLEME(S) - lis le detail ci-dessus."
  echo "  [LCDJ]  Journal : $JOURNAL"
  echo "  [LCDJ]  Rien n'a ete supprime a cause de ces problemes."
  echo "  [LCDJ] ============================================================"
fi
echo ""
exit 0
