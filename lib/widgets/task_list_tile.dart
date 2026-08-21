import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/wedding_task.dart';

class TaskListTile extends StatelessWidget {
  final WeddingTask task;
  final ValueChanged<WeddingTaskStatus> onStatusChanged;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onStatusChanged,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor(WeddingTaskStatus status) => switch (status) {
        WeddingTaskStatus.toBuy => AppColors.textMuted,
        WeddingTaskStatus.bought => AppColors.success,
        WeddingTaskStatus.notNeeded => AppColors.textMuted,
      };

  IconData _statusIcon(WeddingTaskStatus status) => switch (status) {
        WeddingTaskStatus.toBuy => Icons.radio_button_unchecked,
        WeddingTaskStatus.bought => Icons.check_circle,
        WeddingTaskStatus.notNeeded => Icons.block,
      };

  bool get _isDimmed => task.status != WeddingTaskStatus.toBuy;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: PopupMenuButton<WeddingTaskStatus>(
          initialValue: task.status,
          onSelected: onStatusChanged,
          icon: Icon(_statusIcon(task.status), color: _statusColor(task.status)),
          itemBuilder: (context) => WeddingTaskStatus.values
              .map((status) => PopupMenuItem(value: status, child: Text(status.label)))
              .toList(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: _isDimmed ? TextDecoration.lineThrough : null,
            color: _isDimmed ? AppColors.textMuted : AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tahmini: ${formatCurrency(task.estimatedPrice)}'),
            if (task.actualPrice != null)
              Text('Gerçek: ${formatCurrency(task.actualPrice)}'),
            if (task.status == WeddingTaskStatus.notNeeded)
              const Text('İhtiyaç yok olarak işaretlendi',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
          onPressed: onDelete,
        ),
        isThreeLine: true,
      ),
    );
  }
}
