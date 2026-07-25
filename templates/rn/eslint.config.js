// ESLint flat config for the Seed RN template.
// Extends Expo's preset (wires React, RN, TS, hooks).
// `eslint-config-expo` is declared in package.json devDependencies.
//
// Source pattern: proven in a shipped production RN app, trimmed to essentials.

const expoConfig = require('eslint-config-expo/flat');

module.exports = [
  ...expoConfig,
  {
    ignores: ['dist/*', 'node_modules/*', '.expo/*', 'android/*', 'ios/*'],
  },
  {
    // Hardcoded English strings are caught by /l10n-audit, not ESLint.
    // No rule overrides here yet — let Expo's preset stand.
    rules: {},
  },
];
