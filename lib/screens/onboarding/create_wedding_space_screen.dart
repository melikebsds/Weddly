import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' show describeError;
import '../../providers/wedding_state.dart';
import '../home/root_shell.dart';

/// Bölüm 15.1: Yeni hazırlık alanı oluşturma.
class CreateWeddingSpaceScreen extends StatefulWidget {
  const CreateWeddingSpaceScreen({super.key});

  @override
  State<CreateWeddingSpaceScreen> createState() => _CreateWeddingSpaceScreenState();
}

class _CreateWeddingSpaceScreenState extends State<CreateWeddingSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _weddingDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _weddingDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<WeddingState>().createSpace(
            name: _nameController.text.trim(),
            weddingDate: _weddingDate,
          );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _weddingDate == null
        ? 'Düğün tarihi seç (isteğe bağlı)'
        : '${_weddingDate!.day}.${_weddingDate!.month}.${_weddingDate!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Hazırlık Alanı')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Hazırlık Alanı Adı'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Hazırlık alanı adı boş olamaz'
                      : null,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(dateLabel),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Oluştur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
