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
  late final TextEditingController _estimatedController;
  late final TextEditingController _actualController;
  late final TextEditingController _noteController;
  bool _isCompleted = false;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _estimatedController =
        TextEditingController(text: task?.estimatedPrice?.toStringAsFixed(0) ?? '');
    _actualController =
        TextEditingController(text: task?.actualPrice?.toStringAsFixed(0) ?? '');
    _noteController = TextEditingController(text: task?.description ?? '');
    _isCompleted = task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _estimatedController.dispose();
    _actualController.dispose();
    _noteController.dispose();
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
          description: _noteController.text.trim(),
          estimatedPrice: estimated,
          actualPrice: actual,
          isCompleted: _isCompleted,
        );
      } else {
        await state.addTask(
          widget.category.id,
          title: _titleController.text.trim(),
          description: _noteController.text.trim(),
          estimatedPrice: estimated,
          actualPrice: actual,
          isCompleted: _isCompleted,
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
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Not'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tamamlandı'),
              value: _isCompleted,
              onChanged: (value) => setState(() => _isCompleted = value),
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
