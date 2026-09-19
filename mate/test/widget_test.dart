import 'package:flutter_test/flutter_test.dart';
import 'package:mate/main.dart';

void main() {
  testWidgets('앱이 열리고 첫 화면(로그인)이 보여요', (tester) async {
    await tester.pumpWidget(const MateApp());
    expect(find.text('로그인'), findsWidgets);
    expect(find.text('회원가입 / 인증'), findsOneWidget);
  });
}
