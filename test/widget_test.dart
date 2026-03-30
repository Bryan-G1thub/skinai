import 'package:flutter_test/flutter_test.dart';
import 'package:skinai/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SkinAIApp());
    await tester.pumpAndSettle();
    
    expect(find.text('SkinAI'), findsOneWidget);
  });
}
