import React, { useContext, useState } from 'react';
import { ActivityIndicator, Alert, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTranslation } from 'react-i18next';
import * as Application from 'expo-application';
import { ThemeContext } from '@/contexts/ThemeContext';
import { deleteAllAppData, type DeletionOutcome } from '@/src/services/DataDeletionService';
import { useTheme } from '@/theme/useTheme';

type Preference = 'system' | 'light' | 'dark';

export default function SettingsScreen() {
  const { t } = useTranslation();
  const { preference, setPreference } = useContext(ThemeContext);
  const { colors, type, spacing, radius } = useTheme();
  const [isDeleting, setIsDeleting] = useState(false);
  const [showDataBackup, setShowDataBackup] = useState(false);

  const choices: { value: Preference; label: string }[] = [
    { value: 'system', label: t('settings.appearanceSystem') },
    { value: 'light', label: t('settings.appearanceLight') },
    { value: 'dark', label: t('settings.appearanceDark') },
  ];

  const confirmDeleteAllData = () => {
    Alert.alert(
      t('settings.deleteAllDataConfirmTitle'),
      t('settings.deleteAllDataConfirmMessage'),
      [
        { text: t('settings.cancel'), style: 'cancel' },
        {
          text: t('settings.deleteAllDataConfirmButton'),
          style: 'destructive',
          onPress: () => {
            void handleDeleteAllData();
          },
        },
      ]
    );
  };

  // Honest per-outcome copy — never claim more than what happened.
  const outcomeMessageKeys: Record<DeletionOutcome, string> = {
    fullyDeleted: 'settings.deleteAllDataSuccess',
    cloudPending: 'settings.deleteAllDataPendingCloud',
    cloudUnavailable: 'settings.deleteAllDataNoAccount',
    localFailed: 'settings.deleteAllDataError',
  };

  const handleDeleteAllData = async () => {
    setIsDeleting(true);
    try {
      const outcome = await deleteAllAppData();
      Alert.alert(
        t('settings.deleteAllDataResultTitle'),
        t(outcomeMessageKeys[outcome])
      );
    } finally {
      setIsDeleting(false);
    }
  };

  if (showDataBackup) {
    return (
      <SafeAreaView style={[styles.flex, { backgroundColor: colors.bg }]}>
        <View style={[styles.content, { padding: spacing.xl, gap: spacing.lg }]}>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={t('settings.back')}
            onPress={() => setShowDataBackup(false)}
            style={styles.backButton}
          >
            <Text style={[type.body, { color: colors.accent }]}>
              {t('settings.back')}
            </Text>
          </Pressable>

          <Text style={[type.title, { color: colors.text }]}>
            {t('settings.dataAndBackup')}
          </Text>

          <Pressable
            accessibilityRole="button"
            accessibilityLabel={t('settings.deleteAllData')}
            testID="settings.data.deleteAllData"
            disabled={isDeleting}
            onPress={confirmDeleteAllData}
            style={[
              styles.dataRow,
              {
                backgroundColor: colors.surface,
                borderRadius: radius.md,
                opacity: isDeleting ? 0.65 : 1,
              },
            ]}
          >
            <View style={styles.dataRowText}>
              <Text style={[type.body, { color: colors.danger }]}>
                {t('settings.deleteAllData')}
              </Text>
              <Text style={[type.caption, { color: colors.textTertiary }]}>
                {t('settings.deleteAllDataSubtitle')}
              </Text>
            </View>
            {isDeleting ? <ActivityIndicator color={colors.danger} /> : null}
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[styles.flex, { backgroundColor: colors.bg }]}>
      <View style={[styles.content, { padding: spacing.xl, gap: spacing.lg }]}>
        <Text style={[type.title, { color: colors.text }]}>
          {t('settings.title')}
        </Text>

        <View style={{ gap: spacing.sm }}>
          <Text style={[type.headline, { color: colors.text }]}>
            {t('settings.appearance')}
          </Text>
          <View
            style={[
              styles.segmented,
              { backgroundColor: colors.surface, borderRadius: radius.md },
            ]}
          >
            {choices.map((c) => {
              const active = c.value === preference;
              return (
                <Pressable
                  key={c.value}
                  accessibilityRole="button"
                  accessibilityState={{ selected: active }}
                  onPress={() => setPreference(c.value)}
                  style={[
                    styles.segment,
                    {
                      backgroundColor: active ? colors.surfaceElevated : 'transparent',
                      borderRadius: radius.sm,
                    },
                  ]}
                >
                  <Text style={[type.body, { color: active ? colors.accent : colors.textSecondary }]}>
                    {c.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>
        </View>

        <View style={{ gap: spacing.sm }}>
          <Text style={[type.headline, { color: colors.text }]}>
            {t('settings.data')}
          </Text>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={t('settings.dataAndBackup')}
            testID="settings.data.open"
            disabled={isDeleting}
            onPress={() => setShowDataBackup(true)}
            style={[
              styles.dataRow,
              {
                backgroundColor: colors.surface,
                borderRadius: radius.md,
                opacity: isDeleting ? 0.65 : 1,
              },
            ]}
          >
            <View style={styles.dataRowText}>
              <Text style={[type.body, { color: colors.text }]}>
                {t('settings.dataAndBackup')}
              </Text>
              <Text style={[type.caption, { color: colors.textTertiary }]}>
                {t('settings.dataAndBackupSubtitle')}
              </Text>
            </View>
            {isDeleting ? <ActivityIndicator color={colors.accent} /> : null}
          </Pressable>
        </View>

        <View style={{ gap: spacing.xs }}>
          <Text style={[type.headline, { color: colors.text }]}>
            {t('settings.about')}
          </Text>
          <Text style={[type.caption, { color: colors.textTertiary }]}>
            {t('settings.version')} {Application.nativeApplicationVersion ?? '1.0.0'} (
            {Application.nativeBuildVersion ?? '1'})
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { flex: 1 },
  segmented: {
    flexDirection: 'row',
    padding: 4,
    gap: 4,
  },
  segment: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 10,
    minHeight: 44,
  },
  dataRow: {
    minHeight: 64,
    paddingHorizontal: 16,
    paddingVertical: 12,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
  },
  dataRowText: {
    flex: 1,
    gap: 4,
  },
  backButton: {
    alignSelf: 'flex-start',
    minHeight: 44,
    justifyContent: 'center',
  },
});
