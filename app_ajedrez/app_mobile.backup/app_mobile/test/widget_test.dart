import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_mobile/main.dart';

void main() {
  testWidgets('Shows login when there is no saved token', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const ChessApp());
    await tester.pumpAndSettle();

    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
