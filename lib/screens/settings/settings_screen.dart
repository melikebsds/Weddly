import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wedding_state.dart';
import '../splash/splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editWeddingDate(BuildContext context) async {
    final state = context.read<WeddingState>();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.activeSpace?.weddingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    try {
      await state.setWeddingDate(picked);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  Future<void> _editSpaceName(BuildContext context) async {
    final state = context.read<WeddingState>();
    final controller = TextEditingController(text: state.activeSpace?.name ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hazırlık Alanı Adı'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Örn. Melike & Yasin\'in Hazırlıkları'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    try {
      await state.renameActiveSpace(newName);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  Future<void> _invitePartner(BuildContext context) async {
    final state = context.read<WeddingState>();
    try {
      final invitation = await state.createInvitation();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Davet Kodu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bu kodu partnerine gönder:'),
              const SizedBox(height: 12),
              SelectableText(
                invitation.invitationCode,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (invitation.expiresAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Son kullanma: ${invitation.expiresAt!.day}.${invitation.expiresAt!.month}.${invitation.expiresAt!.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: invitation.invitationCode));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Kod panoya kopyalandı')));
              },
              child: const Text('Kopyala'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final space = context.watch<WeddingState>().activeSpace;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil'),
            subtitle: Text(user?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Partnerini Davet Et'),
            onTap: () => _invitePartner(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: const Text('Aktif Hazırlık Alanı'),
            subtitle: Text(space?.name ?? '-'),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _editSpaceName(context),
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Düğün Tarihini Düzenle'),
            onTap: () => _editWeddingDate(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
