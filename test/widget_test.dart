import 'package:flutter_test/flutter_test.dart';
import 'package:fast_note/main.dart';

void main() {
  testWidgets('Fast Note app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const FastNoteApp());

    // Let first frame render
    await tester.pumpAndSettle();

    // Verify app title exists
    expect(find.text('Modern Notes'), findsOneWidget);
  });
}
