import { useContext } from 'react';
import { ThemeContext } from '@/contexts/ThemeContext';
import { typography } from '@/theme/Typography';
import { paletteFor, spacing, radius } from '@/theme/AppTheme';

/**
 * Convenience hook so views can write `const { colors, type } = useTheme()`
 * instead of pulling palette + scheme + typography separately.
 *
 * Source pattern: the consumer shape proven in a shipped production
 * RN app, simplified — the iApp default theme has no premium
 * tiers, so this hook only returns colors + scale.
 */
export function useTheme() {
  const { scheme } = useContext(ThemeContext);
  return {
    scheme,
    colors: paletteFor(scheme),
    type: typography,
    spacing,
    radius,
  };
}
