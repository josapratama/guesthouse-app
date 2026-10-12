import 'package:flutter_test/flutter_test.dart';
import 'package:guesthouse_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic smoke test — app builds without crashing
    await tester.pumpWidget(const GuestHouseApp());
  });
}
