import 'package:flutter_test/flutter_test.dart';
import 'package:buddi/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BuddiApp());
    expect(find.byType(BuddiApp), findsOneWidget);
  });
}
