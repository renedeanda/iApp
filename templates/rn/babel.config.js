// Babel config for Expo SDK 54 / RN 0.81.
// Reanimated's plugin MUST be last — see Reanimated docs.

module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: ['react-native-reanimated/plugin'],
  };
};
