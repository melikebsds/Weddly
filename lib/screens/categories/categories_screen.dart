import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wedding_state.dart';
import '../../widgets/category_list_tile.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeddingState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Listeler')),
      body: RefreshIndicator(
        onRefresh: state.reloadAll,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.categories.length,
          itemBuilder: (context, index) {
            final category = state.categories[index];

            return CategoryListTile(
              category: category,
              totalCount: category.totalTaskCount,
              completedCount: category.completedTaskCount,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryDetailScreen(category: category),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
