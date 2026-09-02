import 'package:flutter_test/flutter_test.dart';
import 'package:humanacare_paciente/main.dart';

void main() {
  testWidgets('HumanaCare inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const HumanaCareApp());

    expect(find.byType(HumanaCareApp), findsOneWidget);
  });
}

