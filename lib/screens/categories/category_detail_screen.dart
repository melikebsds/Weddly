import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/wedding_task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_state.dart';
import '../../widgets/task_list_tile.dart';
import '../tasks/task_form_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final WeddingCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  Future<void> _handle(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeddingState>();
    final tasks = state.tasksForCategory(category.id);

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: tasks.isEmpty
          ? const Center(child: Text('Bu kategoride henüz görev yok.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final WeddingTask task = tasks[index];
                return TaskListTile(
                  task: task,
                  onToggle: () => _handle(context, () => state.toggleCompleted(task)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskFormScreen(category: category, task: task),
                    ),
                  ),
                  onDelete: () => _handle(context, () => state.deleteTask(task)),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskFormScreen(category: category),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
