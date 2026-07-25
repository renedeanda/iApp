# -*- coding: utf-8 -*-
"""Reusable per-app theme registries for the live per-card theme picker.
Unified keys: name, dark, bg, accent (primary), accent2 (secondary), text, sub, ph.
Each registry was distilled from a shipped production app.
Any app with a theme registry can drop a block here + set \"themes\" in its config."""

SAMPLE_THEMES = {
    "light": {"name": "Light", "dark": False, "bg": "#FAF6F0", "accent": "#D4956A", "accent2": "#D4956A", "text": "#2C2520", "sub": "#756A5E", "ph": "#B8AFA4"},
    "dark": {"name": "Dark", "dark": True, "bg": "#1C1A17", "accent": "#E8A97A", "accent2": "#E8A97A", "text": "#F0EBE3", "sub": "#C4BCB2", "ph": "#7A746E"},
    "sage": {"name": "Sage", "dark": False, "bg": "#F0F5F2", "accent": "#5A9E7B", "accent2": "#5A9E7B", "text": "#1E2D25", "sub": "#5A7568", "ph": "#9BB3A5"},
    "sageDark": {"name": "Sage Dark", "dark": True, "bg": "#1A2420", "accent": "#6DB88E", "accent2": "#6DB88E", "text": "#D8E5DD", "sub": "#A0BBA8", "ph": "#5B7568"},
    "ocean": {"name": "Ocean", "dark": False, "bg": "#F0F4F8", "accent": "#4A90BF", "accent2": "#4A90BF", "text": "#1A2533", "sub": "#536C85", "ph": "#94ABBD"},
    "oceanDark": {"name": "Ocean Dark", "dark": True, "bg": "#151B22", "accent": "#5CA3D4", "accent2": "#5CA3D4", "text": "#D6E0EB", "sub": "#A3BAD0", "ph": "#587590"},
    "coral": {"name": "Coral", "dark": False, "bg": "#FAF0F2", "accent": "#C76B7E", "accent2": "#C76B7E", "text": "#2D1E22", "sub": "#78636A", "ph": "#B89EA6"},
    "coralDark": {"name": "Coral Dark", "dark": True, "bg": "#201A1C", "accent": "#D4808F", "accent2": "#D4808F", "text": "#EBDFE2", "sub": "#B8A0A6", "ph": "#7A6268"},
    "grove": {"name": "Grove", "dark": False, "bg": "#F2EFDF", "accent": "#8DA101", "accent2": "#8DA101", "text": "#5C6A72", "sub": "#6E7D6D", "ph": "#A4AFA3"},
    "groveDark": {"name": "Grove Dark", "dark": True, "bg": "#272E33", "accent": "#A7C080", "accent2": "#A7C080", "text": "#D3C6AA", "sub": "#ADBCB0", "ph": "#687873"},
    "olive": {"name": "Olive", "dark": False, "bg": "#F5F2E8", "accent": "#7C9A3C", "accent2": "#7C9A3C", "text": "#2D2E1E", "sub": "#686952", "ph": "#A0A08A"},
    "oliveDark": {"name": "Olive Dark", "dark": True, "bg": "#1C1E16", "accent": "#9AB055", "accent2": "#9AB055", "text": "#DEE0C8", "sub": "#A8AA8E", "ph": "#626450"},
    "midnight": {"name": "Midnight", "dark": True, "bg": "#111318", "accent": "#7B9FD4", "accent2": "#7B9FD4", "text": "#E3E5EB", "sub": "#A0A6B6", "ph": "#5A6178"},
    "lavender": {"name": "Lavender", "dark": False, "bg": "#F4F0FA", "accent": "#8B6EB8", "accent2": "#8B6EB8", "text": "#261E33", "sub": "#6A5F7A", "ph": "#A99BBE"},
    "lavenderDark": {"name": "Lavender Dark", "dark": True, "bg": "#1A1720", "accent": "#A88DD4", "accent2": "#A88DD4", "text": "#E3DFE8", "sub": "#A8A2BE", "ph": "#605880"},
    "arctic": {"name": "Arctic", "dark": True, "bg": "#2E3440", "accent": "#88C0D0", "accent2": "#88C0D0", "text": "#ECEFF4", "sub": "#A8C3DA", "ph": "#576778"},
    "arcticLight": {"name": "Arctic Light", "dark": False, "bg": "#ECEFF4", "accent": "#5E81AC", "accent2": "#5E81AC", "text": "#2E3440", "sub": "#434D5E", "ph": "#7B8898"},
    "twilight": {"name": "Twilight", "dark": True, "bg": "#1A1B26", "accent": "#7AA2F7", "accent2": "#7AA2F7", "text": "#C0CAF5", "sub": "#949CC0", "ph": "#4A5270"},
    "depths": {"name": "Depths", "dark": True, "bg": "#132738", "accent": "#FFC600", "accent2": "#FFC600", "text": "#E1E8F0", "sub": "#96B8D0", "ph": "#4A7A9C"},
    "graphite": {"name": "Graphite", "dark": True, "bg": "#1E1E1E", "accent": "#CF4647", "accent2": "#CF4647", "text": "#D4D4D4", "sub": "#ABABAB", "ph": "#646464"},
    "graphiteLight": {"name": "Graphite Light", "dark": False, "bg": "#EAEAEA", "accent": "#CC3E3E", "accent2": "#CC3E3E", "text": "#2A2A2A", "sub": "#616161", "ph": "#9A9A9A"},
    "contrast": {"name": "Contrast", "dark": False, "bg": "#FAFCFE", "accent": "#0055CC", "accent2": "#0055CC", "text": "#111111", "sub": "#4A4A4A", "ph": "#888888"},
    "contrastDark": {"name": "Contrast Dark", "dark": True, "bg": "#0C0C0C", "accent": "#4A9EFF", "accent2": "#4A9EFF", "text": "#F5F5F5", "sub": "#B5B5B5", "ph": "#666666"},
    "amber": {"name": "Amber", "dark": False, "bg": "#FAF5E8", "accent": "#C49030", "accent2": "#C49030", "text": "#332A1A", "sub": "#766A4E", "ph": "#B5AA8E"},
    "amberDark": {"name": "Amber Dark", "dark": True, "bg": "#221C14", "accent": "#D4A54A", "accent2": "#D4A54A", "text": "#EBE5D6", "sub": "#BDB498", "ph": "#6E654E"},
    "mocha": {"name": "Mocha", "dark": True, "bg": "#251C18", "accent": "#C4956A", "accent2": "#C4956A", "text": "#E8E0D8", "sub": "#B8A8A0", "ph": "#6E625A"},
    "vintage": {"name": "Vintage", "dark": False, "bg": "#FBF1C7", "accent": "#D65D0E", "accent2": "#D65D0E", "text": "#3C3836", "sub": "#6A5F55", "ph": "#A09080"},
    "vintageDark": {"name": "Vintage Dark", "dark": True, "bg": "#282828", "accent": "#FE8019", "accent2": "#FE8019", "text": "#EBDBB2", "sub": "#CDBEA5", "ph": "#7C6F64"},
    "neonDusk": {"name": "Neon Dusk", "dark": True, "bg": "#282A36", "accent": "#BD93F9", "accent2": "#BD93F9", "text": "#F8F8F2", "sub": "#9DA8D0", "ph": "#545872"},
    "solaris": {"name": "Solaris", "dark": False, "bg": "#FDF6E3", "accent": "#268BD2", "accent2": "#268BD2", "text": "#586E75", "sub": "#7A8E90", "ph": "#B0BEC5"},
    "solarisDark": {"name": "Solaris Dark", "dark": True, "bg": "#002B36", "accent": "#268BD2", "accent2": "#268BD2", "text": "#93A1A1", "sub": "#85A0A8", "ph": "#486870"},
    "flame": {"name": "Flame", "dark": False, "bg": "#FAFAF8", "accent": "#FF9940", "accent2": "#FF9940", "text": "#5C6166", "sub": "#727982", "ph": "#ABB0B6"},
    "flameDark": {"name": "Flame Dark", "dark": True, "bg": "#0D1017", "accent": "#FFAE57", "accent2": "#FFAE57", "text": "#BFBDB6", "sub": "#9AA0AA", "ph": "#525A66"},
    "onyx": {"name": "Onyx", "dark": True, "bg": "#111111", "accent": "#FF8C42", "accent2": "#FF8C42", "text": "#E8E8E8", "sub": "#ABABAB", "ph": "#5C5C5C"},
    "scholar": {"name": "Scholar", "dark": False, "bg": "#F5F0E8", "accent": "#7D2B3A", "accent2": "#7D2B3A", "text": "#2A2118", "sub": "#665A4A", "ph": "#A09680"},
    "scholarDark": {"name": "Scholar Dark", "dark": True, "bg": "#1A1614", "accent": "#A44058", "accent2": "#A44058", "text": "#E5DDD0", "sub": "#B2A694", "ph": "#665E50"},
    "petal": {"name": "Petal", "dark": True, "bg": "#191724", "accent": "#EBBCBA", "accent2": "#EBBCBA", "text": "#E0DEF4", "sub": "#A6A2BE", "ph": "#6E6A86"},
    "petalLight": {"name": "Petal Light", "dark": False, "bg": "#FAF4ED", "accent": "#D7827E", "accent2": "#D7827E", "text": "#575279", "sub": "#7E7A92", "ph": "#B4AFB9"},
    "blush": {"name": "Blush", "dark": False, "bg": "#FDF8FA", "accent": "#E06C88", "accent2": "#E06C88", "text": "#2E2A2C", "sub": "#757174", "ph": "#B0AAB0"},
    "pastel": {"name": "Pastel", "dark": True, "bg": "#24273A", "accent": "#F5BDE6", "accent2": "#F5BDE6", "text": "#CAD3F5", "sub": "#A5A9C0", "ph": "#585C74"},
    "pastelLight": {"name": "Pastel Light", "dark": False, "bg": "#EFF1F5", "accent": "#EA76CB", "accent2": "#EA76CB", "text": "#4C4F69", "sub": "#6E7188", "ph": "#ACB0BE"},
}

DOT_THEMES = {
    "classic": {"name": "Classic", "dark": True, "bg": "#0A0A0A", "accent": "#FFFFFF", "accent2": "#2A2A2A", "text": "#FFFFFF", "sub": "#777777", "ph": "#777777"},
    "snow-light": {"name": "Snow", "dark": False, "bg": "#F4F5F7", "accent": "#111111", "accent2": "#E3E4E7", "text": "#0E0E10", "sub": "#6B7280", "ph": "#6B7280"},
    "electric-blue": {"name": "Electric", "dark": True, "bg": "#050810", "accent": "#00D4FF", "accent2": "#152535", "text": "#FFFFFF", "sub": "#5599BB", "ph": "#5599BB"},
    "neon-mint": {"name": "Mint", "dark": True, "bg": "#050A08", "accent": "#00FF88", "accent2": "#152A20", "text": "#FFFFFF", "sub": "#44AA77", "ph": "#44AA77"},
    "sunset-glow": {"name": "Sunset", "dark": True, "bg": "#0A0805", "accent": "#FF6B35", "accent2": "#2A1A12", "text": "#FFFFFF", "sub": "#AA7755", "ph": "#AA7755"},
    "amber-fire": {"name": "Amber", "dark": True, "bg": "#080805", "accent": "#FFAA00", "accent2": "#2A2010", "text": "#FFFFFF", "sub": "#AA8844", "ph": "#AA8844"},
    "rose-gold": {"name": "Rose", "dark": True, "bg": "#0A0808", "accent": "#E8A4A4", "accent2": "#2A1A1A", "text": "#FFFFFF", "sub": "#AA8888", "ph": "#AA8888"},
    "arctic": {"name": "Arctic", "dark": True, "bg": "#050808", "accent": "#B8E8F8", "accent2": "#152025", "text": "#FFFFFF", "sub": "#7799AA", "ph": "#7799AA"},
    "forest": {"name": "Forest", "dark": True, "bg": "#050805", "accent": "#4A7C59", "accent2": "#1A2A1A", "text": "#FFFFFF", "sub": "#668866", "ph": "#668866"},
    "coral-reef": {"name": "Coral", "dark": True, "bg": "#080505", "accent": "#FF7F7F", "accent2": "#2A1515", "text": "#FFFFFF", "sub": "#AA7777", "ph": "#AA7777"},
    "midnight": {"name": "Midnight", "dark": True, "bg": "#050508", "accent": "#5588FF", "accent2": "#151525", "text": "#FFFFFF", "sub": "#6677AA", "ph": "#6677AA"},
    "ocean-deep": {"name": "Ocean", "dark": True, "bg": "#050808", "accent": "#20B2AA", "accent2": "#102020", "text": "#FFFFFF", "sub": "#55AAAA", "ph": "#55AAAA"},
    "champagne": {"name": "Champagne", "dark": True, "bg": "#080806", "accent": "#F7E7CE", "accent2": "#252015", "text": "#FFFFFF", "sub": "#AA9977", "ph": "#AA9977"},
    "aurora": {"name": "Aurora", "dark": True, "bg": "#050510", "accent": "#00FFA3", "accent2": "#152025", "text": "#FFFFFF", "sub": "#55AAAA", "ph": "#55AAAA"},
    "cosmic": {"name": "Cosmic", "dark": True, "bg": "#08050A", "accent": "#FF6B9D", "accent2": "#251525", "text": "#FFFFFF", "sub": "#AA77AA", "ph": "#AA77AA"},
    "sunrise": {"name": "Sunrise", "dark": True, "bg": "#0A0805", "accent": "#FF9E44", "accent2": "#2A1810", "text": "#FFFFFF", "sub": "#AA8855", "ph": "#AA8855"},
    "northern-lights": {"name": "Northern", "dark": True, "bg": "#050808", "accent": "#4ECDC4", "accent2": "#102525", "text": "#FFFFFF", "sub": "#55AAAA", "ph": "#55AAAA"},
    "flame": {"name": "Flame", "dark": True, "bg": "#080505", "accent": "#FF4E50", "accent2": "#281510", "text": "#FFFFFF", "sub": "#AA6655", "ph": "#AA6655"},
    "ocean-breeze": {"name": "Breeze", "dark": True, "bg": "#050808", "accent": "#56CCF2", "accent2": "#152530", "text": "#FFFFFF", "sub": "#5588AA", "ph": "#5588AA"},
    "lavender": {"name": "Lavender", "dark": True, "bg": "#080708", "accent": "#B8A9C9", "accent2": "#201828", "text": "#FFFFFF", "sub": "#8877AA", "ph": "#8877AA"},
    "slate": {"name": "Slate", "dark": True, "bg": "#0A0A0C", "accent": "#94A3B8", "accent2": "#1E1E24", "text": "#FFFFFF", "sub": "#6B7280", "ph": "#6B7280"},
    "sakura": {"name": "Sakura", "dark": True, "bg": "#0A0808", "accent": "#FFB7C5", "accent2": "#251A1E", "text": "#FFFFFF", "sub": "#AA8899", "ph": "#AA8899"},
    "gold": {"name": "Gold", "dark": True, "bg": "#0A0805", "accent": "#FFD700", "accent2": "#2A2010", "text": "#FFFFFF", "sub": "#AA9955", "ph": "#AA9955"},
    "snow": {"name": "Frost", "dark": True, "bg": "#080B0E", "accent": "#DCEBF2", "accent2": "#1C2730", "text": "#FFFFFF", "sub": "#7E97A4", "ph": "#7E97A4"},
    "neon-pink": {"name": "Neon", "dark": True, "bg": "#080508", "accent": "#FF1493", "accent2": "#251520", "text": "#FFFFFF", "sub": "#AA5588", "ph": "#AA5588"},
}

SAMPLE_DEFAULTS = ['light', 'sage', 'ocean', 'midnight', 'amber', 'lavender', 'dark']
DOT_DEFAULTS = ['classic', 'snow-light']


PLANNER_THEMES = {
    "slate": {"name": "Slate", "dark": False, "bg": "#F5F4F0", "accent": "#4A5169", "accent2": "#8B7E6F", "text": "#1F2128", "sub": "#5A5F6E", "ph": "#A8ADBA"},
    "slateDark": {"name": "Slate Dark", "dark": True, "bg": "#1A1C22", "accent": "#7B83A0", "accent2": "#B5A998", "text": "#E8EAEF", "sub": "#A8ADBA", "ph": "#5A5F6E"},
    "sage": {"name": "Sage", "dark": False, "bg": "#F0F5F2", "accent": "#5A9E7B", "accent2": "#BF9B68", "text": "#1E2D25", "sub": "#5A7568", "ph": "#9BB3A5"},
    "ocean": {"name": "Ocean", "dark": False, "bg": "#F0F4F8", "accent": "#4A90BF", "accent2": "#D4907A", "text": "#1A2533", "sub": "#536C85", "ph": "#94ABBD"},
    "midnight": {"name": "Midnight", "dark": True, "bg": "#111318", "accent": "#7B9FD4", "accent2": "#B5A998", "text": "#E3E5EB", "sub": "#A0A6B6", "ph": "#5A6178"},
    "scholar": {"name": "Scholar", "dark": False, "bg": "#F5F0E8", "accent": "#7D2B3A", "accent2": "#BF9B68", "text": "#2A2118", "sub": "#665A4A", "ph": "#A09680"},
    "vintage": {"name": "Vintage", "dark": False, "bg": "#FBF1C7", "accent": "#D65D0E", "accent2": "#8B7E6F", "text": "#3C3836", "sub": "#6A5F55", "ph": "#A09080"},
}

PLANNER_DEFAULTS = ["slate", "slate", "sage", "sage", "ocean", "scholar", "slateDark", "midnight"]
