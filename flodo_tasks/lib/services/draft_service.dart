import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static const String _draftKey = 'task_creation_draft';

  // Save the user's current input as a draft
  Future<void> saveDraft({
    required String title,
    required String description,
    DateTime? dueDate,
    String? status,
    int? blockedById,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create a Map of the current input
    final draftData = {
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'status': status,
      'blocked_by_id': blockedById,
    };

    // Convert to JSON and save locally
    await prefs.setString(_draftKey, json.encode(draftData));
  }

  // Retrieve the draft when the user re-opens the Create Screen
  Future<Map<String, dynamic>?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString(_draftKey);
    
    if (draftString != null) {
      return json.decode(draftString) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear the draft once the task is successfully saved to the backend
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}