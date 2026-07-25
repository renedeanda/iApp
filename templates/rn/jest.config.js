/**
 * Jest configuration for the Seed RN template.
 *
 * Uses `jest-expo` preset so that Reanimated / Expo modules can be
 * imported in tests without bespoke mocks. Pure unit tests can stay
 * with `ts-jest` if a suite never imports a native module.
 *
 * Source pattern: proven in a shipped production RN app, adapted to add the Expo
 * preset so Reanimated v4 doesn't blow up.
 *
 * @type {import('jest').Config}
 */
module.exports = {
  preset: 'jest-expo',
  roots: ['<rootDir>/__tests__'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg))',
  ],
};
