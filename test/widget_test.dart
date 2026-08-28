import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kimo_admin/app.dart';
import 'package:kimo_admin/core/di.dart';
import 'package:kimo_admin/features/auth/login_page.dart';

void main() {
  testWidgets('Unauthenticated app boots to the login screen', (tester) async {
    // Mirror main.dart's startup with an empty (signed-out) token store.
    SharedPreferences.setMockInitialValues({});
    await tokenStore.init();
    await authController.bootstrap();

    await tester.pumpWidget(const KimoAdminApp());
    await tester.pumpAndSettle();

    // No tokens → the router guard redirects to /login (no network calls).
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
