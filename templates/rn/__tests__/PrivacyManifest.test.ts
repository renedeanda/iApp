// SOURCE: Kindling template — RN counterpart to
//         swift template's PrivacyManifestTests.swift
//
// Verifies app.json's privacyManifests block declares every
// required-reason API the template uses. Apple rejects app submissions
// that import APIs without declared reasons; this test catches drift
// at PR time instead of at submission time.

import appJson from '@/app.json';

type RequiredReasonAPI = {
  NSPrivacyAccessedAPIType: string;
  NSPrivacyAccessedAPITypeReasons: string[];
};

type PrivacyManifests = {
  NSPrivacyTracking: boolean;
  NSPrivacyAccessedAPITypes: RequiredReasonAPI[];
};

const REQUIRED_CATEGORIES_USED_BY_TEMPLATE = [
  // AsyncStorage (the @react-native-async-storage/async-storage dep)
  // reads/writes UserDefaults under the hood. Reason CA92.1 ("Declare
  // this reason to access user defaults that contain information that
  // is only accessible to the app itself").
  'NSPrivacyAccessedAPICategoryUserDefaults',
];

describe('Privacy manifest', () => {
  const ios = (appJson as { expo: { ios: { privacyManifests?: PrivacyManifests } } }).expo.ios;

  test('expo.ios.privacyManifests block exists', () => {
    expect(ios.privacyManifests).toBeDefined();
  });

  test('NSPrivacyTracking is explicitly false (template does not track)', () => {
    expect(ios.privacyManifests?.NSPrivacyTracking).toBe(false);
  });

  test('declares every required-reason API category used by the template', () => {
    const declared = (ios.privacyManifests?.NSPrivacyAccessedAPITypes ?? []).map(
      (entry) => entry.NSPrivacyAccessedAPIType
    );
    for (const required of REQUIRED_CATEGORIES_USED_BY_TEMPLATE) {
      expect(declared).toContain(required);
    }
  });

  test('every declared API has at least one reason code', () => {
    const types = ios.privacyManifests?.NSPrivacyAccessedAPITypes ?? [];
    for (const entry of types) {
      expect(entry.NSPrivacyAccessedAPITypeReasons.length).toBeGreaterThan(0);
    }
  });
});
