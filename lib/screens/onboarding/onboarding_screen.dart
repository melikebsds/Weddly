import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wedding_state.dart';
import '../../services/wedding_space_api_service.dart';
import '../home/root_shell.dart';
import 'create_wedding_space_screen.dart';
import 'join_wedding_space_screen.dart';

/// Bölüm 15: Yeni kayıt olan / zaten üye olan kullanıcıya doğru ekranı sunar.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSpace();
  }

  Future<void> _checkExistingSpace() async {
    final weddingState = context.read<WeddingState>();
    final spaceApi = context.read<WeddingSpaceApiService>();

    try {
      final spaces = await spaceApi.getAll();
      if (spaces.isNotEmpty) {
        await weddingState.restoreOrActivate(spaces.first);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RootShell()),
          (route) => false,
        );
        return;
      }
    } catch (_) {
      // Alan listesi alınamadı; kullanıcı elle oluşturabilir/katılabilir.
    }

    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Hazırlığa başlayalım',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateWeddingSpaceScreen()),
                ),
                child: const Text('Yeni Hazırlık Alanı Oluştur'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JoinWeddingSpaceScreen()),
                ),
                child: const Text('Davet Koduyla Katıl'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
