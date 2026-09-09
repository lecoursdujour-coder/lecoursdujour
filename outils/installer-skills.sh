#!/bin/sh
# Installe les skills LCDJ dans ~/.claude/skills à partir du bundle du dépôt.
#
# Appelé automatiquement après chaque pull par les hooks de .githooks/, et
# manuellement par « Activer la mise a jour auto.cmd ».
#
# Ne fait JAMAIS échouer un pull : en cas de problème, on prévient et on sort en 0.

DEPOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE="$DEPOT/lecoursdujour-skills.plugin"
LISTE="$DEPOT/outils/skills-a-installer.txt"
DEST="$HOME/.claude/skills"
MANIFESTE="$DEST/.lcdj-installe.txt"

echo ""
echo "  [LCDJ] mise a jour des skills..."

if [ ! -f "$BUNDLE" ]; then
  echo "  [LCDJ] bundle introuvable ($BUNDLE) - rien a faire."
  exit 0
fi
if [ ! -f "$LISTE" ]; then
  echo "  [LCDJ] liste introuvable ($LISTE) - rien a faire."
  exit 0
fi

TMP="$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/lcdj-skills-$$")"
mkdir -p "$TMP" || { echo "  [LCDJ] dossier temporaire impossible - abandon."; exit 0; }

if ! tar -xf "$BUNDLE" -C "$TMP" 2>/dev/null; then
  echo "  [LCDJ] extraction du bundle impossible - abandon."
  rm -rf "$TMP"
  exit 0
fi

VERSION="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
           "$TMP/.claude-plugin/plugin.json" 2>/dev/null | head -1)"
[ -z "$VERSION" ] && VERSION="?"

mkdir -p "$DEST"
NOUVEAU="$TMP/.manifeste"
: > "$NOUVEAU"
POSEES=0

# On lit la liste en ignorant commentaires, lignes vides et retours chariot Windows.
sed -e 's/\r$//' -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$LISTE" \
| while IFS= read -r NOM; do
    [ -z "$NOM" ] && continue
    if [ -d "$TMP/skills/$NOM" ]; then
      rm -rf "$DEST/$NOM"
      cp -r "$TMP/skills/$NOM" "$DEST/$NOM" && echo "$NOM" >> "$NOUVEAU"
    else
      echo "  [LCDJ] ATTENTION : '$NOM' est dans la liste mais absent du bundle."
    fi
  done

# Retirer ce qu'on avait posé avant et qui n'est plus dans la liste.
if [ -f "$MANIFESTE" ]; then
  while IFS= read -r ANCIEN; do
    [ -z "$ANCIEN" ] && continue
    if ! grep -qxF "$ANCIEN" "$NOUVEAU" 2>/dev/null; then
      rm -rf "$DEST/$ANCIEN"
      echo "  [LCDJ] retire : $ANCIEN (plus dans la liste)"
    fi
  done < "$MANIFESTE"
fi

cp "$NOUVEAU" "$MANIFESTE" 2>/dev/null
POSEES="$(wc -l < "$NOUVEAU" | tr -d ' ')"
rm -rf "$TMP"

echo "  [LCDJ] $POSEES skill(s) a jour depuis le bundle v$VERSION -> $DEST"
echo "  [LCDJ] redemarre Claude Code pour qu'il les relise."
echo ""
exit 0
