import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'profile_photo_service.dart';
import 'profile_document_service.dart';

class ProfileService {
  static final _supabase = Supabase.instance.client;
  
  // Get current user's profile
  static Future<Profile?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;
      
      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Create a new profile
  static Future<Profile> createProfile({
    required String fullName,
    required String email,
    required String phone,
    required String stateId,
    required String cityId,
    int? age,
    SexType? sex,
    String? addressLine1,
    String? addressLine2,
    String? pincode,
    String? professionId,
    String? tribeId,
    APSTStatus? apst,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final profileData = {
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'state_id': stateId,
        'city_id': cityId,
        'age': age,
        'sex': sex?.name,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'pincode': pincode,
        'profession_id': professionId,
        'tribe_id': tribeId,
        'apst': apst?.databaseValue,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'role': 'tenant',
        'country': 'India',
        'is_verified': false,
        'verification_state': 'unverified',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('ProfileService create error: $e'); // Debug logging
      throw Exception('Failed to create profile: $e');
    }
  }

  // Update existing profile
  static Future<Profile> updateProfile({
    required String profileId,
    String? fullName,
    String? phone,
    int? age,
    SexType? sex,
    String? addressLine1,
    String? addressLine2,
    String? pincode,
    String? stateId,
    String? cityId,
    String? professionId,
    String? tribeId,
    APSTStatus? apst,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (age != null) updateData['age'] = age;
      if (sex != null) updateData['sex'] = sex.name;
      if (addressLine1 != null) updateData['address_line1'] = addressLine1;
      if (addressLine2 != null) updateData['address_line2'] = addressLine2;
      if (pincode != null) updateData['pincode'] = pincode;
      if (stateId != null) updateData['state_id'] = stateId;
      if (cityId != null) updateData['city_id'] = cityId;
      if (professionId != null) updateData['profession_id'] = professionId;
      if (tribeId != null) updateData['tribe_id'] = tribeId;
      if (apst != null) updateData['apst'] = apst.databaseValue;
      if (emergencyContactName != null) updateData['emergency_contact_name'] = emergencyContactName;
      if (emergencyContactPhone != null) updateData['emergency_contact_phone'] = emergencyContactPhone;

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', profileId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('ProfileService update error: $e'); // Debug logging
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile photo using Bunny.net
  static Future<String?> updateProfilePhoto({
    required String userId,
    required File imageFile,
    String? currentPhotoUrl,
  }) async {
    try {
      final photoUrl = await ProfilePhotoService.uploadProfilePhoto(
        imageFile: imageFile,
        userId: userId,
        currentPhotoUrl: currentPhotoUrl,
      );

      if (photoUrl != null) {
        // Update database with new photo URL
        await _supabase
            .from('profiles')
            .update({
              'photo_url': photoUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to update profile photo: $e');
    }
  }

  // Upload profile photo using XFile (for mobile image picker)
  static Future<String?> updateProfilePhotoMobile({
    required String userId,
    required XFile imageFile,
    String? currentPhotoUrl,
  }) async {
    try {
      final photoUrl = await ProfilePhotoService.uploadProfilePhotoMobile(
        imageFile: imageFile,
        userId: userId,
        currentPhotoUrl: currentPhotoUrl,
      );

      if (photoUrl != null) {
        // Update database with new photo URL
        await _supabase
            .from('profiles')
            .update({
              'photo_url': photoUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to update profile photo: $e');
    }
  }

  // Remove profile photo
  static Future<bool> removeProfilePhoto({
    required String userId,
    required String photoUrl,
  }) async {
    try {
      final success = await ProfilePhotoService.removeProfilePhoto(
        userId: userId,
        currentPhotoUrl: photoUrl,
      );

      if (success) {
        // Update database to remove photo URL
        await _supabase
            .from('profiles')
            .update({
              'photo_url': null,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Upload identification document using Bunny.net
  static Future<String?> updateIdentificationDocument({
    required String userId,
    required File documentFile,
    String? currentDocumentUrl,
  }) async {
    try {
      final documentUrl = await ProfileDocumentService.uploadProfileDocument(
        documentFile: documentFile,
        userId: userId,
        documentType: DocumentType.identification,
        currentDocumentUrl: currentDocumentUrl,
      );

      if (documentUrl != null) {
        // Update database with new document URL
        await _supabase
            .from('profiles')
            .update({
              'identification_file_url': documentUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return documentUrl;
    } catch (e) {
      throw Exception('Failed to update identification document: $e');
    }
  }

  // Upload police verification document using Bunny.net
  static Future<String?> updatePoliceVerificationDocument({
    required String userId,
    required File documentFile,
    String? currentDocumentUrl,
  }) async {
    try {
      final documentUrl = await ProfileDocumentService.uploadProfileDocument(
        documentFile: documentFile,
        userId: userId,
        documentType: DocumentType.policeVerification,
        currentDocumentUrl: currentDocumentUrl,
      );

      if (documentUrl != null) {
        // Update database with new document URL
        await _supabase
            .from('profiles')
            .update({
              'police_verification_file_url': documentUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return documentUrl;
    } catch (e) {
      throw Exception('Failed to update police verification document: $e');
    }
  }

  // Remove identification document
  static Future<bool> removeIdentificationDocument({
    required String userId,
    required String documentUrl,
  }) async {
    try {
      final success = await ProfileDocumentService.removeProfileDocument(
        userId: userId,
        currentDocumentUrl: documentUrl,
      );

      if (success) {
        // Update database to remove document URL
        await _supabase
            .from('profiles')
            .update({
              'identification_file_url': null,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Remove police verification document
  static Future<bool> removePoliceVerificationDocument({
    required String userId,
    required String documentUrl,
  }) async {
    try {
      final success = await ProfileDocumentService.removeProfileDocument(
        userId: userId,
        currentDocumentUrl: documentUrl,
      );

      if (success) {
        // Update database to remove document URL
        await _supabase
            .from('profiles')
            .update({
              'police_verification_file_url': null,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Complete cleanup when deleting user profile
  static Future<void> cleanupUserFiles({
    required String userId,
    String? photoUrl,
    String? identificationUrl,
    String? policeVerificationUrl,
  }) async {
    try {
      // Cleanup profile photo
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await ProfilePhotoService.cleanupUserPhotos(userId, photoUrl);
      }

      // Cleanup profile documents
      await ProfileDocumentService.cleanupUserDocuments(
        userId,
        identificationUrl: identificationUrl,
        policeVerificationUrl: policeVerificationUrl,
      );
    } catch (e) {
      // Handle cleanup errors silently
    }
  }

  // Get all states
  static Future<List<State>> getStates() async {
    try {
      final response = await _supabase
          .from('states')
          .select()
          .order('name', ascending: true);

      return response.map<State>((json) => State.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch states: $e');
    }
  }

  // Get cities by state
  static Future<List<City>> getCitiesByState(String stateId) async {
    try {
      final response = await _supabase
          .from('cities')
          .select()
          .eq('state_id', stateId)
          .order('name', ascending: true);

      return response.map<City>((json) => City.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch cities: $e');
    }
  }

  // Get all professions
  static Future<List<Profession>> getProfessions() async {
    try {
      final response = await _supabase
          .from('professions')
          .select()
          .order('name', ascending: true);

      return response.map<Profession>((json) => Profession.fromJson(json)).toList();
    } catch (e) {
      print('ProfileService professions error: $e'); // Debug
      throw Exception('Failed to fetch professions: $e');
    }
  }

  // Get all tribes
  static Future<List<Tribe>> getTribes() async {
    try {
      final response = await _supabase
          .from('tribes')
          .select()
          .order('name', ascending: true);

      return response.map<Tribe>((json) => Tribe.fromJson(json)).toList();
    } catch (e) {
      print('ProfileService tribes error: $e'); // Debug
      throw Exception('Failed to fetch tribes: $e');
    }
  }

  // Check if profile is complete
  static bool isProfileComplete(Profile profile) {
    return profile.hasCompleteProfile;
  }

  // Check if user can rent (complete profile + verified)
  static bool canUserRent(Profile profile) {
    return profile.canRent;
  }

  // Get verification status display text
  static String getVerificationStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.unverified:
        return 'Not Verified';
      case VerificationStatus.pending:
        return 'Verification Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Verification Rejected';
    }
  }

  // Get verification status color
  static String getVerificationStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.unverified:
        return 'gray';
      case VerificationStatus.pending:
        return 'orange';
      case VerificationStatus.verified:
        return 'green';
      case VerificationStatus.rejected:
        return 'red';
    }
  }
}