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
    expect(list.length, 3);
    expect(list.first.id, '140050');
    expect(list.first.categoryRaw, '장학');
    expect(list.first.posted, '2026-09-18');
    expect(list.first.title, contains('대학원우수장학금'));
    expect(list.first.url, 'https://www.skku.edu/skku/campus/skk_comm/notice01.do?mode=view&articleNo=140050');
  });

  test('제목 안의 마감일을 달력 키로 바꿔요', () {
    expect(noticeWhen('추천서 접수: 9.23.(수)~10.13.(화)', '2026-09-18').key, '10-13');
    expect(noticeWhen('모집[~9.22.(화) 16:00까지]', '2026-09-19').key, '9-22');
    expect(noticeWhen('모집[~9.22.(화) 16:00까지]', '2026-09-19').time, '16:00');
    expect(noticeWhen('날짜 없는 공지', '2026-09-18').key, '9-18');
    expect(noticeCat('장학', '선발 안내'), 'schol');
    expect(noticeCat('동아리', '모집'), 'club');
    expect(noticeCat('학사', '졸업평가 안내'), 'etc');
    expect(noticeCat('행사/세미나', '2026 ICPC 대학생 프로그래밍 경시대회 안내'), 'edu');
    expect(noticeCat('', '국가장학금 지급 안내'), 'schol');
    expect(noticeCat('취업', 'ICT학점연계 인턴십'), 'lab');
    expect(noticeCat('채용/모집', '신입사원 모집'), 'etc');
    expect(noticeCat('행사/세미나', '비교과 프로그램 참여 후기 조사'), 'edu');
    expect(noticeViewUrl('https://cse.skku.edu/cse/notice.do?mode=list', '225776'), 'https://cse.skku.edu/cse/notice.do?mode=view&articleNo=225776');
  });

  test('학부생에게 필요한 글만 남기고 대학원·조교는 빼요', () {
    expect(keepUndergradNotice('2026 ICPC 대학생 프로그래밍 경시대회 안내', '행사/세미나'), isTrue);
    expect(keepUndergradNotice('[졸업평가] 연구논문작품 신청서 제출 방법 안내', '학사'), isTrue);
    expect(keepUndergradNotice('2026-2학기 소프트웨어학과 진학설명회 안내', '행사/세미나'), isTrue);
    expect(keepUndergradNotice('[한국장학재단] 2026학년도 2학기 국가장학금 지급 안내', ''), isTrue);
    expect(keepUndergradNotice('2027학년도 1학기 新대학원우수장학금 선발 안내', '장학'), isFalse);
    expect(keepUndergradNotice('사회과학대학 행정조교 모집', '채용/모집'), isFalse);
    expect(keepUndergradNotice('AI응용공학과(일반대학원) 신입생 모집', '입학'), isFalse);
    expect(keepUndergradNotice('산학교수 채용', '채용/모집'), isFalse);
    expect(keepUndergradNotice('2026-2학기 대학원 한마당 및 소프트웨어학과 오픈랩 안내', '행사/세미나'), isFalse);
    expect(keepUndergradNotice('When Language Meets 3D: Language-Grounded Perception and Reasoning', ''), isFalse);
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
    expect(bundle.opps.every((o) => keepUndergradNotice(o.title, o.meta)), isTrue);
    expect(bundle.opps.any((o) => o.title.contains('ICPC')), isTrue);
    expect(bundle.opps.any((o) => o.title.contains('대학원우수')), isFalse);
    expect(bundle.opps.where((o) => o.title.contains('ICPC')).every((o) => o.url.contains('articleNo=225776')), isTrue);
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
