import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:crypto/crypto.dart';
import 'package:expense_manager/ui/common/app_strings.dart';

class EncryptionService {
  static const _secretSalt = ksDriveSecretSalt;
  
  encryption.Key? _key;
  encryption.IV? _iv;

  void initialize(String userEmail) {
    final saltedEmail = '$userEmail$_secretSalt';
    final emailBytes = utf8.encode(saltedEmail.toLowerCase());
    final hash = sha256.convert(emailBytes);
    _key = encryption.Key(Uint8List.fromList(hash.bytes));
    _iv = encryption.IV(Uint8List.fromList(hash.bytes.sublist(0, 16)));
  }

  void _checkInitialized() {
    if (_key == null || _iv == null) {
      throw StateError(ksEncryptionNotInitialized);
    }
  }

  String encrypt(String data) {
    _checkInitialized();
    final encrypter = encryption.Encrypter(encryption.AES(_key!));
    return encrypter.encrypt(data, iv: _iv!).base64;
  }

  String decrypt(String encryptedData) {
    _checkInitialized();
    final encrypter = encryption.Encrypter(encryption.AES(_key!));
    return encrypter.decrypt64(encryptedData, iv: _iv!);
  }
} 