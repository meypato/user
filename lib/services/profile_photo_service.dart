import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../configs/bunny_config.dart';
import 'bunny_storage_service.dart';

class ProfilePhotoService {
  /// Upload profile photo for user
  static Future<String?> uploadProfilePhoto({
    required File imageFile,
    required String userId,
    String? currentPhotoUrl,
  }) async {
    try {
      // Validate image file
      if (!BunnyStorageService.validateFile(imageFile, fileType: 'image')) {
        throw Exception('Invalid image file');
      }

      // Get storage path for user
      final storagePath = BunnyConfig.getUserPhotoPath(userId);

      // Generate filename with user ID prefix for easy identification
      final extension = imageFile.path.split('.').last.toLowerCase();
      final filename =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Replace existing photo (this will upload new and delete old)
      final photoUrl = await BunnyStorageService.replaceFile(
        newFile: imageFile,
        storagePath: storagePath,
        oldFileUrl: currentPhotoUrl,
        customFilename: filename,
      );

      return photoUrl;
    } catch (e) {
      return null;
    }
  }

  /// Upload profile photo for user (mobile version with XFile)
  static Future<String?> uploadProfilePhotoMobile({
    required XFile imageFile,
    required String userId,
    String? currentPhotoUrl,
  }) async {
    try {
      // Validate image file
      if (!await BunnyStorageService.validateXFile(
        imageFile,
        fileType: 'image',
      )) {
        throw Exception('Invalid image file');
      }

      // Get storage path for user
      final storagePath = BunnyConfig.getUserPhotoPath(userId);

      // Generate filename with user ID prefix for easy identification
      final extension = imageFile.name.split('.').last.toLowerCase();
      final filename =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Replace existing photo (upload new and delete old)
      final photoUrl = await BunnyStorageService.replaceXFile(
        newFile: imageFile,
        storagePath: storagePath,
        oldFileUrl: currentPhotoUrl,
        customFilename: filename,
      );

      return photoUrl;
    } catch (e) {
      return null;
    }
  }

  /// Remove profile photo for user
  static Future<bool> removeProfilePhoto({
    required String userId,
    required String currentPhotoUrl,
  }) async {
    try {
      if (currentPhotoUrl.isEmpty) return true;

      return await BunnyStorageService.deleteFile(currentPhotoUrl);
    } catch (e) {
      return false;
    }
  }

  /// Update profile photo (replace existing)
  static Future<String?> updateProfilePhoto({
    required File newImageFile,
    required String userId,
    String? oldPhotoUrl,
  }) async {
    return await uploadProfilePhoto(
      imageFile: newImageFile,
      userId: userId,
      currentPhotoUrl: oldPhotoUrl,
    );
  }

  /// Update profile photo (replace existing) - mobile version
  static Future<String?> updateProfilePhotoMobile({
    required XFile newImageFile,
    required String userId,
    String? oldPhotoUrl,
  }) async {
    return await uploadProfilePhotoMobile(
      imageFile: newImageFile,
      userId: userId,
      currentPhotoUrl: oldPhotoUrl,
    );
  }

  /// Check if user has profile photo
  static Future<bool> hasProfilePhoto(String? photoUrl) async {
    if (photoUrl == null || photoUrl.isEmpty) return false;
    return await BunnyStorageService.fileExists(photoUrl);
  }

  /// Get optimized image URL for display
  static String? getDisplayUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    return photoUrl;
  }

  /// Validate image file specifically for profile photos
  static bool validateProfileImage(File imageFile) {
    try {
      // Basic file validation
      if (!BunnyStorageService.validateFile(imageFile, fileType: 'image')) {
        return false;
      }

      // Additional validation for profile photos
      final fileSize = imageFile.lengthSync();

      // Profile photos should be reasonably sized (max 2MB for profiles)
      const maxProfileImageSize = 2 * 1024 * 1024; // 2MB
      if (fileSize > maxProfileImageSize) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate XFile specifically for profile photos (mobile version)
  static Future<bool> validateProfileImageMobile(XFile imageFile) async {
    try {
      // Basic file validation
      if (!await BunnyStorageService.validateXFile(
        imageFile,
        fileType: 'image',
      )) {
        return false;
      }

      // Additional validation for profile photos
      final fileSize = await imageFile.length();

      // Profile photos should be reasonably sized (max 2MB for profiles)
      const maxProfileImageSize = 2 * 1024 * 1024; // 2MB
      if (fileSize > maxProfileImageSize) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clean up all profile photos for a user (useful when deleting user)
  static Future<void> cleanupUserPhotos(String userId, String? photoUrl) async {
    try {
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await BunnyStorageService.cleanupFiles([photoUrl]);
      }
    } catch (e) {
      // Handle cleanup error silently
    }
  }

  /// Get file size for display purposes
  static Future<String?> getFileSizeDisplay(String? photoUrl) async {
    if (photoUrl == null || photoUrl.isEmpty) return null;

    try {
      final fileInfo = BunnyStorageService.getFileInfo(photoUrl);
      if (fileInfo == null) return null;

      // For display purposes, we can't get the actual size from URL
      // This would need to be stored in database or fetched differently
      return 'Photo';
    } catch (e) {
      return null;
    }
  }

  /// Check if photo URL is valid Bunny.net URL
  static bool isValidPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return false;
    return photoUrl.startsWith(BunnyConfig.pullZoneUrl);
  }

  /// Get file extension from photo URL
  static String? getFileExtension(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;

    try {
      final fileInfo = BunnyStorageService.getFileInfo(photoUrl);
      return fileInfo?['extension'];
    } catch (e) {
      return null;
    }
  }

  /// Generate thumbnail URL (if Bunny.net supports image transformation)
  static String? getThumbnailUrl(String? photoUrl, {int width = 150, int height = 150}) {
    if (photoUrl == null || photoUrl.isEmpty) return null;

    // Basic implementation - Bunny.net may support query parameters for resizing
    // Check Bunny.net documentation for actual thumbnail/resize parameters
    return photoUrl; // Return original for now
  }
}