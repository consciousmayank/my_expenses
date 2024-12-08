import 'dart:convert';
import 'dart:typed_data';

import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/models/recurring_expense.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:expense_manager/ui/common/app_strings.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DriveBackupService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

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

  // Add method to refresh token
  Future<String?> _refreshAccessToken() async {
    try {
      print('Attempting to refresh access token...');
      // First try silent sign in
      var currentUser = await _googleSignIn.signInSilently();
      
      // If silent sign in fails, try interactive sign in
      if (currentUser == null) {
        print('Silent sign in failed, attempting interactive sign in...');
        currentUser = await _googleSignIn.signIn();
      }
      
      if (currentUser != null) {
        final auth = await currentUser.authentication;
        print('Successfully refreshed access token');
        return auth.accessToken;
      } else {
        print('Failed to sign in user');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  // Add method to validate token
  Future<bool> _isTokenValid(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=$accessToken'),
      );
      print('Token validation response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  Future<String?> _getValidAccessToken(String accessToken) async {
    print('Validating access token...');
    if (await _isTokenValid(accessToken)) {
      print('Token is valid');
      return accessToken;
    }
    print('Token is invalid, attempting to refresh...');
    final newToken = await _refreshAccessToken();
    if (newToken == null) {
      print('Failed to refresh token, attempting interactive sign in...');
      final currentUser = await _googleSignIn.signIn();
      if (currentUser != null) {
        final auth = await currentUser.authentication;
        return auth.accessToken;
      }
    }
    return newToken;
  }

  // Create or find the app's dedicated folder in Google Drive
  Future<String?> _getOrCreateAppFolder(String accessToken) async {
    int retryCount = 0;
    const maxRetries = 3;

    Future<String?> attempt() async {
      try {
        print('Attempting to find or create app folder: $_appFolderName (Attempt ${retryCount + 1}/$maxRetries)');
        
        // Validate/refresh token first
        final validToken = await _getValidAccessToken(accessToken);
        if (validToken == null) {
          print('Failed to obtain valid access token');
          throw Exception('Failed to obtain valid access token');
        }

        // First check if the app folder already exists
        final files = await listFiles(
          accessToken: validToken,
          query: "name = '$_appFolderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
        );

        if (files.isNotEmpty) {
          print('Found existing app folder with ID: ${files.first['id']}');
          return files.first['id'];
        }

        print('App folder not found. Creating new folder...');

        final headers = {
          'Authorization': 'Bearer $validToken',
          'Content-Type': 'application/json',
        };

        final body = json.encode({
          'name': _appFolderName,
          'mimeType': 'application/vnd.google-apps.folder',
        });

        final uri = Uri.parse('$_driveApiBaseUrl/files');
        print('Sending folder creation request...');
        final response = await http.post(uri, headers: headers, body: body);

        print('Folder creation response status: ${response.statusCode}');
        print('Folder creation response body: ${response.body}');

        if (response.statusCode == 401) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('Failed to authenticate after $maxRetries attempts. Please login again.');
          }
          print('Token expired during request, retrying (Attempt ${retryCount + 1}/$maxRetries)...');
          final newToken = await _refreshAccessToken();
          if (newToken != null) {
            return attempt();
          }
          throw Exception('Failed to refresh token');
        }

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print('Successfully created app folder with ID: ${responseData['id']}');
          return responseData['id'];
        } else {
          print('Failed to create folder. Status code: ${response.statusCode}');
          print('Error response: ${response.body}');
          throw Exception('Failed to create folder: ${response.body}');
        }
      } catch (e, stackTrace) {
        print('Error creating folder: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    }

    return attempt();
  }

  // Upload or update a file in Google Drive
  Future<String?> uploadFile({
    required String accessToken,
    required String fileName,
    required String content,
    String? existingFileId,
  }) async {
    try {
      print('Starting file upload process for: $fileName');
      
      // Validate/refresh token first
      final validToken = await _getValidAccessToken(accessToken);
      if (validToken == null) {
        print('Failed to obtain valid access token');
        throw Exception('Failed to obtain valid access token');
      }

      final folderId = await _getOrCreateAppFolder(validToken);
      if (folderId == null) {
        print('Failed to get or create app folder');
        throw Exception(ksFolderCreationError);
      }

      print('Using folder ID: $folderId');

      // Check if file already exists in the app folder
      print('Checking for existing file...');
      final existingFiles = await listFiles(
        accessToken: validToken,
        query: "name = '$fileName' and '${folderId}' in parents",
      );

      String? fileId;
      if (existingFiles.isNotEmpty) {
        print('Found existing file, updating...');
        fileId = existingFiles.first['id'];
        final boundary = 'boundary-${DateTime.now().millisecondsSinceEpoch}';
        final headers = {
          'Authorization': 'Bearer $validToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        };

        final metadata = {
          'name': fileName,
        };

        // Encrypt the content before uploading
        print('Encrypting content...');
        final encryptedContent = _encryptData(content);
        
        final metadataPart = '--$boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '${json.encode(metadata)}\r\n';

        final contentPart = '--$boundary\r\n'
            'Content-Type: application/json\r\n\r\n'
            '$encryptedContent\r\n'
            '--$boundary--';

        final body = metadataPart + contentPart;

        print('Sending file update request...');
        final uri = Uri.parse('$_uploadBaseUrl/files/$fileId?uploadType=multipart');
        final response = await http.patch(uri, headers: headers, body: body);

        print('File update response status: ${response.statusCode}');
        print('File update response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print('Successfully updated file with ID: ${responseData['id']}');
          return responseData['id'];
        }
      } else {
        print('Creating new file...');
        final boundary = 'boundary-${DateTime.now().millisecondsSinceEpoch}';
        final headers = {
          'Authorization': 'Bearer $validToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        };

        final metadata = {
          'name': fileName,
          'parents': [folderId],
        };

        print('Encrypting content...');
        final encryptedContent = _encryptData(content);
        
        final metadataPart = '--$boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '${json.encode(metadata)}\r\n';

        final contentPart = '--$boundary\r\n'
            'Content-Type: application/json\r\n\r\n'
            '$encryptedContent\r\n'
            '--$boundary--';

        final body = metadataPart + contentPart;

        print('Sending file creation request...');
        final uri = Uri.parse('$_uploadBaseUrl/files?uploadType=multipart');
        final response = await http.post(uri, headers: headers, body: body);

        print('File creation response status: ${response.statusCode}');
        print('File creation response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print('Successfully created file with ID: ${responseData['id']}');
          return responseData['id'];
        }
      }
      return null;
    } catch (e) {
      print('Error uploading file to Drive: $e');
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('Invalid Credentials')) {
        throw Exception('Authentication failed. Please sign in again.');
      }
      rethrow;
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
    String? query, // Optional query to filter files
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
  // Future<bool> deleteFile({
  //   required String accessToken,
  //   required String fileId,
  // }) async {
  //   try {
  //     // Set up authentication header
  //     final headers = {
  //       'Authorization': 'Bearer $accessToken',
  //     };

  //     // Send DELETE request
  //     final uri = Uri.parse('$_driveApiBaseUrl/files/$fileId');
  //     final response = await http.delete(uri, headers: headers);

  //     // Return true if deletion was successful (204 No Content)
  //     return response.statusCode == 204;
  //   } catch (e) {
  //     print('$ksErrorDeletingFile$e');
  //     return false;
  //   }
  // }

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

  // Add method to backup both expenses and recurring expenses
  Future<bool> backupData({
    required String accessToken,
    required List<Expense> expenses,
    required List<RecurringExpense> recurringExpenses,
  }) async {
    try {
      final backupContent = json.encode({
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'recurringExpenses': recurringExpenses.map((e) => e.toJson()).toList(),
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      });

      final fileId = await uploadFile(
        accessToken: accessToken,
        fileName: ksFileName,
        content: backupContent,
      );

      return fileId != null;
    } catch (e) {
      print('Error backing up data: $e');
      return false;
    }
  }

  // Update restore functionality to handle recurring expenses
  Future<Map<String, dynamic>> restoreData({
    required String accessToken,
  }) async {
    try {
      final result = await readFileByName(
        accessToken: accessToken,
        fileName: ksFileName,
      );

      if (result['content'] == null) {
        return {
          'success': false,
          'error': 'No backup file found',
          'expenses': <Expense>[],
          'recurringExpenses': <RecurringExpense>[],
        };
      }

      final Map<String, dynamic> backupData = json.decode(result['content']!);
      
      // Parse regular expenses
      final List<Expense> expenses = (backupData['expenses'] as List)
          .where((element) {
            final isRecurring = (element as Map<String, dynamic>)['isRecurring'];
            return isRecurring == null || isRecurring == false;
          })
          .map((json) => Expense.fromJson(json))
          .toList();

      // Parse recurring expenses  
      final List<RecurringExpense> recurringExpenses = 
          (backupData['recurringExpenses'] as List? ?? [])
          .where((element) {
            final isRecurring = (element as Map<String, dynamic>)['isRecurring'];
            return isRecurring == null || isRecurring == false;
          })
          .map((json) => RecurringExpense.fromJson(json))
          .toList();

      return {
        'success': true,
        'expenses': expenses,
        'recurringExpenses': recurringExpenses,
      };
    } catch (e) {
      print('Error restoring data: $e');
      return {
        'success': false,
        'error': e.toString(),
        'expenses': <Expense>[],
        'recurringExpenses': <RecurringExpense>[],
      };
    }
  }
}
