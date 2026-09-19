import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mate/data.dart';
import 'package:mate/feeds.dart';
import 'package:mate/main.dart';
import 'package:mate/state.dart';

void main() {
  setUpAll(() {
    FeedClient.allowNetwork = false;
  });

  testWidgets('로그인 칸에 학번·비밀번호를 칠 수 있어요', (tester) async {
    await tester.pumpWidget(const MateApp());
    await tester.enterText(find.byType(TextField).first, '2026123456');
    await tester.enterText(find.byType(TextField).at(1), 'demo');
    expect(app.idC.text, '2026123456');
    expect(app.pwC.text, 'demo');
    await tester.tap(find.text('로그인').last);
    await tester.pump();
    expect(find.text('밥약'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('로그인 뒤 내 정보에서 가져올 곳이 보여요', (tester) async {
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
    expect(find.text('소프트웨어융합대학'), findsWidgets);
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

  test('제목 안의 마감일·행사 당일을 달력 키로 바꿔요', () {
    expect(noticeWhen('추천서 접수: 9.23.(수)~10.13.(화)', '2026-09-18').key, '10-13');
    expect(noticeWhen('추천서 접수: 9.23.(수)~10.13.(화)', '2026-09-18').kind, 'deadline');
    expect(noticeWhen('모집[~9.22.(화) 16:00까지]', '2026-09-19').key, '9-22');
    expect(noticeWhen('모집[~9.22.(화) 16:00까지]', '2026-09-19').time, '16:00');
    expect(noticeWhen('날짜 없는 공지', '2026-09-18').key, '9-18');
    expect(noticeWhen('날짜 없는 공지', '2026-09-18').kind, 'posted');
    final info = noticeWhen('2026-2학기 소프트웨어학과 진학설명회 안내 (9/30(목) 18:00 / 사전접수 : 9/18(금))', '2026-09-16');
    expect(info.key, '9-30');
    expect(info.time, '18:00');
    expect(info.kind, 'event');
    final forum = noticeWhen('(9월 29일(화)/여의도 FKI타워) 대한민국 클라우드/SaaS 포럼 2026', '2026-09-11');
    expect(forum.key, '9-29');
    expect(forum.kind, 'event');
    final talk = noticeWhen('(9/14(월) 12:00-13:30 2공학관 26106호) 한화시스템 방산부문 채용설명회', '2026-09-11');
    expect(talk.key, '9-14');
    expect(talk.time, '12:00');
    expect(talk.kind, 'event');
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

  test('소프트웨어융합대학 학부 공지를 가져와요', () async {
    FeedClient.allowNetwork = true;
    addTearDown(() => FeedClient.allowNetwork = false);
    final html = File('test/fixtures/sw_college_board.html').readAsStringSync();
    final client = FeedClient(
      httpClient: MockClient((req) async {
        expect(req.url.host, 'sw.skku.edu');
        return http.Response.bytes(utf8.encode(html), 200, headers: {'content-type': 'text/html; charset=utf-8'});
      }),
      loadAsset: (_) async => throw StateError('snapshot should not be used'),
    );
    final bundle = await client.load(kFeedSources.firstWhere((s) => s.id == 'college'));
    expect(bundle.fromNetwork, isTrue);
    expect(bundle.opps, isNotEmpty);
    expect(bundle.opps.every((o) => o.src == '소프트웨어융합대학'), isTrue);
    expect(bundle.opps.any((o) => o.title.contains('진학설명회')), isTrue);
    expect(bundle.opps.any((o) => o.title.contains('한마당')), isFalse);
    final info = bundle.opps.firstWhere((o) => o.title.contains('진학설명회'));
    expect(info.key, '9-30');
    expect(info.t, '18:00');
    expect(info.whenKind, 'event');
    expect(info.url, contains('articleNo=225638'));
  });

  test('저장해 둔 단대 공지 스냅샷도 Opp 로 바뀌어요', () {
    final doc = parseSnapshot(File('assets/feeds/college.json').readAsStringSync());
    expect(doc.sourceId, 'college');
    expect(doc.opps, isNotEmpty);
    expect(doc.opps.any((o) => o.title.contains('진학설명회') && o.key == '9-30' && o.whenKind == 'event'), isTrue);
  });

  testWidgets('추천 + 는 공지의 마감일·행사 당일에 달력 일정을 넣어요', (tester) async {
    await tester.pumpWidget(const MateApp());
    final before = app.events.length;
    app.toggleOpp('o1');
    await tester.pump();
    final added = app.events.where((e) => e.id == 'opp-o1');
    expect(added, isNotEmpty);
    expect(added.first.key, '9-25');
    expect(added.first.t, '18:00');
    expect(app.sel, '9-25');
    app.toggleOpp('o1');
    await tester.pump();
    expect(app.events.where((e) => e.id == 'opp-o1'), isEmpty);
    expect(app.events.length, before);

    final o = parseSnapshot(File('assets/feeds/college.json').readAsStringSync()).opps.firstWhere((x) => x.title.contains('진학설명회'));
    app.opps.add(o);
    app.toggleOpp(o.id);
    await tester.pump();
    final ev = app.events.firstWhere((e) => e.id == 'opp-${o.id}');
    expect(ev.key, '9-30');
    expect(ev.t, '18:00');
    expect(app.sel, '9-30');
    app.events.removeWhere((e) => e.id == ev.id);
    app.opps.removeWhere((x) => x.id == o.id);
    await tester.pump(const Duration(seconds: 3));
  });

  test('날짜 글자를 9월 밖도 포함해 달력 키로 바꿔요', () {
    expect(parseDate('9/28'), '9-28');
    expect(parseDate('28'), '9-28');
    expect(parseDate('0928'), '9-28');
    expect(parseDate('9월 28일'), '9-28');
    expect(parseDate('10/1'), '10-1');
    expect(parseDate('10월 13일'), '10-13');
    expect(parseDate('9/31'), isNull);
    expect(parseDate('13/1'), isNull);
    expect(parseDate(''), isNull);
  });

  test('달력에 있는 일정의 제목·날짜·시간을 고칠 수 있어요', () {
    app.resetAll();
    final e = app.events.firstWhere((x) => x.title == '카페 알바' && x.key == '9-21');
    app.prepareEdit(e);
    expect(app.isEditing, isTrue);
    expect(app.addTitleC.text, '카페 알바');
    expect(app.addDateC.text, '9/21');
    expect(app.addType, 'job');
    app.addTitleC.text = '도서관 알바';
    app.addDateC.text = '10/2';
    app.addStart = '13:00';
    app.addEnd = '17:00';
    expect(app.submitAdd(), isNull);
    final edited = app.events.firstWhere((x) => x.id == e.id);
    expect(edited.title, '도서관 알바');
    expect(edited.key, '10-2');
    expect(edited.t, '13:00');
    expect(edited.end, '17:00');
    expect(edited.hours, 4);
    expect(app.sel, '10-2');
    expect(app.isEditing, isFalse);
    expect(app.events.where((x) => x.id == e.id).length, 1);
  });

  testWidgets('달력에서 일정을 누르면 수정 창이 열려요', (tester) async {
    await tester.pumpWidget(const MateApp());
    app.resetAll();
    app.idC.text = '2026123456';
    app.pwC.text = 'demo';
    app.login();
    await tester.pump();
    app.jump(1);
    await tester.pumpAndSettle();
    expect(find.text('자료구조 과제 2'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('자료구조 과제 2 수정'));
    await tester.pumpAndSettle();
    expect(find.text('일정 수정'), findsOneWidget);
    expect(find.text('저장'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '과제 이름 바꿈');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('일정 수정'), findsNothing);
    expect(find.text('과제 이름 바꿈'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
  });
}
