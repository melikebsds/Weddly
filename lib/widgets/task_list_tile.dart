import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/wedding_task.dart';

class TaskListTile extends StatelessWidget {
  final WeddingTask task;
  final ValueChanged<WeddingTaskStatus> onStatusChanged;
  final VoidCallback onTap;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onStatusChanged,
    required this.onTap,
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

  Future<void> _openProductUrl() async {
    final url = task.productUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
            if (task.responsibleParty != ResponsibleParty.unspecified)
              Text(
                'Sorumlu: ${task.responsibleParty.label}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            if (task.status == WeddingTaskStatus.notNeeded)
              const Text('İhtiyaç yok olarak işaretlendi',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
        trailing: (task.productUrl != null && task.productUrl!.isNotEmpty)
            ? IconButton(
                icon: const Icon(Icons.link, color: AppColors.primary),
                onPressed: _openProductUrl,
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}
