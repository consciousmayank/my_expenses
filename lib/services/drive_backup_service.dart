import 'dart:convert';

import 'package:http/http.dart' as http;

class DriveBackupService {
  static const _driveApiBaseUrl = 'https://www.googleapis.com/drive/v3';
  static const _uploadBaseUrl = 'https://www.googleapis.com/upload/drive/v3';
  static const _appFolderName = 'Expense Manager'; // Your app name here

  // Create a folder if it doesn't exist
  Future<String?> _getOrCreateAppFolder(String accessToken) async {
    try {
      // First check if folder exists
      final files = await listFiles(
        accessToken: accessToken,
        query:
            "name = '$_appFolderName' and mimeType = 'application/vnd.google-apps.folder'",
      );

      if (files.isNotEmpty) {
        return files.first['id'];
      }

      // Create folder if it doesn't exist
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'name': _appFolderName,
        'mimeType': 'application/vnd.google-apps.folder',
      });

      final uri = Uri.parse('$_driveApiBaseUrl/files');
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['id'];
      }
      return null;
    } catch (e) {
      print('Error creating folder: $e');
      return null;
    }
  }

  Future<String?> uploadFile({
    required String accessToken,
    required String fileName,
    required String content,
    String? existingFileId,
  }) async {
    try {
      final folderId = await _getOrCreateAppFolder(accessToken);
      if (folderId == null) {
        throw Exception('Failed to create or find app folder');
      }

      // Check for existing backup files
      final existingFiles = await listFiles(
        accessToken: accessToken,
        query: "name = '$fileName' and '${folderId}' in parents",
      );

      // Upload new backup file
      final boundary = 'boundary-${DateTime.now().millisecondsSinceEpoch}';
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/related; boundary=$boundary',
      };

      final metadata = {
        'name': fileName,
        'parents': [folderId],
      };

      final metadataPart = '--$boundary\r\n'
          'Content-Type: application/json; charset=UTF-8\r\n\r\n'
          '${json.encode(metadata)}\r\n';

      final contentPart = '--$boundary\r\n'
          'Content-Type: application/json\r\n\r\n'
          '$content\r\n'
          '--$boundary--';

      final body = metadataPart + contentPart;

      final uri = Uri.parse('$_uploadBaseUrl/files?uploadType=multipart');
      final response = await http.post(uri, headers: headers, body: body);

      String? newFileId;
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        newFileId = responseData['id'];

        // Delete old backup files after successful upload
        // for (var file in existingFiles) {
        //   if (file['id'] != newFileId) {
        //     await deleteFile(
        //       accessToken: accessToken,
        //       fileId: file['id']!,
        //     );
        //   }
        // }`

        return newFileId;
      }
      return null;
    } catch (e) {
      print('Error uploading file to Drive: $e');
      return null;
    }
  }

  // Read a file
  Future<Map<String, String?>> readFile({
    required String accessToken,
    required String fileId,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      // Get file metadata (including name)
      final metadataUri =
          Uri.parse('$_driveApiBaseUrl/files/$fileId?fields=name');
      final metadataResponse = await http.get(metadataUri, headers: headers);

      // Get file content
      final contentUri = Uri.parse('$_driveApiBaseUrl/files/$fileId?alt=media');
      final contentResponse = await http.get(contentUri, headers: headers);

      if (metadataResponse.statusCode == 200 &&
          contentResponse.statusCode == 200) {
        final metadata = json.decode(metadataResponse.body);
        return {
          'name': metadata['name'],
          'content': contentResponse.body,
        };
      }
      return {'name': null, 'content': null};
    } catch (e) {
      print('Error reading file from Drive: $e');
      return {'name': null, 'content': null};
    }
  }

  // List files
  Future<List<Map<String, String>>> listFiles({
    required String accessToken,
    String? query,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      var uri = Uri.parse(
          '$_driveApiBaseUrl/files?spaces=drive&fields=files(id,name)');
      if (query != null) {
        uri = Uri.parse(
            '$_driveApiBaseUrl/files?spaces=drive&fields=files(id,name)&q=$query');
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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
      print('Error listing files from Drive: $e');
      return [];
    }
  }

  // Delete a file
  Future<bool> deleteFile({
    required String accessToken,
    required String fileId,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      final uri = Uri.parse('$_driveApiBaseUrl/files/$fileId');
      final response = await http.delete(uri, headers: headers);

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting file from Drive: $e');
      return false;
    }
  }

  // Modified readFileByName to search in app folder
  Future<Map<String, String?>> readFileByName({
    required String accessToken,
    required String fileName,
  }) async {
    try {
      final folderId = await _getOrCreateAppFolder(accessToken);
      if (folderId == null) {
        throw Exception('Failed to find app folder');
      }

      // Search for file in the app folder
      final files = await listFiles(
        accessToken: accessToken,
        query: "name = '$fileName' and '${folderId}' in parents",
      );

      if (files.isEmpty) {
        return {'name': null, 'content': null};
      }

      return await readFile(
        accessToken: accessToken,
        fileId: files.first['id']!,
      );
    } catch (e) {
      print('Error reading file by name from Drive: $e');
      return {'name': null, 'content': null};
    }
  }

  logout({required String accessToken}) async {
    try {
      // Revoke access token to properly logout from Google
      final uri = Uri.parse('https://accounts.google.com/o/oauth2/revoke?token=$accessToken');
      await http.get(uri);
    } catch (e) {
      print('Error revoking access token: $e');
    }
  }
}
