import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finpath/main.dart';
import 'package:finpath/services/app_state.dart';

void main() {
  testWidgets('FinPath app launches and shows welcome screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const FinPathApp(),
      ),
    );
    expect(find.text('FinPath'), findsOneWidget);
  });
}
