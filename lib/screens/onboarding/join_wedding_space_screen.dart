import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' show describeError;
import '../../providers/wedding_state.dart';
import '../home/root_shell.dart';

/// Bölüm 15.2: Davet koduyla mevcut bir hazırlık alanına katılma.
class JoinWeddingSpaceScreen extends StatefulWidget {
  const JoinWeddingSpaceScreen({super.key});

  @override
  State<JoinWeddingSpaceScreen> createState() => _JoinWeddingSpaceScreenState();
}

class _JoinWeddingSpaceScreenState extends State<JoinWeddingSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<WeddingState>().joinSpaceWithCode(_codeController.text.trim());
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
    return Scaffold(
      appBar: AppBar(title: const Text('Davet Koduyla Katıl')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Davet Kodu',
                    hintText: 'LOVE-2026-X82A',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Kod boş olamaz';
                    if (!RegExp(r'^[A-Za-z0-9-]+$').hasMatch(value.trim())) {
                      return 'Kod geçerli formatta olmalıdır';
                    }
                    return null;
                  },
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
                      : const Text('Katıl'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
