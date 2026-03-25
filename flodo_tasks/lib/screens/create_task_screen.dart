import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../services/draft_service.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final Task? taskToEdit; // If null, we are creating a new task. If provided, we are editing.
  const CreateTaskScreen({Key? key, this.taskToEdit}) : super(key: key);

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

// WidgetsBindingObserver allows us to detect when the app is minimized
class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'To-Do';
  int? _blockedById;
  
  bool _isLoading = false;
  final _draftService = DraftService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Start listening for app minimize
    
    if (widget.taskToEdit != null) {
      // We are editing an existing task, populate the fields
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _selectedDate = widget.taskToEdit!.dueDate;
      _selectedStatus = widget.taskToEdit!.status;
      _blockedById = widget.taskToEdit!.blockedById;
    } else {
      // We are creating a new task, check for a saved draft!
      _loadDraft();
    }
  }

  Future<void> _loadDraft() async {
    final draft = await _draftService.getDraft();
    if (draft != null && mounted) {
      setState(() {
        _titleController.text = draft['title'] ?? '';
        _descController.text = draft['description'] ?? '';
        if (draft['due_date'] != null) {
          _selectedDate = DateTime.parse(draft['due_date']);
        }
        _selectedStatus = draft['status'] ?? 'To-Do';
        _blockedById = draft['blocked_by_id'];
      });
    }
  }

  // Helper method to save the draft
  void _saveDraft() {
    // Only save draft if we are creating a new task and NOT currently submitting
    if (widget.taskToEdit == null && !_isLoading) {
      _draftService.saveDraft(
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        status: _selectedStatus,
        blockedById: _blockedById,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // REQUIREMENT: Save draft if user accidentally minimizes the app
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveDraft(); 
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // REQUIREMENT: Save draft if user swipes back/closes the screen
    _saveDraft(); 
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    // REQUIREMENT: Disable UI and show loading state
    setState(() => _isLoading = true);

    final task = Task(
      id: widget.taskToEdit?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDate,
      status: _selectedStatus,
      blockedById: _blockedById,
    );

    try {
      if (widget.taskToEdit != null) {
        // Edit existing task
        await ref.read(taskProvider.notifier).updateTask(task);
      } else {
        // Create new task (Backend handles the 2-second delay)
        await ref.read(taskProvider.notifier).addTask(task);
        await _draftService.clearDraft(); // Success! Clear the draft.
      }
      
      if (mounted) {
        Navigator.pop(context); // Go back to the list screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false); // Re-enable UI on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch tasks to populate the "Blocked By" dropdown
    final taskState = ref.watch(taskProvider);
    List<Task> availableTasksToBlock = [];
    
    if (taskState is AsyncData) {
      // Prevent a task from blocking itself
      availableTasksToBlock = taskState.value!.where((t) => t.id != widget.taskToEdit?.id).toList();
    }

    // POLISH: Modern input decoration to keep the UI consistent
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      filled: true,
      fillColor: Colors.white, // Inputs are pure white inside the card
    );

    return Scaffold(
      backgroundColor: Colors.grey[50], // MATCHING THEME: Soft grey background
      appBar: AppBar(
        title: Text(
          widget.taskToEdit == null ? 'Create Task' : 'Edit Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true, // Center the app bar title
      ),
      body: _isLoading 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text('Processing...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          // POLISH: Center and Constrain the width of the form for desktop
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                // NEW: Wrapped the form in a beautiful white floating card!
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true, // Lets the card hug the content so it doesn't stretch infinitely
                      padding: const EdgeInsets.all(32),
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: inputDecoration.copyWith(labelText: 'Title'),
                          validator: (v) => v!.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descController,
                          decoration: inputDecoration.copyWith(labelText: 'Description', alignLabelWithHint: true),
                          maxLines: 4,
                          validator: (v) => v!.isEmpty ? 'Description is required' : null,
                        ),
                        const SizedBox(height: 20),
                        
                        // Due Date Picker
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            trailing: const Icon(Icons.calendar_today, color: Colors.black),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(primary: Colors.black),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: inputDecoration.copyWith(labelText: 'Status'),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                          items: ['To-Do', 'In Progress', 'Done']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedStatus = v!),
                        ),
                        const SizedBox(height: 20),

                        DropdownButtonFormField<int?>(
                          value: _blockedById,
                          decoration: inputDecoration.copyWith(labelText: 'Blocked By (Optional)'),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                          items: [
                            const DropdownMenuItem<int?>(value: null, child: Text('None')),
                            ...availableTasksToBlock.map((t) => DropdownMenuItem(
                              value: t.id, 
                              child: Text(t.title, overflow: TextOverflow.ellipsis),
                            )),
                          ],
                          onChanged: (v) => setState(() => _blockedById = v),
                        ),
                        const SizedBox(height: 40),

                        // Save Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: const Text('Save Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}