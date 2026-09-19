import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/main.dart';
import 'package:mate/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    app.resetAll();
    app.logout();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MateApp());
  }

  Future<void> login(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, '2026123456');
    await tester.enterText(find.byType(TextField).last, 'demo');
    await tester.tap(find.text('로그인').last);
    await tester.pump();
  }

  testWidgets('앱이 열리고 첫 화면(로그인)이 보여요', (tester) async {
    await pumpApp(tester);
    expect(find.text('로그인'), findsWidgets);
    expect(find.text('회원가입 / 인증'), findsOneWidget);
  });

  testWidgets('홈에는 알림·마이페이지가 없고, 내 약속에서만 마이페이지가 보여요', (tester) async {
    await pumpApp(tester);
    await login(tester);

    expect(find.bySemanticsLabel(RegExp(r'^알림')), findsNothing);
    expect(find.bySemanticsLabel('내 정보'), findsNothing);

    await tester.ensureVisible(find.text('내 약속'));
    await tester.tap(find.text('내 약속'));
    await tester.pump();

    expect(find.bySemanticsLabel('내 정보'), findsOneWidget);
  });

  testWidgets('내 정보는 로그아웃까지이고 그 아래 데모 메뉴는 없어요', (tester) async {
    await pumpApp(tester);
    await login(tester);
    await tester.ensureVisible(find.text('내 약속'));
    await tester.tap(find.text('내 약속'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('내 정보'));
    await tester.pump();

    expect(find.text('로그아웃'), findsOneWidget);
    expect(find.text('채널톡 연동'), findsOneWidget);
    expect(find.text('정보를 가져올 곳'), findsNothing);
    expect(find.text('관심사 다시 고르기'), findsNothing);
    expect(find.text('매너 경고'), findsNothing);
    expect(find.text('데모 둘러보기'), findsNothing);
    expect(find.text('처음 상태로 되돌리기'), findsNothing);
  });
}
