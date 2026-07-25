# -*- coding: utf-8 -*-
"""
Localized App Store screenshot copy for the graphics generator.

One <APP>_I18N dict per app, keyed by locale → {heroH, heroSub, screens:[{h,sub}]}.
English lives in generate.py's `screens[]` (the base + fallback); add locales
for the top App Store markets (es / fr / de / pt / it / ja / ko / zh-Hans).

Machine-drafted translations should be FLAGGED FOR NATIVE-SPEAKER REVIEW before
submission (this is conversion-critical copy). Each `h`/`sub` is an array of
stacked lines; keep line counts matching the English. Add a locale by dropping
a block in and re-running `python3 generate.py`.

SAMPLE_I18N below covers the shipped "Sample Notes" example config with two
locales — copy its shape for your own apps.
"""

SAMPLE_I18N = {
  "es": {"heroH": ["Notas que se sienten", "como en casa"],
         "heroSub": ["Escribe con belleza, organiza con", "sencillez y conserva tus palabras"],
         "screens": [
    {"h": ["Notas", "hermosas"], "sub": ["Un editor sereno y enfocado", "para todo lo que escribes"]},
    {"h": ["Editor", "Markdown"], "sub": ["Formato enriquecido, listas", "y vista previa en vivo"]},
    {"h": ["Sincronización", "iCloud total"], "sub": ["Tus notas en cada dispositivo,", "sincronizadas automática y segura"]},
    {"h": ["Carpetas", "y etiquetas"], "sub": ["Organiza a tu manera con", "carpetas, etiquetas y búsqueda"]},
    {"h": ["Privado por", "diseño"], "sub": ["Exporta cuando quieras: tus", "datos siempre son tuyos"]}]},
  "fr": {"heroH": ["Des notes qui se sentent", "comme chez soi"],
         "heroSub": ["Écrivez avec élégance, organisez", "simplement, gardez vos mots à vous"],
         "screens": [
    {"h": ["De belles", "notes"], "sub": ["Un éditeur calme et concentré", "pour tout ce que vous écrivez"]},
    {"h": ["Éditeur", "Markdown"], "sub": ["Mise en forme riche, listes", "et aperçu en direct"]},
    {"h": ["Sync iCloud", "partout"], "sub": ["Vos notes sur chaque appareil,", "synchronisées automatiquement"]},
    {"h": ["Dossiers et", "étiquettes"], "sub": ["Organisez à votre façon avec", "dossiers, étiquettes et recherche"]},
    {"h": ["Privé par", "conception"], "sub": ["Exportez à tout moment — vos", "données restent les vôtres"]}]},
}
