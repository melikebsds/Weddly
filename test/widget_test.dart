import 'package:flutter_test/flutter_test.dart';

import 'package:bridely_app/main.dart';

void main() {
  testWidgets('Uygulama açılışta çöküyor mu (splash ekranı görünüyor mu)', (tester) async {
    await tester.pumpWidget(const BridelyApp());
    await tester.pump();

    expect(find.text('Bridely'), findsOneWidget);
  });
}
