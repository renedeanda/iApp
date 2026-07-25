/**
 * Palette tokens for the Seed RN template.
 *
 * The wizard's `/pick-palette` step substitutes hex values for the
 * chosen palette seed at `/new-app --commit` time. Defaults below are
 * a neutral warm-minimal so the template is visually coherent
 * standalone.
 *
 * Code-quality rule (from Kindling CLAUDE.md): no pure #000000 or
 * #FFFFFF. Use the palette's surface tokens. The "off-black" /
 * "off-white" pair below is the warm-minimal default.
 */

export type Palette = {
  bg: string;
  surface: string;
  surfaceElevated: string;
  text: string;
  textSecondary: string;
  textTertiary: string;
  accent: string;
  accentMuted: string;
  onAccent: string;
  border: string;
  danger: string;
  success: string;
};

export const lightPalette: Palette = {
  bg: '#FBF8F4',
  surface: '#F4EFE7',
  surfaceElevated: '#FFFEFB',
  text: '#1A1614',
  textSecondary: '#5C544C',
  textTertiary: '#8F857B',
  accent: '#D97757',
  accentMuted: '#E8B19C',
  onAccent: '#FFFEFB',
  border: '#E6DDD1',
  danger: '#C03B3B',
  success: '#3F8C5C',
};

export const darkPalette: Palette = {
  bg: '#161412',
  surface: '#1F1B17',
  surfaceElevated: '#2A2520',
  text: '#F4EFE7',
  textSecondary: '#B5A99B',
  textTertiary: '#857B70',
  accent: '#E8916A',
  accentMuted: '#A2674E',
  onAccent: '#161412',
  border: '#2E2924',
  danger: '#E06B6B',
  success: '#6FB388',
};

export type ColorScheme = 'light' | 'dark';

export function paletteFor(scheme: ColorScheme): Palette {
  return scheme === 'dark' ? darkPalette : lightPalette;
}

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 32,
} as const;

export const radius = {
  sm: 6,
  md: 10,
  lg: 16,
  pill: 999,
} as const;
