import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.init();

  final deps = AppDependencies();
  final router = createAppRouter(deps: deps, notifications: notifications);

  runApp(AdsDashboardApp(router: router));
}

class AdsDashboardApp extends StatelessWidget {
  const AdsDashboardApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ads Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
