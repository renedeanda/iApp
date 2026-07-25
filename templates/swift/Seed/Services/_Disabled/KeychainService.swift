// SOURCE: proven in a shipped production app.
// Thin Keychain wrapper, no force-unwraps.

import Foundation
import Security

/// Thin Keychain wrapper. No force-unwraps. Generic-password class only.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// `keychain`. Use for credential / token storage; never for
/// app-state UserDefaults can hold.
///
/// Source pattern: proven in a shipped production app.
/// (per portfolio/REUSE_INDEX.md).
///
/// All values are stored with `kSecAttrAccessibleAfterFirstUnlock`
/// so background launches can read but the data is encrypted at rest.
struct KeychainService {
    enum KeychainError: Error {
        case unhandled(OSStatus)
        case dataConversion
    }

    private let service: String

    init(service: String) {
        self.service = service
    }

    /// Store a value for `key`. Overwrites any existing entry.
    func set(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataConversion
        }

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        // Remove existing entry, then add fresh.
        SecItemDelete(query as CFDictionary)

        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status)
        }
    }

    /// Read the value for `key`, or nil if not present.
    func get(_ key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status)
        }
        guard let data = item as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.dataConversion
        }
        return value
    }

    /// Delete the value for `key`. Silent no-op if absent.
    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
