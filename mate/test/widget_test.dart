import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mate/feeds.dart';
import 'package:mate/main.dart';
import 'package:mate/state.dart';

void main() {
  setUpAll(() {
    FeedClient.allowNetwork = false;
  });

  testWidgets('앱이 열리고 첫 화면(로그인)이 보여요', (tester) async {
    await tester.pumpWidget(const MateApp());
    expect(find.text('로그인'), findsWidgets);
    expect(find.text('회원가입 / 인증'), findsOneWidget);
  });

  testWidgets('로그인 뒤 내 정보에서 가져올 곳 네 가지가 보여요', (tester) async {
    await tester.pumpWidget(const MateApp());
    app.idC.text = '2026123456';
    app.pwC.text = 'demo';
    app.login();
    await tester.pump();
    expect(find.text('밥약'), findsOneWidget);
    app.open('me');
    await tester.pump();
    expect(find.text('학교 홈페이지'), findsWidgets);
    expect(find.text('학과 홈페이지'), findsWidgets);
    expect(find.text('아이캠퍼스'), findsWidgets);
    expect(find.text('에브리타임'), findsWidgets);
    expect(find.text('지금 가져오기'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  test('성균관대 공지 HTML에서 제목·날짜·글번호를 뽑아요', () {
    final html = File('test/fixtures/skku_board.html').readAsStringSync();
    final list = SkkuBoardParser.parse(html, baseUrl: 'https://www.skku.edu/skku/campus/skk_comm/notice01.do');
    expect(list.length, 2);
    expect(list.first.id, '140050');
    expect(list.first.categoryRaw, '장학');
    expect(list.first.posted, '2026-09-18');
    expect(list.first.title, contains('대학원우수장학금'));
    expect(list.first.url, contains('articleNo=140050'));
  });

  test('제목 안의 마감일을 달력 키로 바꿔요', () {
    expect(noticeWhen('추천서 접수: 9.23.(수)~10.13.(화)', '2026-09-18').key, '10-13');
    expect(noticeWhen('모집[~9.22.(화) 16:00까지]', '2026-09-19').key, '9-22');
    expect(noticeWhen('모집[~9.22.(화) 16:00까지]', '2026-09-19').time, '16:00');
    expect(noticeWhen('날짜 없는 공지', '2026-09-18').key, '9-18');
    expect(noticeCat('장학', '선발 안내'), 'schol');
    expect(noticeCat('동아리', '모집'), 'club');
  });

  test('저장해 둔 JSON 공지도 Opp 로 바뀌어요', () {
    const json = '''
{
  "sourceId": "school",
  "loginRequired": false,
  "items": [
    {"id": "1", "title": "교내 장학금", "url": "https://example.com", "posted": "2026-09-18", "categoryRaw": "장학"}
  ]
}
''';
    final doc = parseSnapshot(json);
    expect(doc.opps.single.g, 'school');
    expect(doc.opps.single.cat, 'schol');
    expect(doc.opps.single.id, 'feed-school-1');
  });

  test('공개 게시판 HTML을 가져오면 네트워크 결과로 표시해요', () async {
    FeedClient.allowNetwork = true;
    addTearDown(() => FeedClient.allowNetwork = false);
    final html = File('test/fixtures/skku_board.html').readAsStringSync();
    final client = FeedClient(
      httpClient: MockClient((req) async {
        expect(req.url.host, 'www.skku.edu');
        return http.Response.bytes(utf8.encode(html), 200, headers: {'content-type': 'text/html; charset=utf-8'});
      }),
      loadAsset: (_) async => throw StateError('snapshot should not be used'),
    );
    final bundle = await client.load(kFeedSources.firstWhere((s) => s.id == 'school'));
    expect(bundle.fromNetwork, isTrue);
    expect(bundle.opps, isNotEmpty);
    expect(bundle.opps.first.src, '학교 홈페이지');
  });

  test('로그인이 필요한 곳은 공개 HTML을 긁지 않아요', () async {
    var hits = 0;
    final client = FeedClient(
      httpClient: MockClient((req) async {
        hits++;
        return http.Response('nope', 500);
      }),
      loadAsset: (path) async {
        expect(path, 'assets/feeds/icampus.json');
        return File(path).readAsStringSync();
      },
    );
    final bundle = await client.load(kFeedSources.firstWhere((s) => s.id == 'icampus'));
    expect(hits, 0);
    expect(bundle.loginPending, isTrue);
    expect(bundle.fromNetwork, isFalse);
    expect(bundle.opps, isNotEmpty);
  });
}
