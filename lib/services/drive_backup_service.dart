import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:expense_manager/ui/common/app_strings.dart';

class DriveBackupService {
  // Base URLs for Google Drive API endpoints
  static const _driveApiBaseUrl = ksDriveApiBaseUrl;
  static const _uploadBaseUrl = ksDriveUploadBaseUrl;
  // Name of the folder where all app files will be stored in Google Drive
  static const _appFolderName = ksDriveAppFolderName;
  // A unique salt added to user's email for additional security during key generation
  static const _secretSalt = ksDriveSecretSalt;

  // Make encryption components nullable
  encrypt.Key? _key;
  encrypt.IV? _iv;

  // Initialize encryption components with user's email
  void initializeEncryption(String userEmail) {
    // Combine user email with salt for added security
    final saltedEmail = '$userEmail$_secretSalt';
    // Convert email to lowercase and then to bytes for hashing
    final emailBytes = utf8.encode(saltedEmail.toLowerCase());
    // Create SHA-256 hash of the salted email
    final hash = sha256.convert(emailBytes);
    // Use the hash bytes as encryption key
    _key = encrypt.Key(Uint8List.fromList(hash.bytes));
    
    // Use first 16 bytes of hash as IV (AES requires 16 bytes IV)
    final ivBytes = Uint8List.fromList(hash.bytes.sublist(0, 16));
    _iv = encrypt.IV(ivBytes);
  }

  // Updated check method to handle null values
  void _checkEncryptionInitialized() {
    if (_key == null || _iv == null) {
      throw StateError(ksEncryptionNotInitialized);
    }
  }

  // Updated encryption method to handle null safety
  String _encryptData(String data) {
    _checkEncryptionInitialized();
    // Create AES encrypter with our key (we can use ! because we checked above)
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!));
    // Encrypt the data using the IV
    final encrypted = encrypter.encrypt(data, iv: _iv!);
    // Return base64 encoded encrypted data
    return encrypted.base64;
  }

  // Updated decryption method to handle null safety
  String _decryptData(String encryptedData) {
    _checkEncryptionInitialized();
    // Create AES encrypter with our key (we can use ! because we checked above)
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!));
    // Decrypt the base64 encoded data using the IV
    final decrypted = encrypter.decrypt64(encryptedData, iv: _iv!);
    return decrypted;
  }

  // Create or find the app's dedicated folder in Google Drive
  Future<String?> _getOrCreateAppFolder(String accessToken) async {
    try {
      // First check if the app folder already exists
      // Query uses specific mime type for folders and the app folder name
      final files = await listFiles(
        accessToken: accessToken,
        query:
            "name = '$_appFolderName' and mimeType = 'application/vnd.google-apps.folder'",
      );

      // If folder exists, return its ID
      if (files.isNotEmpty) {
        return files.first['id'];
      }

      // If folder doesn't exist, create it
      // Set up headers with authentication token
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Prepare request body with folder metadata
      final body = json.encode({
        'name': _appFolderName,
        'mimeType': 'application/vnd.google-apps.folder',
      });

      // Send POST request to create folder
      final uri = Uri.parse('$_driveApiBaseUrl/files');
      final response = await http.post(uri, headers: headers, body: body);

      // If successful, return the new folder's ID
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['id'];
      }
      return null;
    } catch (e) {
      print('$ksErrorCreatingFolder$e');
      return null;
    }
  }

  // Upload or update a file in Google Drive
  Future<String?> uploadFile({
    required String accessToken,
    required String fileName,
    required String content,
    String? existingFileId,  // Optional: ID of existing file to update
  }) async {
    try {

      // Get or create the app folder
      final folderId = await _getOrCreateAppFolder(accessToken);
      if (folderId == null) {
        throw Exception(ksFolderCreationError);
      }

      // Check if file already exists in the app folder
      final existingFiles = await listFiles(
        accessToken: accessToken,
        query: "name = '$fileName' and '${folderId}' in parents",
      );

      String? fileId;
      if (existingFiles.isNotEmpty) {
        // Update existing file logic
        fileId = existingFiles.first['id'];
        // Create unique boundary for multipart request
        final boundary = 'boundary-${DateTime.now().millisecondsSinceEpoch}';
        final headers = {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        };

        // Prepare metadata for existing file
        final metadata = {
          'name': fileName,
        };

        // Create multipart request parts
        // First part: metadata in JSON format
        final metadataPart = '--$boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '${json.encode(metadata)}\r\n';

        // Second part: encrypted file content
        final encryptedContent = _encryptData(content);
        final contentPart = '--$boundary\r\n'
            'Content-Type: application/json\r\n\r\n'
            '$encryptedContent\r\n'
            '--$boundary--';

        // Combine parts into final request body
        final body = metadataPart + contentPart;

        // Send PATCH request to update existing file
        final uri = Uri.parse('$_uploadBaseUrl/files/$fileId?uploadType=multipart');
        final response = await http.patch(uri, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          return responseData['id'];
        }
      } else {
        // Create new file logic
        final boundary = 'boundary-${DateTime.now().millisecondsSinceEpoch}';
        final headers = {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        };

        // Prepare metadata for new file, including parent folder
        final metadata = {
          'name': fileName,
          'parents': [folderId],  // Place file in app folder
        };

        // Create multipart request parts similar to update logic
        final metadataPart = '--$boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '${json.encode(metadata)}\r\n';

        final encryptedContent = _encryptData(content);
        final contentPart = '--$boundary\r\n'
            'Content-Type: application/json\r\n\r\n'
            '$encryptedContent\r\n'
            '--$boundary--';

        final body = metadataPart + contentPart;

        // Send POST request to create new file
        final uri = Uri.parse('$_uploadBaseUrl/files?uploadType=multipart');
        final response = await http.post(uri, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          return responseData['id'];
        }
      }
      return null;
    } catch (e) {
      print('$ksErrorUploadingFile$e');
      return null;
    }
  }

  // Read a file from Google Drive by its ID
  Future<Map<String, String?>> readFile({
    required String accessToken,
    required String fileId,
  }) async {
    try {
      // Set up authentication header
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      // First request: Get file metadata (name) using fields parameter
      final metadataUri =
          Uri.parse('$_driveApiBaseUrl/files/$fileId?fields=name');
      final metadataResponse = await http.get(metadataUri, headers: headers);

      // Second request: Get actual file content using alt=media parameter
      final contentUri = Uri.parse('$_driveApiBaseUrl/files/$fileId?alt=media');
      final contentResponse = await http.get(contentUri, headers: headers);

      // If both requests are successful
      if (metadataResponse.statusCode == 200 &&
          contentResponse.statusCode == 200) {
        final metadata = json.decode(metadataResponse.body);
        // Decrypt the content before returning it
        final decryptedContent = _decryptData(contentResponse.body);
        return {
          'name': metadata['name'],
          'content': decryptedContent,
        };
      }
      // Return null values if requests fail
      return {'name': null, 'content': null};
    } catch (e) {
      print('$ksErrorReadingFile$e');
      return {'name': null, 'content': null};
    }
  }

  // List files in Google Drive with optional query parameter
  Future<List<Map<String, String>>> listFiles({
    required String accessToken,
    String? query,  // Optional query to filter files
  }) async {
    try {
      // Set up authentication header
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      // Build URI based on whether a query is provided
      var uri = Uri.parse(
          '$_driveApiBaseUrl/files?spaces=drive&fields=files(id,name)');
      if (query != null) {
        // Add query parameter if provided
        uri = Uri.parse(
            '$_driveApiBaseUrl/files?spaces=drive&fields=files(id,name)&q=$query');
      }

      // Send GET request to list files
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Convert response data into List of Maps containing file info
        final files = (responseData['files'] as List)
            .map((file) => {
                  'id': file['id'] as String,
                  'name': file['name'] as String,
                })
            .toList();
        return files;
      }
      return [];
    } catch (e) {
      print('$ksErrorListingFiles$e');
      return [];
    }
  }

  // Delete a file from Google Drive
  Future<bool> deleteFile({
    required String accessToken,
    required String fileId,
  }) async {
    try {
      // Set up authentication header
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      // Send DELETE request
      final uri = Uri.parse('$_driveApiBaseUrl/files/$fileId');
      final response = await http.delete(uri, headers: headers);

      // Return true if deletion was successful (204 No Content)
      return response.statusCode == 204;
    } catch (e) {
      print('$ksErrorDeletingFile$e');
      return false;
    }
  }

  // Read a file by its name from the app's folder
  Future<Map<String, String?>> readFileByName({
    required String accessToken,
    required String fileName,
  }) async {
    try {
      // First get or create the app folder
      final folderId = await _getOrCreateAppFolder(accessToken);
      if (folderId == null) {
        throw Exception(ksFolderCreationError);
      }

      // Search for file in the app folder using query
      final files = await listFiles(
        accessToken: accessToken,
        query: "name = '$fileName' and '${folderId}' in parents",
      );

      // If file not found, return null values
      if (files.isEmpty) {
        return {'name': null, 'content': null};
      }

      // If file found, read its contents
      return await readFile(
        accessToken: accessToken,
        fileId: files.first['id']!,
      );
    } catch (e) {
      print('$ksErrorReadingFileByName$e');
      return {'name': null, 'content': null};
    }
  }

  // Logout from Google Drive
  logout({required String accessToken}) async {
    try {
      // Revoke the access token to properly logout
      final uri = Uri.parse(
          'https://accounts.google.com/o/oauth2/revoke?token=$accessToken');
      await http.get(uri);
    } catch (e) {
      print('$ksErrorRevokingToken$e');
    }
  }
}
