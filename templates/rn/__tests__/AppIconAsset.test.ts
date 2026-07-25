// SOURCE: iApp template — RN counterpart to
//         swift template's AppIconAssetTests.swift
//
// Verifies that once the wizard runs `/generate-icons`, the standard
// asset paths exist. Before icons are generated the test gracefully
// skips with a single "no icons yet" assertion so CI doesn't fail on
// a fresh template — but once any icon exists, the full set must
// exist (no partial states).

import * as fs from 'fs';
import * as path from 'path';

const REPO_ROOT = path.resolve(__dirname, '..');
const IMAGES_DIR = path.join(REPO_ROOT, 'assets', 'images');

const REQUIRED_FILES = ['icon.png', 'adaptive-icon.png', 'favicon.png', 'splash.png'];

function exists(file: string): boolean {
  return fs.existsSync(path.join(IMAGES_DIR, file));
}

describe('App icon assets', () => {
  const anyExists = REQUIRED_FILES.some(exists);

  if (!anyExists) {
    test('icons not generated yet (template stub); run /generate-icons to populate', () => {
      // Sentinel assertion: we passed the file existence sweep without
      // any partial state, which is the only acceptable "no icons" state.
      expect(REQUIRED_FILES.every((f) => !exists(f))).toBe(true);
    });
    return;
  }

  for (const file of REQUIRED_FILES) {
    test(`assets/images/${file} exists`, () => {
      expect(exists(file)).toBe(true);
    });
  }

  test('every generated icon is non-zero size', () => {
    for (const file of REQUIRED_FILES) {
      const fullPath = path.join(IMAGES_DIR, file);
      if (!fs.existsSync(fullPath)) continue;
      const stat = fs.statSync(fullPath);
      expect(stat.size).toBeGreaterThan(0);
    }
  });
});
