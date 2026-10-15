#!/bin/sh
# Verifie l'installation des skills LCDJ et repond a une seule question :
# « est-ce que tout est a jour et sans doublon ? »
#
# Usage :  sh outils/verifier-skills.sh
#
# Sort en 0 si tout va bien, en 1 s'il y a quoi que ce soit a regarder.
# Ne modifie RIEN : lecture seule, on peut le lancer a tout moment.

DEPOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE="$DEPOT/lecoursdujour-skills.plugin"
LISTE="$DEPOT/outils/skills-a-installer.txt"
DEST="$HOME/.claude/skills"
MANIFESTE="$DEST/.lcdj-installe.txt"

SOUCIS=0
ok()      { echo "  OK      $1"; }
souci()   { SOUCIS=$((SOUCIS + 1)); echo "  /!\\      $1"; }
titre()   { echo ""; echo "$1"; echo "------------------------------------------------------------"; }

echo ""
echo "============================================================"
echo " VERIFICATION DES SKILLS LCDJ   $(date '+%Y-%m-%d %H:%M')"
echo "============================================================"

# ---------------------------------------------------------------- 1. le dépôt
titre "1. Depot"
echo "  dossier  : $DEPOT"
echo "  commit   : $(git -C "$DEPOT" log --oneline -1 2>/dev/null || echo '?')"

HOOKS="$(git -C "$DEPOT" config core.hooksPath 2>/dev/null)"
if [ "$HOOKS" = ".githooks" ]; then
  ok "mise a jour auto armee (core.hooksPath = .githooks)"
else
  souci "mise a jour auto NON armee : un pull n'installera rien."
  echo "          correction : lance « Activer la mise a jour auto.cmd »"
fi

RETARD="$(git -C "$DEPOT" rev-list --count HEAD..@{u} 2>/dev/null)"
if [ -n "$RETARD" ] && [ "$RETARD" -gt 0 ] 2>/dev/null; then
  souci "$RETARD commit(s) de retard sur origin : fais un git pull."
fi

# ---------------------------------------------------------------- 2. le bundle
titre "2. Bundle"
if [ ! -f "$BUNDLE" ]; then
  souci "bundle introuvable : $BUNDLE"
  echo ""; exit 1
fi

TMP="$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/lcdj-verif-$$")"
mkdir -p "$TMP" || { echo "  /!\\      dossier temporaire impossible"; exit 1; }
trap 'rm -rf "$TMP"' EXIT INT TERM

if ! tar -xf "$BUNDLE" -C "$TMP" 2>/dev/null; then
  souci "extraction impossible : le bundle est peut-etre corrompu."
  echo ""; exit 1
fi
# On travaille toujours sur l'arborescence extraite : elle normalise un prefixe
# « ./skills/… » comme « skills/… ». Lire l'archive directement casse en silence
# des qu'un repack change le prefixe (vu le 11/10/2026).
if [ ! -d "$TMP/skills" ]; then
  souci "le bundle ne contient pas de dossier skills/."
  echo ""; exit 1
fi

VERSION="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
           "$TMP/.claude-plugin/plugin.json" 2>/dev/null | head -1)"
[ -z "$VERSION" ] && { VERSION="?"; souci "version illisible dans plugin.json."; }
echo "  version  : v$VERSION"
echo "  skills   : $(ls "$TMP/skills" 2>/dev/null | wc -l | tr -d ' ')"
echo "  taille   : $(du -k "$BUNDLE" 2>/dev/null | cut -f1) Ko"

# ------------------------------------------------- 3. conformité octet par octet
titre "3. Skills du canal auto (installees dans ~/.claude/skills)"
VOULUES="$TMP/.voulues"
sed -e 's/\r$//' -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$LISTE" 2>/dev/null \
  | grep -v '^$' > "$VOULUES"

while IFS= read -r NOM; do
  [ -z "$NOM" ] && continue
  if [ ! -d "$TMP/skills/$NOM" ]; then
    souci "$NOM : demandee par la liste mais ABSENTE DU BUNDLE."
  elif [ ! -d "$DEST/$NOM" ]; then
    souci "$NOM : PAS INSTALLEE. Lance : sh outils/installer-skills.sh"
  elif diff -rq "$TMP/skills/$NOM" "$DEST/$NOM" >/dev/null 2>&1; then
    V="$(sed -n 's/^version:[[:space:]]*"*\([^"]*\)"*.*/\1/p' "$DEST/$NOM/SKILL.md" 2>/dev/null | head -1)"
    ok "$NOM${V:+   (v$V)}"
  else
    N="$(diff -rq "$TMP/skills/$NOM" "$DEST/$NOM" 2>/dev/null | wc -l | tr -d ' ')"
    souci "$NOM : PERIMEE, $N fichier(s) different(s). Lance : sh outils/installer-skills.sh"
  fi
done < "$VOULUES"

# --------------------------------------------------------------- 4. doublons
titre "4. Doublons entre le canal auto et le plugin Claude"
PLUGDIR="$(find "$APPDATA/Claude/local-agent-mode-sessions" -type d -name 'skills' -path '*plugin_*' 2>/dev/null \
           | while read -r d; do [ -d "$d/embedded-captions" ] && echo "$d" && break; done)"
if [ -z "$PLUGDIR" ]; then
  echo "  plugin lecoursdujour-skills : introuvable sur le disque."
  echo "  (normal si tu ne l'as jamais depose dans Claude ; sinon redemarre l'app)"
else
  echo "  plugin : $PLUGDIR"
  DBL=0
  for d in "$PLUGDIR"/*/; do
    NOM="$(basename "$d")"
    if [ -d "$DEST/$NOM" ]; then
      souci "$NOM est servie PAR LES DEUX canaux : elle apparaitra en double."
      DBL=$((DBL + 1))
    fi
  done
  [ "$DBL" -eq 0 ] && ok "aucun doublon ($(ls "$PLUGDIR" | wc -l | tr -d ' ') par le plugin, $(wc -l < "$VOULUES" | tr -d ' ') par le canal auto)"

  # Garde-fou : la personnalisation LCDJ d'embedded-captions n'existe que dans le
  # plugin installe. Si elle manque au bundle, une reinstallation l'effacerait.
  if [ -f "$PLUGDIR/embedded-captions/themes/lecoursdujour.json" ] \
     && [ ! -f "$TMP/skills/embedded-captions/themes/lecoursdujour.json" ]; then
    souci "le theme sous-titres LCDJ est dans le plugin installe mais PAS dans le bundle."
    echo "          => NE PAS reinstaller le .plugin : le theme serait perdu."
  fi
fi

# ------------------------------------------------------------- 5. le journal
titre "5. Dernier passage de l'installeur"
if [ -f "$DEST/.lcdj-journal.txt" ]; then
  tail -n 6 "$DEST/.lcdj-journal.txt" 2>/dev/null | sed 's/^/  /'
else
  echo "  pas de journal : l'installeur n'a pas encore tourne dans sa version recente."
fi

# ------------------------------------------------------------------ verdict
echo ""
echo "============================================================"
if [ "$SOUCIS" -eq 0 ]; then
  echo " TOUT EST BON. Rien a faire."
else
  echo " $SOUCIS POINT(S) A REGARDER - voir les /!\\ ci-dessus."
fi
echo "============================================================"
echo ""
[ "$SOUCIS" -eq 0 ] || exit 1
exit 0
