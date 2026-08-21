import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/wedding_task.dart';
import '../../providers/wedding_state.dart';
import '../../widgets/section_card.dart';

const _chartColors = [
  Color(0xFFE0576B),
  Color(0xFFF2A65A),
  Color(0xFF5AA9E6),
  Color(0xFF6FCF97),
  Color(0xFF9B72CF),
  Color(0xFFE6C15A),
  Color(0xFF56C1B4),
  Color(0xFFD65DB1),
  Color(0xFF4E8397),
  Color(0xFFB0705C),
  Color(0xFF8C9EFF),
  Color(0xFFB94A63),
];

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int? _touchedIndex;

  double _categoryEstimated(WeddingState state, String categoryId) {
    return state
        .tasksForCategory(categoryId)
        .where((t) => t.status != WeddingTaskStatus.notNeeded)
        .fold<double>(0, (sum, t) => sum + (t.estimatedPrice ?? 0));
  }

  double _categoryActual(WeddingState state, String categoryId) {
    return state
        .tasksForCategory(categoryId)
        .where((t) => t.status != WeddingTaskStatus.notNeeded)
        .fold<double>(0, (sum, t) => sum + (t.actualPrice ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeddingState>();
    final estimatedTotal = state.estimatedTotal();
    final actualTotal = state.actualTotal();
    final remaining = estimatedTotal - actualTotal;

    final categoriesWithBudget = state.categories
        .map((c) => (category: c, estimated: _categoryEstimated(state, c.id)))
        .where((entry) => entry.estimated > 0)
        .toList();

    final hasActualSpending = actualTotal > 0;
    final difference = estimatedTotal - actualTotal;
    final isOverBudget = hasActualSpending && difference < 0;
    final isUnderBudget = hasActualSpending && difference > 0;

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
                  if (hasActualSpending) ...[
                    const SizedBox(height: 16),
                    _BudgetStatusBanner(isOver: isOverBudget, isUnder: isUnderBudget, difference: difference),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (categoriesWithBudget.isNotEmpty)
              SectionCard(
                title: 'Kategori Dağılımı (Tahmini)',
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response?.touchedSection == null) {
                                  _touchedIndex = null;
                                  return;
                                }
                                _touchedIndex = response!.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sections: [
                            for (var i = 0; i < categoriesWithBudget.length; i++)
                              _buildSection(i, categoriesWithBudget[i].estimated, estimatedTotal),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < categoriesWithBudget.length; i++)
                          _LegendItem(
                            color: _chartColors[i % _chartColors.length],
                            label: categoriesWithBudget[i].category.name,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Kategori Bazlı Harcama',
              child: Column(
                children: state.categories.map((category) {
                  final estimated = _categoryEstimated(state, category.id);
                  final actual = _categoryActual(state, category.id);

                  if (estimated == 0 && actual == 0) return const SizedBox.shrink();

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

  PieChartSectionData _buildSection(int index, double value, double total) {
    final isTouched = index == _touchedIndex;
    final percentage = total == 0 ? 0 : (value / total * 100);
    return PieChartSectionData(
      color: _chartColors[index % _chartColors.length],
      value: value,
      title: '${percentage.toStringAsFixed(0)}%',
      radius: isTouched ? 70 : 60,
      titleStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _BudgetStatusBanner extends StatelessWidget {
  final bool isOver;
  final bool isUnder;
  final double difference;

  const _BudgetStatusBanner({
    required this.isOver,
    required this.isUnder,
    required this.difference,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOver && !isUnder) return const SizedBox.shrink();

    final color = isOver ? Colors.red : AppColors.success;
    final icon = isOver ? Icons.trending_up : Icons.trending_down;
    final text = isOver
        ? '${formatCurrency(difference.abs())} Bütçe Aşımı'
        : '${formatCurrency(difference.abs())} Tasarruf';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
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
