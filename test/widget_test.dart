import 'package:flutter_test/flutter_test.dart';
import 'package:widmate/app/app.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('WidMate'), findsOneWidget);
  });
}
