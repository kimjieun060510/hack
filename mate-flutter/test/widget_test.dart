import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/main.dart';
import 'package:mate/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    app.resetAll();
  });

  testWidgets('첫 화면은 로그인이에요', (tester) async {
    await tester.pumpWidget(const MateApp());
    expect(find.text('로그인'), findsNWidgets(2));
    expect(find.text('학번'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
    expect(find.text('자동 로그인'), findsOneWidget);
    expect(find.text('회원가입 / 인증'), findsOneWidget);
    expect(find.text('Mate'), findsOneWidget);
  });

  testWidgets('로그인 버튼을 누르면 메인(달력)으로 들어가요', (tester) async {
    await tester.pumpWidget(const MateApp());
    await tester.enterText(find.byType(TextField).first, '20231234');
    await tester.enterText(find.byType(TextField).last, 'demo');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('혜인님'), findsOneWidget);
    expect(find.text('달력'), findsOneWidget);
  });

  testWidgets('회원가입 버튼은 아직 시안을 기다려요', (tester) async {
    await tester.pumpWidget(const MateApp());
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();
    expect(find.textContaining('회원가입 / 인증 화면은 다음 시안'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
