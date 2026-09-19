import 'package:flutter_test/flutter_test.dart';
import 'package:mate/main.dart';

void main() {
  testWidgets('앱이 열리고 첫 화면(학생증 인증)이 보여요', (tester) async {
    await tester.pumpWidget(const MateApp());
    expect(find.textContaining('학생증 한 장이면'), findsOneWidget);
  });
}
