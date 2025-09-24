class BunnyConfig {
  // Storage Zone Configuration
  static const String storageZone = 'meypato'; // Replace with your actual storage zone name
  static const String accessKey = 'c63030f4-e9a2-481f-a1d6da64308f-9948-46ae'; // Replace with your actual access key
  static const String pullZoneUrl = 'https://meypato.b-cdn.net'; // Replace with your actual pull zone URL

  // Storage endpoint (using standard endpoint)
  static const String storageEndpoint = 'storage.bunnycdn.com';

  // File size limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  // Allowed file extensions
  static const List<String> allowedImageTypes = [
    'jpg', 'jpeg', 'png', 'webp', 'avif', 'heic', 'heif', 'bmp', 'gif', 'svg', 'tiff', 'tif'
  ];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'jpg', 'jpeg', 'png', 'webp', 'avif', 'heic', 'heif', 'bmp', 'gif', 'svg', 'tiff', 'tif'
  ];

  // Storage paths for profile files
  static const String profilePhotosPath = 'profiles/photos/';
  static const String profileDocumentsPath = 'profiles/documents/';

  // Generated URLs
  static String get storageUrl => 'https://$storageEndpoint/$storageZone/';

  // Get public file URL for accessing files
  static String getFileUrl(String filePath) {
    return '$pullZoneUrl/$filePath';
  }

  // Get upload URL for API calls
  static String getUploadUrl(String filePath) {
    return '$storageUrl$filePath';
  }

  // Helper methods for profile storage paths
  static String getUserPhotoPath(String userId) => '$profilePhotosPath$userId/';
  static String getUserDocumentPath(String userId) => '$profileDocumentsPath$userId/';
}