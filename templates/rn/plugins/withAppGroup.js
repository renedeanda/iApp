// SOURCE: harvested from a shipped production app's widget-extension plugin (App Groups slice only).
// Extracted into its own plugin so apps without widgets can still
// share UserDefaults / file containers between the host app and a
// future extension (e.g. notification service extension, share
// extension).

/**
 * Adds the App Groups entitlement to the iOS main app target.
 *
 * The group identifier defaults to `group.<bundleIdentifier>`. Pass an
 * explicit identifier via plugin options to override:
 *
 *   ["./plugins/withAppGroup", { "identifier": "group.com.you.shared" }]
 *
 * Why a separate plugin: widget extensions, notification service
 * extensions, and share extensions all need the same App Group. If you
 * only need shared storage and not a full extension, this plugin alone
 * is enough — saves the heavier widget-extension prebuild dance.
 */

const { withEntitlementsPlist } = require('@expo/config-plugins');

function withAppGroup(config, options = {}) {
  return withEntitlementsPlist(config, (cfg) => {
    const bundleId = cfg.ios?.bundleIdentifier;
    if (!bundleId) {
      throw new Error(
        '[withAppGroup] ios.bundleIdentifier must be set in app.json before this plugin runs.'
      );
    }
    const groupId = options.identifier || `group.${bundleId}`;

    const existing =
      cfg.modResults['com.apple.security.application-groups'] || [];
    const groups = Array.from(new Set([...existing, groupId]));
    cfg.modResults['com.apple.security.application-groups'] = groups;

    return cfg;
  });
}

module.exports = withAppGroup;
