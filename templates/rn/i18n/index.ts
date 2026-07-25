import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import * as Localization from 'expo-localization';

import en from './locales/en.json';
import es from './locales/es.json';
import de from './locales/de.json';
import fr from './locales/fr.json';
import pt from './locales/pt.json';
import ja from './locales/ja.json';
import zhHans from './locales/zh-Hans.json';

/**
 * i18next bootstrap for the Seed RN template.
 *
 * Tier-1 locales (en, es, de, fr, pt, ja, zh-Hans) ship as JSON files
 * under `i18n/locales/`. The wizard's `/translate <lang>` skill diffs
 * en.json against the target language and fills in missing keys.
 *
 * Locale detection: expo-localization's `getLocales()` returns an
 * ordered preference list from the OS. We pick the first entry whose
 * base language matches a tier-1 locale. `zh-Hans` and `zh-Hant`
 * share the `zh` base — explicit handling keeps Simplified vs
 * Traditional from collapsing.
 */

function pickInitialLocale(): string {
  const preferred = Localization.getLocales();
  const supported = ['en', 'es', 'de', 'fr', 'pt', 'ja', 'zh-Hans'] as const;

  for (const locale of preferred) {
    const tag = locale.languageTag;
    if (supported.includes(tag as (typeof supported)[number])) {
      return tag;
    }
    const base = locale.languageCode ?? 'en';
    if (base === 'zh') {
      // zh-Hans / zh-Hant / zh-CN / zh-TW — only Simplified shipped.
      const lower = tag.toLowerCase();
      if (lower.includes('hans') || lower.endsWith('cn') || lower === 'zh') {
        return 'zh-Hans';
      }
    }
    if (supported.includes(base as (typeof supported)[number])) {
      return base;
    }
  }
  return 'en';
}

void i18n.use(initReactI18next).init({
  compatibilityJSON: 'v4',
  resources: {
    en: { translation: en },
    es: { translation: es },
    de: { translation: de },
    fr: { translation: fr },
    pt: { translation: pt },
    ja: { translation: ja },
    'zh-Hans': { translation: zhHans },
  },
  lng: pickInitialLocale(),
  fallbackLng: 'en',
  interpolation: { escapeValue: false },
  returnNull: false,
});

export default i18n;
