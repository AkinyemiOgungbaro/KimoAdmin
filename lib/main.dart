import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tokenStore.init();
  // Restore/verify any existing session before the first frame so the router
  // guard can redirect correctly.
  await authController.bootstrap();
  runApp(const KimoAdminApp());
}
