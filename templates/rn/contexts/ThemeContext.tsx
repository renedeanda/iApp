import React, { createContext, ReactNode, useEffect, useMemo, useState } from 'react';
import { useColorScheme as useSystemColorScheme } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ColorScheme } from '@/theme/AppTheme';

type Preference = 'system' | 'light' | 'dark';
const PREF_KEY = 'seed.theme.preference';

type ThemeContextValue = {
  preference: Preference;
  setPreference: (p: Preference) => void;
  scheme: ColorScheme; // resolved from preference + system
};

export const ThemeContext = createContext<ThemeContextValue>({
  preference: 'system',
  setPreference: () => {},
  scheme: 'light',
});

export function ThemeProvider({ children }: { children: ReactNode }) {
  const systemScheme = useSystemColorScheme() ?? 'light';
  const [preference, setPreferenceState] = useState<Preference>('system');

  useEffect(() => {
    let cancelled = false;
    void AsyncStorage.getItem(PREF_KEY).then((value) => {
      if (cancelled) return;
      if (value === 'light' || value === 'dark' || value === 'system') {
        setPreferenceState(value);
      }
    });
    return () => {
      cancelled = true;
    };
  }, []);

  const setPreference = (next: Preference) => {
    setPreferenceState(next);
    void AsyncStorage.setItem(PREF_KEY, next);
  };

  const scheme: ColorScheme = preference === 'system' ? (systemScheme as ColorScheme) : preference;

  const value = useMemo(() => ({ preference, setPreference, scheme }), [preference, scheme]);

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}
