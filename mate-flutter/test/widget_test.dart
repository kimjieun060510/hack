import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mate/main.dart';
import 'package:mate/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    app.resetAll();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MateApp());
  }

  testWidgets('첫 화면은 로그인이에요', (tester) async {
    await pumpApp(tester);
    expect(find.text('로그인'), findsNWidgets(2));
    expect(find.text('학번'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
    expect(find.text('자동 로그인'), findsOneWidget);
    expect(find.text('회원가입 / 인증'), findsOneWidget);
    expect(find.text('Mate'), findsOneWidget);
  });

  testWidgets('로그인 버튼을 누르면 메인(달력)으로 들어가요', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextField).first, '20231234');
    await tester.enterText(find.byType(TextField).last, 'demo');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('혜인님'), findsOneWidget);
    expect(find.text('달력'), findsOneWidget);
  });

  testWidgets('회원가입 / 인증으로 학생증 가입 화면이 열려요', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();
    expect(find.textContaining('학생증 한 장이면'), findsOneWidget);
    expect(find.text('사진 찍기'), findsOneWidget);
    expect(find.text('앨범'), findsOneWidget);
    expect(find.text('제출'), findsOneWidget);
    expect(find.text('남'), findsOneWidget);
    expect(find.text('여'), findsOneWidget);
  });

  testWidgets('학생증을 읽은 척하면 이름·학번·학과가 채워지고 제출하면 로그인으로 돌아가요', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signupCamera')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 850));
    expect(find.text('혜인'), findsOneWidget);
    expect(find.text('20231234'), findsOneWidget);
    expect(find.text('소프트웨어학과'), findsOneWidget);
    expect(find.textContaining('학생증이 인식됐어요'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('signupSubmit')));
    await tester.tap(find.byKey(const Key('signupSubmit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('로그인'), findsNWidgets(2));
    expect(find.textContaining('계정이 만들어졌어요'), findsOneWidget);
    expect(app.studentIdC.text, '20231234');
    await tester.pump(const Duration(milliseconds: 2500));
  });

  testWidgets('회원가입에서 뒤로 가면 로그인으로 돌아가요', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signupBack')));
    await tester.pump();
    expect(find.text('Mate'), findsOneWidget);
    expect(find.text('회원가입 / 인증'), findsOneWidget);
  });
}
