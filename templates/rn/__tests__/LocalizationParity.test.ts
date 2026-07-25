// SOURCE: iApp template — RN counterpart to
//         swift template's LocalizationParityTests.swift
//
// Verifies every tier-1 locale JSON has exactly the same key set as
// en.json. Missing keys = runtime fallback to English (not catastrophic
// but a UX bug). Extra keys = dead translations (cost without value).

import en from '@/i18n/locales/en.json';
import es from '@/i18n/locales/es.json';
import de from '@/i18n/locales/de.json';
import fr from '@/i18n/locales/fr.json';
import pt from '@/i18n/locales/pt.json';
import ja from '@/i18n/locales/ja.json';
import zhHans from '@/i18n/locales/zh-Hans.json';

type Tree = Record<string, unknown>;

function flatten(tree: Tree, prefix = ''): string[] {
  const keys: string[] = [];
  for (const [k, v] of Object.entries(tree)) {
    const fullKey = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      keys.push(...flatten(v as Tree, fullKey));
    } else {
      keys.push(fullKey);
    }
  }
  return keys.sort();
}

function countFormatSpecifiers(value: string): { positional: number; named: number } {
  // i18next named: {{var}}. Standard printf-ish: %s, %d, %@, %lld.
  const named = (value.match(/\{\{[^}]+\}\}/g) || []).length;
  const positional = (value.match(/%[sd@flld]/g) || []).length;
  return { positional, named };
}

const tierOne: Array<[string, Tree]> = [
  ['es', es as Tree],
  ['de', de as Tree],
  ['fr', fr as Tree],
  ['pt', pt as Tree],
  ['ja', ja as Tree],
  ['zh-Hans', zhHans as Tree],
];

const enKeys = flatten(en as Tree);

describe('Localization parity (Tier 1)', () => {
  for (const [name, tree] of tierOne) {
    test(`${name} has the same key set as en`, () => {
      const otherKeys = flatten(tree);
      const missing = enKeys.filter((k) => !otherKeys.includes(k));
      const extra = otherKeys.filter((k) => !enKeys.includes(k));
      expect({ missing, extra }).toEqual({ missing: [], extra: [] });
    });
  }

  test('every locale has format-specifier parity with en for matching keys', () => {
    const violations: string[] = [];
    const enFlat = flattenWithValues(en as Tree);
    for (const [name, tree] of tierOne) {
      const otherFlat = flattenWithValues(tree);
      for (const [key, enValue] of Object.entries(enFlat)) {
        const otherValue = otherFlat[key];
        if (typeof otherValue !== 'string' || typeof enValue !== 'string') continue;
        const enSpecs = countFormatSpecifiers(enValue);
        const otherSpecs = countFormatSpecifiers(otherValue);
        if (
          enSpecs.named !== otherSpecs.named ||
          enSpecs.positional !== otherSpecs.positional
        ) {
          violations.push(
            `${name}.${key}: en has ${JSON.stringify(enSpecs)}, ${name} has ${JSON.stringify(otherSpecs)}`
          );
        }
      }
    }
    expect(violations).toEqual([]);
  });
});

function flattenWithValues(tree: Tree, prefix = ''): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [k, v] of Object.entries(tree)) {
    const fullKey = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      Object.assign(out, flattenWithValues(v as Tree, fullKey));
    } else if (typeof v === 'string') {
      out[fullKey] = v;
    }
  }
  return out;
}
