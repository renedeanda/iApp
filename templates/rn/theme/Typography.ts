import { TextStyle } from 'react-native';

/**
 * Typography scale for the Seed RN template.
 *
 * 7 tokens — matches the Swift template's `Typography.swift` so
 * cross-platform copy stays visually consistent. Never use raw font
 * sizes in components; go through `typography.<token>`.
 *
 * The wizard's `/pick-typography` step swaps `fontFamily` at
 * `/new-app --commit` time. Defaults below use System (San Francisco
 * on iOS, Roboto on Android) since custom fonts require an
 * `expo-font` registration the template doesn't ship by default.
 */

const fontFamily = undefined; // System default — wizard overrides if a custom font is picked.

export const typography = {
  display: {
    fontFamily,
    fontSize: 34,
    fontWeight: '700' as const,
    lineHeight: 40,
  },
  title: {
    fontFamily,
    fontSize: 24,
    fontWeight: '700' as const,
    lineHeight: 30,
  },
  headline: {
    fontFamily,
    fontSize: 17,
    fontWeight: '600' as const,
    lineHeight: 22,
  },
  body: {
    fontFamily,
    fontSize: 17,
    fontWeight: '400' as const,
    lineHeight: 22,
  },
  bodyEmphasized: {
    fontFamily,
    fontSize: 17,
    fontWeight: '600' as const,
    lineHeight: 22,
  },
  caption: {
    fontFamily,
    fontSize: 13,
    fontWeight: '400' as const,
    lineHeight: 18,
  },
  mono: {
    fontFamily: 'Menlo',
    fontSize: 14,
    fontWeight: '400' as const,
    lineHeight: 20,
  },
} satisfies Record<string, TextStyle>;

export type TypographyToken = keyof typeof typography;
