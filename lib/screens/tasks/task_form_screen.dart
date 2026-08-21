import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/wedding_task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_state.dart';

class TaskFormScreen extends StatefulWidget {
  final WeddingCategory category;
  final WeddingTask? task;

  const TaskFormScreen({super.key, required this.category, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _subCategoryController;
  late final TextEditingController _estimatedController;
  late final TextEditingController _actualController;
  late final TextEditingController _noteController;
  late final TextEditingController _productUrlController;
  WeddingTaskStatus _status = WeddingTaskStatus.toBuy;
  ResponsibleParty _responsibleParty = ResponsibleParty.unspecified;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _subCategoryController = TextEditingController(text: task?.subCategory ?? '');
    _estimatedController =
        TextEditingController(text: task?.estimatedPrice?.toStringAsFixed(0) ?? '');
    _actualController =
        TextEditingController(text: task?.actualPrice?.toStringAsFixed(0) ?? '');
    _noteController = TextEditingController(text: task?.description ?? '');
    _productUrlController = TextEditingController(text: task?.productUrl ?? '');
    _status = task?.status ?? WeddingTaskStatus.toBuy;
    _responsibleParty = task?.responsibleParty ?? ResponsibleParty.unspecified;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subCategoryController.dispose();
    _estimatedController.dispose();
    _actualController.dispose();
    _noteController.dispose();
    _productUrlController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Geçerli bir sayı giriniz';
    if (parsed < 0) return 'Fiyat negatif olamaz';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final state = context.read<WeddingState>();
    final estimated = _estimatedController.text.trim().isEmpty
        ? null
        : double.tryParse(_estimatedController.text.replaceAll(',', '.'));
    final actual = _actualController.text.trim().isEmpty
        ? null
        : double.tryParse(_actualController.text.replaceAll(',', '.'));

    try {
      if (_isEditing) {
        await state.updateTask(
          widget.task!,
          title: _titleController.text.trim(),
          subCategory: _subCategoryController.text.trim().isEmpty
              ? null
              : _subCategoryController.text.trim(),
          description: _noteController.text.trim(),
          estimatedPrice: estimated,
          actualPrice: actual,
          responsibleParty: _responsibleParty,
          productUrl: _productUrlController.text.trim().isEmpty
              ? null
              : _productUrlController.text.trim(),
          status: _status,
        );
      } else {
        await state.addTask(
          widget.category.id,
          title: _titleController.text.trim(),
          subCategory: _subCategoryController.text.trim().isEmpty
              ? null
              : _subCategoryController.text.trim(),
          description: _noteController.text.trim(),
          estimatedPrice: estimated,
          actualPrice: actual,
          responsibleParty: _responsibleParty,
          productUrl: _productUrlController.text.trim().isEmpty
              ? null
              : _productUrlController.text.trim(),
          status: _status,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Görevi Düzenle' : 'Yeni Görev')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Görev / Ürün Adı'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Görev adı boş olamaz' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subCategoryController,
              decoration: const InputDecoration(
                labelText: 'Alt Kategori (isteğe bağlı)',
                hintText: 'Örn. Pişirme, Sofra, Mobilya',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _estimatedController,
              decoration: const InputDecoration(labelText: 'Tahmini Fiyat'),
              keyboardType: TextInputType.number,
              validator: _validatePrice,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _actualController,
              decoration: const InputDecoration(labelText: 'Gerçek Fiyat'),
              keyboardType: TextInputType.number,
              validator: _validatePrice,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _productUrlController,
              decoration: const InputDecoration(
                labelText: 'Ürün Linki (isteğe bağlı)',
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Not'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Sorumlu', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ResponsibleParty>(
              segments: const [
                ButtonSegment(value: ResponsibleParty.bride, label: Text('Gelin')),
                ButtonSegment(value: ResponsibleParty.groom, label: Text('Damat')),
                ButtonSegment(value: ResponsibleParty.both, label: Text('Ortak')),
              ],
              selected: {
                _responsibleParty == ResponsibleParty.unspecified
                    ? ResponsibleParty.both
                    : _responsibleParty,
              },
              onSelectionChanged: (selection) =>
                  setState(() => _responsibleParty = selection.first),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Durum', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            SegmentedButton<WeddingTaskStatus>(
              segments: WeddingTaskStatus.values
                  .map((status) => ButtonSegment(value: status, label: Text(status.label)))
                  .toList(),
              selected: {_status},
              onSelectionChanged: (selection) => setState(() => _status = selection.first),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Kaydet' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
