import 'package:flutter_test/flutter_test.dart';
import 'package:humanacare_paciente/main.dart';
import 'package:humanacare_paciente/models/app_state.dart';

void main() {
  testWidgets('HumanaCare inicia corretamente', (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      HumanaCareApp(
        appState: appState,
      ),
    );

    expect(find.byType(HumanaCareApp), findsOneWidget);
  });
}