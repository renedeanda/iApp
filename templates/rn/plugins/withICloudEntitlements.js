// SOURCE: harvested from a shipped production app's iCloud entitlements plugin.
// Generalized: bundle id is read from config (no hardcoding); derives
// the iCloud container, KVS identifier, and APS environment.

/**
 * Adds the iCloud (CloudKit + KVS + silent push) entitlements at
 * prebuild. Pairs with `modules/icloud-sync/`.
 *
 * Without these entries, `expo prebuild` succeeds but every iCloud
 * call fails at runtime with permission errors and the JS layer
 * sees iCloud as unavailable.
 *
 * Usage in app.json:
 *   "plugins": [..., "./plugins/withICloudEntitlements"]
 *
 * Optional inline config:
 *   ["./plugins/withICloudEntitlements", { "apsEnvironment": "production" }]
 */

const { withEntitlementsPlist } = require('@expo/config-plugins');

function withICloudEntitlements(config, options = {}) {
  const apsEnvironment = options.apsEnvironment || 'development';

  return withEntitlementsPlist(config, (cfg) => {
    const bundleId = cfg.ios?.bundleIdentifier;
    if (!bundleId) {
      throw new Error(
        '[withICloudEntitlements] ios.bundleIdentifier must be set in app.json before this plugin runs.'
      );
    }

    const containerId = `iCloud.${bundleId}`;
    const kvsIdentifier = `$(TeamIdentifierPrefix)${bundleId}`;

    cfg.modResults['com.apple.developer.icloud-services'] = [
      'CloudKit',
      'CloudDocuments',
    ];
    cfg.modResults['com.apple.developer.icloud-container-identifiers'] = [
      containerId,
    ];
    cfg.modResults['com.apple.developer.ubiquity-container-identifiers'] = [
      containerId,
    ];
    cfg.modResults['com.apple.developer.ubiquity-kvstore-identifier'] =
      kvsIdentifier;
    // Silent push for CKRecordZoneSubscription notifications.
    cfg.modResults['aps-environment'] = apsEnvironment;

    return cfg;
  });
}

module.exports = withICloudEntitlements;
