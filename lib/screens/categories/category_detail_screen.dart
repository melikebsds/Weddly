import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
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

  /// Görevleri alt kategoriye göre gruplar; sırayı ilk görüldükleri sıraya göre korur.
  /// Alt kategorisi olmayan görevler en sonda tek grup halinde gösterilir.
  Map<String?, List<WeddingTask>> _groupBySubCategory(List<WeddingTask> tasks) {
    final grouped = <String?, List<WeddingTask>>{};
    for (final task in tasks) {
      grouped.putIfAbsent(task.subCategory, () => []).add(task);
    }
    if (grouped.containsKey(null)) {
      final withoutSubCategory = grouped.remove(null)!;
      grouped[null] = withoutSubCategory;
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeddingState>();
    final tasks = state.tasksForCategory(category.id);
    final grouped = _groupBySubCategory(tasks);

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: tasks.isEmpty
          ? const Center(child: Text('Bu kategoride henüz görev yok.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in grouped.entries) ...[
                  if (entry.key != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        entry.key!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  for (final task in entry.value)
                    TaskListTile(
                      task: task,
                      onStatusChanged: (status) =>
                          _handle(context, () => state.setTaskStatus(task, status)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskFormScreen(category: category, task: task),
                        ),
                      ),
                      onDelete: () => _handle(context, () => state.deleteTask(task)),
                    ),
                ],
              ],
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
