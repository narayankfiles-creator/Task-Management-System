import 'dart:convert';
import 'package:flutter/foundation.dart'; // Web-safe platform checking
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS Simulator/Web
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/tasks/';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/tasks/';
    }
    return 'http://127.0.0.1:8000/tasks/';
  }

  // GET: Fetch all tasks (Supports Search & Filter for Stretch Goal 1)
  Future<List<Task>> getTasks({String? search, String? status}) async {
    // Build query parameters
    Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status != 'All') queryParams['status'] = status;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // POST: Create a new task (Backend handles the 2-second delay)
  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  // PUT: Update an existing task (Backend handles the 2-second delay)
  Future<Task> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  // DELETE: Remove a task
  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}