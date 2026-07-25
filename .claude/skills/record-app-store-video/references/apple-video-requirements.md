# Apple video requirements

Refresh these official pages immediately before capture or delivery:

- App preview specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/
- App preview creative guidance: https://developer.apple.com/app-store/app-previews/
- Upload app previews and screenshots: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- App Review attachments API overview: https://developer.apple.com/documentation/appstoreconnectapi/app-store-review-attachments
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

## Current App Store preview baseline

Verified against Apple's official English specification on 2026-07-19. Recheck before relying on it.

- Duration: 15–30 seconds.
- Maximum file size: 500 MB.
- Formats: H.264 in `.mov`, `.m4v`, or `.mp4`; ProRes 422 HQ in `.mov`.
- Maximum frame rate: 30 fps.
- H.264 target bitrate: 10–12 Mbps, progressive, up to High Profile Level 4.0.
- Audio, when present: enabled stereo tracks using 256 kbps AAC at 44.1 or 48 kHz. ProRes may also use PCM.
- Orientation: portrait or landscape for iOS; macOS and tvOS are landscape only.
- Default poster-frame time: five seconds.
- Up to three previews may be supplied per supported device size and language.
- Accepted pixel dimensions vary by current device-display class. Read the live resolution table and pass the chosen exact size to the validator; do not assume native Simulator pixels are directly uploadable.

App Review attachments are evidence for reviewers, not public App Store previews. Apple accepts documentation and demo videos through the review-attachment workflow, but the public preview's 15–30 second product-page rules should not be imposed on a reviewer walkthrough unless Apple specifically requests that format.
