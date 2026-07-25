// SOURCE: Kindling template — RN counterpart to
//         swift template's ThemeContrastTests.swift
//
// Verifies the warm-minimal palette ships AAA contrast (WCAG 2.1
// 7.0:1) for the text/background pair in both light and dark schemes.
// Apple's HIG and the Kindling design philosophy both require AAA
// on primary copy.

import { lightPalette, darkPalette } from '@/theme/AppTheme';

function hexToRgb(hex: string): [number, number, number] {
  const cleaned = hex.replace('#', '');
  expect(cleaned.length).toBe(6);
  const r = parseInt(cleaned.slice(0, 2), 16);
  const g = parseInt(cleaned.slice(2, 4), 16);
  const b = parseInt(cleaned.slice(4, 6), 16);
  return [r, g, b];
}

function relativeLuminance([r, g, b]: [number, number, number]): number {
  const toLinear = (c: number) => {
    const v = c / 255;
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  };
  return 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b);
}

function contrastRatio(a: string, b: string): number {
  const la = relativeLuminance(hexToRgb(a));
  const lb = relativeLuminance(hexToRgb(b));
  const lighter = Math.max(la, lb);
  const darker = Math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

const AAA_BODY = 7.0;
const AAA_LARGE = 4.5; // AA-large is the AAA-equivalent for large text.

describe('Theme contrast (AAA)', () => {
  test('light text on light bg passes AAA (7:1)', () => {
    const ratio = contrastRatio(lightPalette.text, lightPalette.bg);
    expect(ratio).toBeGreaterThanOrEqual(AAA_BODY);
  });

  test('dark text on dark bg passes AAA (7:1)', () => {
    const ratio = contrastRatio(darkPalette.text, darkPalette.bg);
    expect(ratio).toBeGreaterThanOrEqual(AAA_BODY);
  });

  test('light secondary text passes AA-large (4.5:1) at minimum', () => {
    const ratio = contrastRatio(lightPalette.textSecondary, lightPalette.bg);
    expect(ratio).toBeGreaterThanOrEqual(AAA_LARGE);
  });

  test('dark secondary text passes AA-large (4.5:1) at minimum', () => {
    const ratio = contrastRatio(darkPalette.textSecondary, darkPalette.bg);
    expect(ratio).toBeGreaterThanOrEqual(AAA_LARGE);
  });

  test('no pure #000 or #FFF anywhere in the palette', () => {
    const banned = ['#000000', '#FFFFFF', '#000', '#FFF'];
    const allValues = [
      ...Object.values(lightPalette),
      ...Object.values(darkPalette),
    ].map((v) => v.toUpperCase());
    for (const value of allValues) {
      expect(banned).not.toContain(value);
    }
  });
});
