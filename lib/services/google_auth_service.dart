import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A service class to handle Google Sign-In with Supabase
class GoogleAuthService {
  // Singleton instance
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  // Get the Supabase client
  final _supabase = Supabase.instance.client;

  /// Perform Google Sign-In and authenticate with Supabase
  /// Returns the AuthResponse if successful
  Future<AuthResponse> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In process');
      
      // Web Client ID (required for server verification)
      const webClientId = '982499423703-dovj0elsdsnlimn4evt51d94a5ncv4ia.apps.googleusercontent.com';
      
      // Create GoogleSignIn instance with the web client ID
      // Following the same pattern as Kaku app
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );
      
      // Sign out first to ensure the account picker is shown
      await googleSignIn.signOut();
      
      // Start the sign-in process
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In was cancelled by the user';
      }
      
      // Get authentication details
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      // Validate tokens
      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }
      
      debugPrint('Google authentication successful, signing in with Supabase');
      
      // Sign in with Supabase using the Google ID token
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      rethrow;
    }
  }
  
  /// Sign out from both Supabase and Google
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
  
  /// Check if a user has a complete profile
  /// Returns true if the user has completed their profile setup
  Future<bool> hasCompleteProfile(User? user) async {
    if (user == null) return false;
    
    try {
      debugPrint('🔍 Checking if user ${user.id} has complete profile');
      // Query the profiles table to check profile completion
      final response = await _supabase
          .from('profiles')
          .select('full_name, phone')
          .eq('id', user.id)
          .maybeSingle();
      
      // If no profile exists, user needs to complete profile
      if (response == null) {
        debugPrint('⚠️ No profile found for user ${user.id}');
        return false;
      }
      
      final fullName = response['full_name'] as String?;
      final phone = response['phone'] as String?;
      
      debugPrint('📋 User ${user.id} profile - Name: $fullName, Phone: $phone');
      
      // Check if essential profile fields are filled
      return fullName != null && 
             fullName.isNotEmpty && 
             phone != null && 
             phone.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking profile completion: $e');
      return false;
    }
  }
  
  /// Create or update user profile after Google Sign-In
  Future<void> createOrUpdateProfile(User user, {
    String? fullName,
    String? phone,
  }) async {
    try {
      debugPrint('💾 Creating/updating profile for user ${user.id}');
      
      // First check if the profile exists
      final profileExists = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      
      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName ?? user.userMetadata?['full_name'] ?? user.email?.split('@').first,
        'phone': phone,
        'avatar_url': user.userMetadata?['picture'],
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (profileExists == null) {
        // Create new profile
        profileData['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from('profiles').insert(profileData);
        debugPrint('✅ Created new profile for user ${user.id}');
      } else {
        // Update existing profile (only if new data provided)
        final updateData = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
        if (fullName != null) updateData['full_name'] = fullName;
        if (phone != null) updateData['phone'] = phone;
        
        await _supabase.from('profiles').update(updateData).eq('id', user.id);
        debugPrint('✅ Updated profile for user ${user.id}');
      }
    } catch (e) {
      debugPrint('❌ Error creating/updating profile: $e');
      rethrow;
    }
  }
}