import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

// 1. Provide the ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// 2. Provide the TaskNotifier
final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TaskNotifier(apiService);
});

// 3. The StateNotifier that manages our list of tasks
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiService _apiService;

  TaskNotifier(this._apiService) : super(const AsyncValue.loading()) {
    fetchTasks(); // Load tasks immediately when the app starts
  }

  // Fetch all tasks (with optional search and filter for our stretch goal)
  Future<void> fetchTasks({String? search, String? status}) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _apiService.getTasks(search: search, status: status);
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    // We don't change the main list state to loading here, because we want the 
    // main screen to remain visible. The loading state for creation will be 
    // handled locally in the Create UI, but we update the list once done.
    try {
      final newTask = await _apiService.createTask(task);
      if (state is AsyncData) {
        final currentTasks = state.value!;
        state = AsyncValue.data([...currentTasks, newTask]);
      }
    } catch (e) {
      rethrow; // Throw to the UI so we can show an error Snackbar
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await _apiService.updateTask(task);
      if (state is AsyncData) {
        final currentTasks = state.value!;
        state = AsyncValue.data([
          for (final t in currentTasks)
            if (t.id == updatedTask.id) updatedTask else t
        ]);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(int taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      if (state is AsyncData) {
        final currentTasks = state.value!;
        state = AsyncValue.data(currentTasks.where((t) => t.id != taskId).toList());
      }
    } catch (e) {
      rethrow;
    }
  }
}