import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_gudangmng/main.dart';

void main() {
  testWidgets('Cek halaman login muncul', (WidgetTester tester) async {
    // Mocking SharedPreferences
    SharedPreferences.setMockInitialValues({'is_login': false});

    await tester.pumpWidget(const MyApp(isLogin: false));

    // Mencari teks "Selamat Datang" yang ada di LoginScreen kamu
    expect(find.text('Selamat Datang'), findsOneWidget);
  });
}