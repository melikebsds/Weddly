import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../providers/wedding_state.dart';
import '../../widgets/section_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeddingState>();
    final estimatedTotal = state.estimatedTotal();
    final actualTotal = state.actualTotal();
    final remaining = estimatedTotal - actualTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçe')),
      body: RefreshIndicator(
        onRefresh: state.reloadAll,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BudgetRow(label: 'Tahmini Toplam', value: formatCurrency(estimatedTotal)),
                const Divider(height: 20),
                _BudgetRow(label: 'Gerçek Harcama', value: formatCurrency(actualTotal)),
                const Divider(height: 20),
                _BudgetRow(label: 'Tahmini Kalan', value: formatCurrency(remaining)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Kategori Bazlı Harcama',
            child: Column(
              children: state.categories.map((category) {
                final tasks = state.tasksForCategory(category.id);
                final estimated =
                    tasks.fold<double>(0, (sum, t) => sum + (t.estimatedPrice ?? 0));
                final actual =
                    tasks.fold<double>(0, (sum, t) => sum + (t.actualPrice ?? 0));

                if (tasks.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('${category.icon} ${category.name}'),
                      ),
                      Expanded(
                        child: Text(
                          formatCurrency(estimated),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formatCurrency(actual),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final String value;

  const _BudgetRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
