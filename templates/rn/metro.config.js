// Metro config. See https://docs.expo.dev/guides/customizing-metro/
// Source pattern: verbatim default Expo
// config. Override here only when the child app needs a custom
// resolver (rare).

const { getDefaultConfig } = require('expo/metro-config');

/** @type {import('expo/metro-config').MetroConfig} */
const config = getDefaultConfig(__dirname);

module.exports = config;
