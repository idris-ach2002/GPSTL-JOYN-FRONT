import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/app/app.dart';

void main() {
  testWidgets('JOYN starts on the landing page', (tester) async {
    await tester.pumpWidget(const JoynApp());

    await tester.pumpAndSettle();

    expect(find.text('JOYN'), findsOneWidget);
  });
}
