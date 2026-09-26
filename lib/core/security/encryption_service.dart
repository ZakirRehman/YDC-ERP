import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Cryptographic vault engine providing AES-256-GCM envelope encryption
/// and in-memory decryption directly to Flutter viewports (Zero-Disk-Leak)
class EncryptionService {
  static final _aesGcm = AesGcm.with256bits();
  static final _sha256 = Sha256();

  /// Derives a 256-bit SecretKey from a PIN or Master Password using PBKDF2 with SHA-256
  static Future<SecretKey> deriveKeyFromPassword(String password, [List<int>? salt]) async {
    final effectiveSalt = salt ?? utf8.encode('YDC_AUST_SECURE_SALT_2026');
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: effectiveSalt,
    );
  }

  /// Calculates SHA-256 hex checksum of raw byte content
  static Future<String> calculateChecksum(Uint8List data) async {
    final hash = await _sha256.hash(data);
    return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Encrypts raw bytes using AES-256-GCM and persists as an .enc file in AppData vault
  static Future<String> encryptAndStoreFile({
    required Uint8List rawBytes,
    required String originalFileName,
    required String masterPassword,
    Directory? customTargetDir,
  }) async {
    final secretKey = await deriveKeyFromPassword(masterPassword);

    // Encrypt in-memory
    final secretBox = await _aesGcm.encrypt(
      rawBytes,
      secretKey: secretKey,
    );

    // Concatenate nonce + ciphertext + MAC
    final encryptedBytes = secretBox.concatenation();

    Directory vaultDir;
    if (customTargetDir != null) {
      vaultDir = customTargetDir;
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        vaultDir = Directory(p.join(appDir.path, 'YDC_AUST', 'Vault'));
      } catch (_) {
        // Fallback for headless environments / unit tests without platform channels
        vaultDir = Directory(p.join(Directory.systemTemp.path, 'YDC_AUST', 'Vault'));
      }
    }

    if (!vaultDir.existsSync()) {
      vaultDir.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedBase = p.basenameWithoutExtension(originalFileName).replaceAll(RegExp(r'\s+'), '_');
    final encryptedPath = p.join(vaultDir.path, '${sanitizedBase}_$timestamp.enc');

    await File(encryptedPath).writeAsBytes(encryptedBytes);
    return encryptedPath;
  }

  /// Decrypts an .enc file directly into RAM volatile memory (never written plaintext to disk)
  static Future<Uint8List> decryptFileInMemory({
    required String encryptedFilePath,
    required String masterPassword,
  }) async {
    final file = File(encryptedFilePath);
    if (!file.existsSync()) {
      throw Exception('Encrypted file does not exist on disk.');
    }

    final encryptedBytes = await file.readAsBytes();
    final secretKey = await deriveKeyFromPassword(masterPassword);

    // Reconstruct SecretBox from concatenated byte stream (12-byte nonce, 16-byte MAC)
    final secretBox = SecretBox.fromConcatenation(
      encryptedBytes,
      nonceLength: _aesGcm.nonceLength,
      macLength: _aesGcm.macAlgorithm.macLength,
    );

    final decryptedBytes = await _aesGcm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return Uint8List.fromList(decryptedBytes);
  }
}
