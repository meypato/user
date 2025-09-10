# Bunny.net Storage for Flutter - Implementation Guide

**Quick implementation guide for Bunny.net Storage in Flutter projects.**

## Dependencies

```yaml
dependencies:
  http: ^1.1.0
  path: ^1.8.3
```

## Setup

### 1. Configuration

`lib/config/bunny_config.dart`:

```dart
class BunnyConfig {
  static const String region = 'sg'; // asia region
  static const String storageZone = 'your-storage-zone';
  static const String accessKey = 'your-access-key';
  static const String pullZoneUrl = 'https://your-zone.b-cdn.net';
  
  static String get storageUrl => 'https://$region.storage.bunnycdn.com/$storageZone/';
  static String getFileUrl(String path) => '$pullZoneUrl/$path';
  static String getUploadUrl(String path) => '$storageUrl$path';
}
```

### 2. Storage Service

`lib/services/bunny_storage_service.dart`:

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../config/bunny_config.dart';

class BunnyStorageService {
  
  // Upload file
  static Future<String?> uploadFile(File file, String storagePath) async {
    try {
      final filename = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final filePath = '$storagePath$filename';
      final uploadUrl = BunnyConfig.getUploadUrl(filePath);
      
      final request = http.Request('PUT', Uri.parse(uploadUrl));
      request.headers['AccessKey'] = BunnyConfig.accessKey;
      request.headers['Content-Type'] = 'application/octet-stream';
      request.bodyBytes = await file.readAsBytes();
      
      final response = await request.send();
      
      if (response.statusCode == 201) {
        return BunnyConfig.getFileUrl(filePath);
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
  
  // Delete file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final deleteUrl = BunnyConfig.getUploadUrl(filePath);
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {'AccessKey': BunnyConfig.accessKey},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### 3. Upload Widget

`lib/widgets/file_upload_widget.dart`:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/bunny_storage_service.dart';

class FileUploadWidget extends StatefulWidget {
  final String storagePath;
  final Function(String?) onUploaded;
  final String? currentUrl;
  
  const FileUploadWidget({
    Key? key,
    required this.storagePath,
    required this.onUploaded,
    this.currentUrl,
  }) : super(key: key);
  
  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _uploading = false;
  String? _fileUrl;
  
  @override
  void initState() {
    super.initState();
    _fileUrl = widget.currentUrl;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _uploading ? null : _pickFile,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _uploading
                ? const Center(child: CircularProgressIndicator())
                : _fileUrl != null
                    ? const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 48))
                    : const Center(child: Icon(Icons.upload, size: 48)),
          ),
        ),
        if (_fileUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('File uploaded', style: TextStyle(color: Colors.green)),
          ),
      ],
    );
  }
  
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result?.files.single.path != null) {
      setState(() => _uploading = true);
      
      final file = File(result!.files.single.path!);
      final url = await BunnyStorageService.uploadFile(file, widget.storagePath);
      
      setState(() {
        _uploading = false;
        _fileUrl = url;
      });
      
      widget.onUploaded(url);
    }
  }
}
```

## Usage Examples

### Profile Image Upload

```dart
FileUploadWidget(
  storagePath: 'profiles/$userId/',
  onUploaded: (url) {
    if (url != null) {
      // Update profile in database
      updateProfileImage(url);
    }
  },
)
```

### Document Upload

```dart
FileUploadWidget(
  storagePath: 'documents/$userId/',
  currentUrl: user.documentUrl,
  onUploaded: (url) {
    setState(() {
      user.documentUrl = url;
    });
  },
)
```

### Display Images

```dart
// Show uploaded image
Image.network(
  imageUrl,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error);
  },
)

// Profile avatar
CircleAvatar(
  backgroundImage: user.photoUrl != null 
    ? NetworkImage(user.photoUrl!) 
    : null,
  child: user.photoUrl == null 
    ? Icon(Icons.person) 
    : null,
)
```

## Storage Paths

```dart
class StoragePaths {
  static String userProfile(String userId) => 'profiles/$userId/';
  static String userDocs(String userId) => 'documents/$userId/';
  static String buildingPhotos(String buildingId) => 'buildings/$buildingId/';
  static String reviewPhotos(String reviewId) => 'reviews/$reviewId/';
  static String agreements(String subscriptionId) => 'agreements/$subscriptionId/';
}
```

## File Validation

```dart
class FileValidator {
  static bool isValidImage(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png'].contains(extension);
  }
  
  static bool isValidSize(File file, int maxBytes) {
    return file.lengthSync() <= maxBytes;
  }
  
  static bool isValidDocument(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.pdf', '.doc', '.docx'].contains(extension);
  }
}
```

## Quick Setup Checklist

1. **Create Bunny.net account**
2. **Create Storage Zone** (note the name and region)
3. **Create Pull Zone** (connect to storage zone)
4. **Get Access Key** (from Storage Zone → FTP & API Access)
5. **Update BunnyConfig** with your credentials
6. **Add dependencies** to pubspec.yaml
7. **Implement BunnyStorageService**
8. **Use FileUploadWidget** in your forms

## Common Patterns

### Multiple File Upload

```dart
Future<List<String>> uploadMultipleFiles(List<File> files, String path) async {
  final urls = <String>[];
  for (final file in files) {
    final url = await BunnyStorageService.uploadFile(file, path);
    if (url != null) urls.add(url);
  }
  return urls;
}
```

### Replace File

```dart
Future<String?> replaceFile(String oldUrl, File newFile, String path) async {
  final newUrl = await BunnyStorageService.uploadFile(newFile, path);
  if (newUrl != null && oldUrl.isNotEmpty) {
    // Extract file path from old URL and delete
    final oldPath = oldUrl.replaceFirst(BunnyConfig.pullZoneUrl + '/', '');
    await BunnyStorageService.deleteFile(oldPath);
  }
  return newUrl;
}
```

That's it! Simple and focused implementation for Bunny.net Storage in Flutter.