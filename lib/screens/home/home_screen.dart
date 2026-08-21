import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_state.dart';
import '../../widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeddingState>();
    final userName = context.watch<AuthProvider>().currentUser?.name ?? '';
    final days = state.daysUntilWedding();

    return Scaffold(
      appBar: AppBar(title: const Text('Bridely')),
      body: RefreshIndicator(
        onRefresh: state.reloadAll,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Merhaba $userName 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (days != null) _CountdownCard(days: days),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Hazırlık Durumu',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.completedTaskCount()} / ${state.totalTaskCount()} görev tamamlandı',
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.completionRatio(),
                    minHeight: 10,
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text('%${(state.completionRatio() * 100).round()} tamamlandı'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Bütçe Özeti',
            child: Row(
              children: [
                Expanded(
                  child: _BudgetStat(
                    label: 'Tahmini Toplam',
                    value: formatCurrency(state.estimatedTotal()),
                  ),
                ),
                Expanded(
                  child: _BudgetStat(
                    label: 'Harcanan',
                    value: formatCurrency(state.actualTotal()),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final int days;

  const _CountdownCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFB94A63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BÜYÜK GÜNE KALAN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$days',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const Text(
            'GÜN 💍',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;

  const _BudgetStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
