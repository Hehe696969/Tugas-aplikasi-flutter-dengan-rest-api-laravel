import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perpus_app/main.dart';

void main() {
  testWidgets('Aplikasi Perpustakaan berhasil dijalankan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PerpusApp()));

    expect(find.byType(PerpusApp), findsOneWidget);
  });
}
