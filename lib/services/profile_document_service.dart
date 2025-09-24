import 'dart:io';
import '../configs/bunny_config.dart';
import 'bunny_storage_service.dart';

enum DocumentType { identification, policeVerification }

extension DocumentTypeExtension on DocumentType {
  String get name {
    switch (this) {
      case DocumentType.identification:
        return 'identification';
      case DocumentType.policeVerification:
        return 'police_verification';
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.identification:
        return 'Identification Document';
      case DocumentType.policeVerification:
        return 'Police Verification Certificate';
    }
  }

  String get description {
    switch (this) {
      case DocumentType.identification:
        return 'Upload a government-issued ID (Aadhaar, PAN, Passport, Driver\'s License)';
      case DocumentType.policeVerification:
        return 'Upload police verification certificate for rental eligibility';
    }
  }
}

class ProfileDocumentService {
  /// Upload profile document for user
  static Future<String?> uploadProfileDocument({
    required File documentFile,
    required String userId,
    required DocumentType documentType,
    String? currentDocumentUrl,
  }) async {
    try {
      // Validate document file
      if (!BunnyStorageService.validateFile(
        documentFile,
        fileType: 'document',
      )) {
        throw Exception('Invalid document file');
      }

      // Get storage path for user documents
      final storagePath = BunnyConfig.getUserDocumentPath(userId);

      // Generate filename with document type and user ID prefix
      final extension = documentFile.path.split('.').last.toLowerCase();
      final filename =
          '${documentType.name}_${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Replace existing document (this will upload new and delete old)
      final documentUrl = await BunnyStorageService.replaceFile(
        newFile: documentFile,
        storagePath: storagePath,
        oldFileUrl: currentDocumentUrl,
        customFilename: filename,
      );

      return documentUrl;
    } catch (e) {
      return null;
    }
  }

  /// Remove profile document for user
  static Future<bool> removeProfileDocument({
    required String userId,
    required String currentDocumentUrl,
  }) async {
    try {
      if (currentDocumentUrl.isEmpty) return true;

      return await BunnyStorageService.deleteFile(currentDocumentUrl);
    } catch (e) {
      return false;
    }
  }

  /// Update profile document (replace existing)
  static Future<String?> updateProfileDocument({
    required File newDocumentFile,
    required String userId,
    required DocumentType documentType,
    String? oldDocumentUrl,
  }) async {
    return await uploadProfileDocument(
      documentFile: newDocumentFile,
      userId: userId,
      documentType: documentType,
      currentDocumentUrl: oldDocumentUrl,
    );
  }

  /// Check if user has profile document
  static Future<bool> hasProfileDocument(String? documentUrl) async {
    if (documentUrl == null || documentUrl.isEmpty) return false;
    return await BunnyStorageService.fileExists(documentUrl);
  }

  /// Get document display URL
  static String? getDisplayUrl(String? documentUrl) {
    if (documentUrl == null || documentUrl.isEmpty) return null;
    return documentUrl;
  }

  /// Validate document file specifically for profile documents
  static bool validateProfileDocument(File documentFile) {
    try {
      // Basic file validation
      if (!BunnyStorageService.validateFile(
        documentFile,
        fileType: 'document',
      )) {
        return false;
      }

      // Additional validation for profile documents
      final fileSize = documentFile.lengthSync();

      // Profile documents should be reasonably sized (max 10MB for documents)
      const maxProfileDocumentSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxProfileDocumentSize) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file type from extension for UI display
  static String getFileTypeDisplay(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) return 'Unknown';

    final extension = fileUrl.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'webp':
        return 'WebP Image';
      default:
        return 'Document';
    }
  }

  /// Get appropriate icon for file type (Material Icons)
  static String getFileTypeIcon(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) return 'insert_drive_file';

    final extension = fileUrl.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'doc':
      case 'docx':
        return 'description';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return 'image';
      default:
        return 'insert_drive_file';
    }
  }

  /// Get file size display string
  static Future<String?> getFileSizeDisplay(File documentFile) async {
    try {
      final fileSize = documentFile.lengthSync();
      return BunnyStorageService.formatFileSize(fileSize);
    } catch (e) {
      return null;
    }
  }

  /// Check if document is an image type
  static bool isImageDocument(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) return false;

    final extension = fileUrl.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(extension);
  }

  /// Check if document is a PDF
  static bool isPdfDocument(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) return false;
    return fileUrl.toLowerCase().endsWith('.pdf');
  }

  /// Clean up all profile documents for a user (useful when deleting user)
  static Future<void> cleanupUserDocuments(
    String userId, {
    String? identificationUrl,
    String? policeVerificationUrl,
  }) async {
    try {
      final urlsToClean = <String>[];

      if (identificationUrl != null && identificationUrl.isNotEmpty) {
        urlsToClean.add(identificationUrl);
      }

      if (policeVerificationUrl != null && policeVerificationUrl.isNotEmpty) {
        urlsToClean.add(policeVerificationUrl);
      }

      if (urlsToClean.isNotEmpty) {
        await BunnyStorageService.cleanupFiles(urlsToClean);
      }
    } catch (e) {
      // Handle cleanup error silently
    }
  }

  /// Check if document URL is valid Bunny.net URL
  static bool isValidDocumentUrl(String? documentUrl) {
    if (documentUrl == null || documentUrl.isEmpty) return false;
    return documentUrl.startsWith(BunnyConfig.pullZoneUrl);
  }

  /// Get file name from URL for display
  static String? getFileName(String? documentUrl) {
    if (documentUrl == null || documentUrl.isEmpty) return null;

    try {
      final fileInfo = BunnyStorageService.getFileInfo(documentUrl);
      return fileInfo?['fileName'];
    } catch (e) {
      return null;
    }
  }

  /// Get document type from filename
  static DocumentType? getDocumentTypeFromUrl(String? documentUrl) {
    if (documentUrl == null || documentUrl.isEmpty) return null;

    try {
      final fileName = getFileName(documentUrl);
      if (fileName == null) return null;

      if (fileName.startsWith('identification_')) {
        return DocumentType.identification;
      } else if (fileName.startsWith('police_verification_')) {
        return DocumentType.policeVerification;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validate document file extension
  static bool isValidDocumentExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return BunnyConfig.allowedDocumentTypes.contains(extension);
  }

  /// Get recommended file formats for document type
  static List<String> getRecommendedFormats(DocumentType documentType) {
    switch (documentType) {
      case DocumentType.identification:
        return ['PDF', 'JPG', 'PNG']; // Government IDs are usually scanned images
      case DocumentType.policeVerification:
        return ['PDF', 'JPG', 'PNG']; // Official documents, usually PDF or scanned
    }
  }

  /// Get maximum file size for document type
  static int getMaxFileSize(DocumentType documentType) {
    // All document types use the same max size for now
    return BunnyConfig.maxDocumentSize;
  }

  /// Format file size from bytes to human readable
  static String formatDocumentSize(int bytes) {
    return BunnyStorageService.formatFileSize(bytes);
  }
}