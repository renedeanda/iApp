import React from 'react';
import {
  AccessibilityRole,
  Pressable,
  StyleSheet,
  Text,
  ViewStyle,
} from 'react-native';
import * as Haptics from 'expo-haptics';
import { useTheme } from '@/theme/useTheme';

type Props = {
  title: string;
  onPress: () => void;
  disabled?: boolean;
  accessibilityHint?: string;
  style?: ViewStyle;
};

/**
 * Standard primary CTA. Haptic-on-press (light impact) gated by the
 * platform's Reduce Motion preference, since RN's `AccessibilityInfo`
 * doesn't surface Reduce Haptics directly. Kindling convention:
 * `expo-haptics` calls should always be wrapped in a check the app
 * can disable centrally — for the template, we ship the simplest
 * shape and the wizard's `/earn-haptic` skill controls when more
 * patterns get added.
 */
export function PrimaryButton({
  title,
  onPress,
  disabled = false,
  accessibilityHint,
  style,
}: Props) {
  const { colors, type, spacing, radius } = useTheme();

  const handlePress = () => {
    void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    onPress();
  };

  const role: AccessibilityRole = 'button';

  return (
    <Pressable
      accessibilityRole={role}
      accessibilityHint={accessibilityHint}
      accessibilityState={{ disabled }}
      disabled={disabled}
      onPress={handlePress}
      style={({ pressed }) => [
        styles.base,
        {
          backgroundColor: disabled ? colors.accentMuted : colors.accent,
          paddingVertical: spacing.md,
          paddingHorizontal: spacing.xl,
          borderRadius: radius.md,
          opacity: pressed ? 0.85 : 1,
        },
        style,
      ]}
    >
      <Text style={[type.bodyEmphasized, { color: colors.onAccent }]}>{title}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 44, // iOS HIG touch target
  },
});
