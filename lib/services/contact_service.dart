import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ContactService {
  static final _supabase = Supabase.instance.client;

  static Future<Contact?> getActiveContact() async {
    try {
      final response = await _supabase
          .from('contacts')
          .select()
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return Contact.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch contact information: $e');
    }
  }
}