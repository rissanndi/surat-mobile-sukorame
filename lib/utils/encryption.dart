import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple client-side encryption utility using AES-GCM.
///
/// Usage:
/// - Call [encryptField] before writing sensitive strings to Firestore.
/// - Call [decryptField] after reading those fields.
///
/// Security notes (important):
/// - This stores a randomly generated 32-byte master key in Flutter Secure Storage on first run.
/// - For production and high-security needs, use a proper KMS (Cloud KMS) or server-side key management.
/// - Don't hard-code keys in the app.

const _kMasterKeyStorageKey = 'app_master_encryption_key_v1';
const _kEncryptedPrefix = 'enc:'; // marker to recognize encrypted fields

final _secureStorage = const FlutterSecureStorage();
final AesGcm _aesGcm = AesGcm.with256bits();

/// Get or create the master key (32 bytes) stored in secure storage as base64.
Future<SecretKey> _getOrCreateMasterKey() async {
  final existing = await _secureStorage.read(key: _kMasterKeyStorageKey);
  if (existing != null) {
    final keyBytes = base64.decode(existing);
    return SecretKey(keyBytes);
  }

  // Generate a new secret key
  final key = await _aesGcm.newSecretKey();
  final keyBytes = await key.extractBytes();
  await _secureStorage.write(key: _kMasterKeyStorageKey, value: base64.encode(keyBytes));
  return SecretKey(keyBytes);
}

/// Encrypt a plaintext string and return a compact base64 string prefixed with [_kEncryptedPrefix].
/// Returns the original input if it's null or empty.
Future<String> encryptField(String? plaintext) async {
  if (plaintext == null || plaintext.isEmpty) return plaintext ?? '';

  final secretKey = await _getOrCreateMasterKey();

  // Generate a fresh random nonce (12 bytes recommended for AES-GCM)
  final nonce = _aesGcm.newNonce();

  final secretBox = await _aesGcm.encrypt(
    utf8.encode(plaintext),
    secretKey: secretKey,
    nonce: nonce,
  );

  // Combine nonce + ciphertext + mac into a single byte array
  final combined = <int>[];
  combined.addAll(secretBox.nonce);
  combined.addAll(secretBox.cipherText);
  combined.addAll(secretBox.mac.bytes);

  return '$_kEncryptedPrefix${base64.encode(Uint8List.fromList(combined))}';
}

/// Decrypt a field that was produced by [encryptField]. If the value is not marked as encrypted
/// (doesn't start with [_kEncryptedPrefix]), it will be returned unchanged.
Future<String> decryptField(String? value) async {
  if (value == null || value.isEmpty) return value ?? '';
  if (!value.startsWith(_kEncryptedPrefix)) return value;

  final payload = value.substring(_kEncryptedPrefix.length);
  final bytes = base64.decode(payload);

  // nonce (12 bytes) + ciphertext + mac (16 bytes) => need to split
  if (bytes.length < 12 + 16) {
    // malformed
    throw FormatException('Encrypted value is too short or malformed');
  }

  final nonce = bytes.sublist(0, 12);
  final macBytes = bytes.sublist(bytes.length - 16);
  final cipherText = bytes.sublist(12, bytes.length - 16);

  final secretKey = await _getOrCreateMasterKey();

  final secretBox = SecretBox(
    cipherText,
    nonce: nonce,
    mac: Mac(macBytes),
  );

  final clear = await _aesGcm.decrypt(secretBox, secretKey: secretKey);
  return utf8.decode(clear);
}

/// Helper: try to decrypt but return original on failure (useful for UI).
Future<String> tryDecryptField(String? value) async {
  try {
    return await decryptField(value);
  } catch (_) {
    return value ?? '';
  }
}
