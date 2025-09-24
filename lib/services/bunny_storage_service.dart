import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import '../configs/bunny_config.dart';

class BunnyStorageService {
  /// Upload file to Bunny.net Storage
  static Future<String?> uploadFile({
    required File file,
    required String storagePath,
    String? customFilename,
  }) async {
    try {
      // Generate unique filename if not provided
      final filename =
          customFilename ??
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';

      final filePath = '$storagePath$filename';
      final uploadUrl = BunnyConfig.getUploadUrl(filePath);

      // Create PUT request
      final request = http.Request('PUT', Uri.parse(uploadUrl));
      request.headers['AccessKey'] = BunnyConfig.accessKey;
      request.headers['Content-Type'] = 'application/octet-stream';
      request.bodyBytes = await file.readAsBytes();

      // Send request
      final response = await request.send();

      if (response.statusCode == 201) {
        return BunnyConfig.getFileUrl(filePath);
      } else {
        print('Bunny.net upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Bunny.net upload error: $e');
      return null;
    }
  }

  /// Upload XFile to Bunny.net Storage (for mobile image picker compatibility)
  static Future<String?> uploadXFile({
    required XFile file,
    required String storagePath,
    String? customFilename,
  }) async {
    try {
      // Generate unique filename if not provided
      final extension = file.name.split('.').last.toLowerCase();
      final filename =
          customFilename ??
          '${DateTime.now().millisecondsSinceEpoch}.$extension';

      final filePath = '$storagePath$filename';
      final uploadUrl = BunnyConfig.getUploadUrl(filePath);

      // Create PUT request
      final request = http.Request('PUT', Uri.parse(uploadUrl));
      request.headers['AccessKey'] = BunnyConfig.accessKey;
      request.headers['Content-Type'] = 'application/octet-stream';
      request.bodyBytes = await file.readAsBytes();

      // Send request
      final response = await request.send();

      if (response.statusCode == 201) {
        return BunnyConfig.getFileUrl(filePath);
      } else {
        print('Bunny.net XFile upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Bunny.net XFile upload error: $e');
      return null;
    }
  }

  /// Delete file from Bunny.net Storage
  static Future<bool> deleteFile(String fileUrl) async {
    try {
      // Extract file path from URL
      final filePath = _extractFilePathFromUrl(fileUrl);
      if (filePath == null) {
        print('Failed to extract file path from URL: $fileUrl');
        return false;
      }

      final deleteUrl = BunnyConfig.getUploadUrl(filePath);

      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {'AccessKey': BunnyConfig.accessKey},
      );

      if (response.statusCode == 200) {
        print('Successfully deleted file: $filePath');
        return true;
      } else {
        print('Failed to delete file: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Bunny.net delete error: $e');
      return false;
    }
  }

  /// Check if file exists in storage
  static Future<bool> fileExists(String fileUrl) async {
    try {
      final filePath = _extractFilePathFromUrl(fileUrl);
      if (filePath == null) return false;

      final checkUrl = BunnyConfig.getUploadUrl(filePath);

      final response = await http.head(
        Uri.parse(checkUrl),
        headers: {'AccessKey': BunnyConfig.accessKey},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Bunny.net file exists check error: $e');
      return false;
    }
  }

  /// Replace existing file with new one (upload new + delete old atomically)
  static Future<String?> replaceFile({
    required File newFile,
    required String storagePath,
    String? oldFileUrl,
    String? customFilename,
  }) async {
    try {
      // Upload new file first
      final newFileUrl = await uploadFile(
        file: newFile,
        storagePath: storagePath,
        customFilename: customFilename,
      );

      // If upload successful and old file exists, delete old file
      if (newFileUrl != null && oldFileUrl != null && oldFileUrl.isNotEmpty) {
        // Delete old file in background - don't await to avoid blocking
        deleteFile(oldFileUrl).catchError((e) {
          print('Warning: Failed to delete old file during replace: $e');
          return false;
        });
      }

      return newFileUrl;
    } catch (e) {
      print('Bunny.net replace file error: $e');
      return null;
    }
  }

  /// Replace existing file with new XFile (for mobile image picker)
  static Future<String?> replaceXFile({
    required XFile newFile,
    required String storagePath,
    String? oldFileUrl,
    String? customFilename,
  }) async {
    try {
      // Upload new file first
      final newFileUrl = await uploadXFile(
        file: newFile,
        storagePath: storagePath,
        customFilename: customFilename,
      );

      // If upload successful and old file exists, delete old file
      if (newFileUrl != null && oldFileUrl != null && oldFileUrl.isNotEmpty) {
        // Delete old file in background - don't await to avoid blocking
        deleteFile(oldFileUrl).catchError((e) {
          print('Warning: Failed to delete old file during XFile replace: $e');
          return false;
        });
      }

      return newFileUrl;
    } catch (e) {
      print('Bunny.net replace XFile error: $e');
      return null;
    }
  }

  /// Validate file before upload
  static bool validateFile(File file, {required String fileType}) {
    try {
      // Get file size - handle mobile-specific issues
      int fileSize;
      try {
        fileSize = file.lengthSync();
      } catch (e) {
        print('Failed to get file size: $e');
        return false;
      }

      final extension = path.extension(file.path).toLowerCase().substring(1);

      // Validate based on file type
      switch (fileType.toLowerCase()) {
        case 'image':
          if (!BunnyConfig.allowedImageTypes.contains(extension)) {
            print('Invalid image extension: $extension');
            return false;
          }
          if (fileSize > BunnyConfig.maxImageSize) {
            print('Image too large: ${fileSize}bytes > ${BunnyConfig.maxImageSize}bytes');
            return false;
          }
          break;

        case 'document':
          if (!BunnyConfig.allowedDocumentTypes.contains(extension)) {
            print('Invalid document extension: $extension');
            return false;
          }
          if (fileSize > BunnyConfig.maxDocumentSize) {
            print('Document too large: ${fileSize}bytes > ${BunnyConfig.maxDocumentSize}bytes');
            return false;
          }
          break;

        default:
          print('Unknown file type: $fileType');
          return false;
      }

      return true;
    } catch (e) {
      print('File validation error: $e');
      return false;
    }
  }

  /// Validate XFile before upload (for mobile image picker)
  static Future<bool> validateXFile(
    XFile file, {
    required String fileType,
  }) async {
    try {
      final fileSize = await file.length();
      final extension = file.name.split('.').last.toLowerCase();

      // Validate based on file type
      switch (fileType.toLowerCase()) {
        case 'image':
          if (!BunnyConfig.allowedImageTypes.contains(extension)) {
            print('Invalid image extension: $extension');
            return false;
          }
          if (fileSize > BunnyConfig.maxImageSize) {
            print('Image too large: ${fileSize}bytes > ${BunnyConfig.maxImageSize}bytes');
            return false;
          }
          break;

        case 'document':
          if (!BunnyConfig.allowedDocumentTypes.contains(extension)) {
            print('Invalid document extension: $extension');
            return false;
          }
          if (fileSize > BunnyConfig.maxDocumentSize) {
            print('Document too large: ${fileSize}bytes > ${BunnyConfig.maxDocumentSize}bytes');
            return false;
          }
          break;

        default:
          print('Unknown file type: $fileType');
          return false;
      }

      return true;
    } catch (e) {
      print('XFile validation error: $e');
      return false;
    }
  }

  /// Extract file path from public URL
  static String? _extractFilePathFromUrl(String fileUrl) {
    try {
      if (fileUrl.startsWith(BunnyConfig.pullZoneUrl)) {
        return fileUrl.replaceFirst('${BunnyConfig.pullZoneUrl}/', '');
      }
      print('URL does not match pull zone URL pattern: $fileUrl');
      return null;
    } catch (e) {
      print('Error extracting file path from URL: $e');
      return null;
    }
  }

  /// Clean up multiple files (for bulk deletion)
  static Future<void> cleanupFiles(List<String> fileUrls) async {
    final futures = <Future<bool>>[];

    for (final url in fileUrls) {
      if (url.isNotEmpty) {
        futures.add(
          deleteFile(url).catchError((e) {
            print('Failed to cleanup file $url: $e');
            return false;
          })
        );
      }
    }

    // Wait for all deletions to complete
    await Future.wait(futures);
    print('Cleanup completed for ${fileUrls.length} files');
  }

  /// Get file info from URL (useful for UI display)
  static Map<String, dynamic>? getFileInfo(String fileUrl) {
    try {
      final filePath = _extractFilePathFromUrl(fileUrl);
      if (filePath == null) return null;

      final fileName = path.basename(filePath);
      final extension = path.extension(fileName);
      final directory = path.dirname(filePath);

      return {
        'fileName': fileName,
        'extension': extension,
        'directory': directory,
        'fullPath': filePath,
      };
    } catch (e) {
      print('Error getting file info: $e');
      return null;
    }
  }

  /// Get file size in human readable format
  static String formatFileSize(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }
}