import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTranslation } from 'react-i18next';
import { useTheme } from '@/theme/useTheme';
import { PrimaryButton } from '@/components/PrimaryButton';

export default function HomeScreen() {
  const { t } = useTranslation();
  const { colors, type, spacing } = useTheme();

  return (
    <SafeAreaView style={[styles.flex, { backgroundColor: colors.bg }]}>
      <View
        style={[
          styles.content,
          { padding: spacing.xl, gap: spacing.md },
        ]}
      >
        <Text style={[type.display, { color: colors.text }]}>
          {t('home.title')}
        </Text>
        <Text style={[type.body, { color: colors.textSecondary }]}>
          {t('home.subtitle')}
        </Text>
        <View style={{ marginTop: spacing.lg }}>
          <PrimaryButton title={t('home.primaryCTA')} onPress={() => {}} />
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { flex: 1, justifyContent: 'center' },
});
