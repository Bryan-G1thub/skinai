import 'package:flutter_test/flutter_test.dart';
import 'package:skiin/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SkiinApp());
    await tester.pumpAndSettle();
    
    expect(find.text('Skiin'), findsOneWidget);
  });
}
