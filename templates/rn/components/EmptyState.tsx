import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useTheme } from '@/theme/useTheme';

type Props = {
  title: string;
  subtitle?: string;
  action?: React.ReactNode;
};

/**
 * Generic empty state. iApp UX rule: every list/collection
 * surface ships an empty state with a CTA. This component is the
 * default shape — customize colors / icons via the theme tokens.
 */
export function EmptyState({ title, subtitle, action }: Props) {
  const { colors, type, spacing } = useTheme();

  return (
    <View
      style={[
        styles.container,
        { paddingHorizontal: spacing.xl, gap: spacing.md },
      ]}
    >
      <Text style={[type.title, { color: colors.text, textAlign: 'center' }]}>
        {title}
      </Text>
      {subtitle ? (
        <Text
          style={[
            type.body,
            { color: colors.textSecondary, textAlign: 'center' },
          ]}
        >
          {subtitle}
        </Text>
      ) : null}
      {action ? <View style={{ marginTop: spacing.lg }}>{action}</View> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
