# Review routing matrix

Apply the rows relevant to the submission. Evidence priority is archive/runtime over source/config.

| Area | Trigger | Deterministic evidence | Manual/runtime evidence |
|---|---|---|---|
| Completeness | every app | final archive, version/build, metadata validation, placeholder scan, reachable backend | clean launch, core journey, reviewer credentials/instructions |
| Privacy | data collection or required-reason API | privacy manifests, SDK inventory, permission strings, the app's privacy plan | ASC label matches actual flows; consent and minimization |
| Tracking | cross-company app/site tracking | SDK/config/domain inventory, `NSUserTrackingUsageDescription` | ATT timing; no tracking before authorization |
| Account deletion | app creates accounts or cloud identity/data | deletion entry points and service calls | deletion works, truthful pending/failure state, reinstall does not resurrect data |
| Purchases | IAP/subscription/paywall | product IDs, StoreKit API, restore/manage path, legal links | products load; purchase/restore/cancel; price and renewal clarity |
| Login | third-party/social login | providers and entitlements | current guideline 4.8 equivalence and exceptions; account recovery |
| UGC | users create/share public content | report/block/filter/moderation/contact implementation | abuse flow and response path actually work |
| Permissions | sensitive frameworks/capabilities | archive purpose strings and entitlements | denial path, just-in-time request, feature remains understandable |
| Background work | background modes/tasks/push | built `UIBackgroundModes`, entitlements, task registration | behavior matches declared purpose; no hidden continuous work |
| Legal/support | every app | metadata/config URLs use HTTPS and correct slug | privacy, terms/EULA, and support pages resolve and match the app |
| Extensions | widgets/share/watch/live activities | embedded target inventory, manifests, entitlements, localization | renders, deep-links, stale/zero state, privacy-safe shared data |
| AI | generated content or external model calls | provider/config/data flow and terms | disclosure, consent for personal data, safe failure, review notes |
| Regulated | health, finance, kids, gambling, crypto, VPN, etc. | capabilities, claims, age/category metadata | licensed/qualified-party requirements and jurisdiction-specific review |

## Severity

- **Blocker:** observed build/archive/runtime failure or clear conflict with a current, cited Apple requirement.
- **High:** strong evidence of likely review failure, but one fact or reviewer judgment remains.
- **Medium:** meaningful quality/compliance risk unlikely to stand alone as a rejection.
- **Manual:** cannot be established from static evidence.
- **Verified:** tested evidence supports the expected behavior; never means approval is guaranteed.

## False-positive guards

- Analytics is not automatically tracking. Apply ATT only to activity that meets Apple's tracking definition.
- A social-login rule is not synonymous with “always add Sign in with Apple”; read current guideline 4.8 and its exceptions/equivalence language.
- Build-time environment variables and bundled config are not secret storage.
- A framework import is a signal, not proof of data collection or permission use.
- A missing privacy manifest is not automatically a blocker; determine whether the target or included SDK uses covered APIs.
- Logs, TODOs, or platform references require context. Report shipping impact, not keyword presence.
- A privacy/support URL existing in source does not prove it is live or reachable from the submitted UI.
