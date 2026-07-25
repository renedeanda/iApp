import React from 'react';
import { Link, Stack } from 'expo-router';
import { StyleSheet, Text, View } from 'react-native';
import { useTranslation } from 'react-i18next';
import { useTheme } from '@/theme/useTheme';

export default function NotFoundScreen() {
  const { t } = useTranslation();
  const { colors, type, spacing } = useTheme();

  return (
    <>
      <Stack.Screen options={{ title: '404' }} />
      <View style={[styles.container, { backgroundColor: colors.bg, padding: spacing.xl }]}>
        <Text style={[type.title, { color: colors.text }]}>{t('notFound.title')}</Text>
        <Link href="/" style={[type.body, { color: colors.accent, marginTop: spacing.md }]}>
          {t('notFound.goHome')}
        </Link>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
