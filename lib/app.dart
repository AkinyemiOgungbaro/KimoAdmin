import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class KimoAdminApp extends StatelessWidget {
  const KimoAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KIMO GAMES Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
