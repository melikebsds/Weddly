import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/wedding_state.dart';
import 'screens/splash/splash_screen.dart';
import 'services/api_client.dart';
import 'services/auth_api_service.dart';
import 'services/category_api_service.dart';
import 'services/invitation_api_service.dart';
import 'services/secure_storage_service.dart';
import 'services/task_api_service.dart';
import 'services/wedding_space_api_service.dart';

void main() {
  runApp(const BridelyApp());
}

class BridelyApp extends StatelessWidget {
  const BridelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorageService();
    final apiClient = ApiClient(storage: storage);
    final authApiService = AuthApiService(apiClient);
    final weddingSpaceApiService = WeddingSpaceApiService(apiClient);
    final categoryApiService = CategoryApiService(apiClient);
    final taskApiService = TaskApiService(apiClient);
    final invitationApiService = InvitationApiService(apiClient);

    return MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: authApiService),
        Provider.value(value: weddingSpaceApiService),
        Provider.value(value: categoryApiService),
        Provider.value(value: taskApiService),
        Provider.value(value: invitationApiService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authApiService: authApiService, storage: storage),
        ),
        ChangeNotifierProvider(
          create: (_) => WeddingState(
            weddingSpaceApi: weddingSpaceApiService,
            categoryApi: categoryApiService,
            taskApi: taskApiService,
            invitationApi: invitationApiService,
            storage: storage,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Bridely',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
