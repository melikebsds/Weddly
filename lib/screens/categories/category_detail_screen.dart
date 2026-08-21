import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/task_export.dart';
import '../../models/category.dart';
import '../../models/wedding_task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_state.dart';
import '../../widgets/task_list_tile.dart';
import '../tasks/task_form_screen.dart';

enum _TaskFilter { all, toBuy, bought }

class CategoryDetailScreen extends StatefulWidget {
  final WeddingCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _TaskFilter _filter = _TaskFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handle(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  List<WeddingTask> _applyFilters(List<WeddingTask> tasks) {
    var filtered = tasks;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) => t.title.toLowerCase().contains(query)).toList();
    }

    switch (_filter) {
      case _TaskFilter.all:
        break;
      case _TaskFilter.toBuy:
        filtered = filtered.where((t) => t.status == WeddingTaskStatus.toBuy).toList();
        break;
      case _TaskFilter.bought:
        filtered = filtered.where((t) => t.status == WeddingTaskStatus.bought).toList();
        break;
    }

    return filtered;
  }

  /// Görevleri alt kategoriye göre gruplar; sırayı ilk görüldükleri sıraya göre korur.
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
    final allTasks = state.tasksForCategory(widget.category.id);
    final filtered = _applyFilters(allTasks);
    final grouped = _groupBySubCategory(filtered);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share),
            onSelected: (value) {
              if (value == 'text') {
                TaskExport.shareAsText(widget.category.name, allTasks);
              } else if (value == 'pdf') {
                TaskExport.shareAsPdf(widget.category.name, allTasks);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'text', child: Text('Metin olarak paylaş')),
              PopupMenuItem(value: 'pdf', child: Text('PDF olarak paylaş')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tümü'),
                  selected: _filter == _TaskFilter.all,
                  onSelected: (_) => setState(() => _filter = _TaskFilter.all),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Alınacaklar'),
                  selected: _filter == _TaskFilter.toBuy,
                  onSelected: (_) => setState(() => _filter = _TaskFilter.toBuy),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tamamlananlar'),
                  selected: _filter == _TaskFilter.bought,
                  onSelected: (_) => setState(() => _filter = _TaskFilter.bought),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Görev bulunamadı.'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          Dismissible(
                            key: ValueKey(task.id),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                final newStatus = task.status == WeddingTaskStatus.bought
                                    ? WeddingTaskStatus.toBuy
                                    : WeddingTaskStatus.bought;
                                await _handle(() => state.setTaskStatus(task, newStatus));
                                return false;
                              }

                              return await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Görevi sil'),
                                      content: Text('"${task.title}" silinsin mi?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(false),
                                          child: const Text('Vazgeç'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(true),
                                          child: const Text('Sil'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (direction) {
                              _handle(() => state.deleteTask(task));
                            },
                            child: TaskListTile(
                              task: task,
                              onStatusChanged: (status) =>
                                  _handle(() => state.setTaskStatus(task, status)),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskFormScreen(category: widget.category, task: task),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskFormScreen(category: widget.category),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
