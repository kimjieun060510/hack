import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'data.dart';

/// 아이캠퍼스 · 학교/학과 홈페이지 · 에브리타임에서 소식을 가져오는 층이에요.
///
/// - 학교·학과 공지: 로그인 없이 볼 수 있는 HTML을 읽어 제목·날짜·링크를 뽑아요.
/// - 아이캠퍼스·에브리타임: 공식 공개 API가 없고 로그인이 필요해서,
///   비밀번호를 받아 몰래 긁지 않고 같은 JSON 계약의 예시(스냅샷)를 써요.
///   나중에 SSO/공식 연동이 되면 [FeedBundle] 만 바꾸면 화면은 그대로예요.

class FeedDef {
  final String id, name, sub;
  final bool needsLogin;
  final String? liveUrl;
  final String snapshotAsset;
  const FeedDef({
    required this.id,
    required this.name,
    required this.sub,
    required this.needsLogin,
    required this.snapshotAsset,
    this.liveUrl,
  });

  bool get canFetchLive => liveUrl != null && !needsLogin;
}

/// 관심사 고르기 · 내 정보에서 같이 쓰는 목록
const List<FeedDef> kFeedSources = [
  FeedDef(
    id: 'icampus',
    name: '아이캠퍼스',
    sub: '시간표·과제는 킹고 로그인이 필요해요. 지금은 연동 전 예시를 써요.',
    needsLogin: true,
    snapshotAsset: 'assets/feeds/icampus.json',
  ),
  FeedDef(
    id: 'school',
    name: '학교 홈페이지',
    sub: '성균관대 전체 공지를 공개 게시판에서 가져와요.',
    needsLogin: false,
    liveUrl: 'https://www.skku.edu/skku/campus/skk_comm/notice01.do?mode=list',
    snapshotAsset: 'assets/feeds/school.json',
  ),
  FeedDef(
    id: 'dept',
    name: '학과 홈페이지',
    sub: '소프트웨어학과 공지를 공개 게시판에서 가져와요.',
    needsLogin: false,
    liveUrl: 'https://cse.skku.edu/cse/notice.do?mode=list',
    snapshotAsset: 'assets/feeds/dept.json',
  ),
  FeedDef(
    id: 'etta',
    name: '에브리타임',
    sub: '공식 API가 없어요. 로그인 연동 전이라 예시 글만 보여요.',
    needsLogin: true,
    snapshotAsset: 'assets/feeds/etta.json',
  ),
];

FeedDef? feedDef(String id) {
  for (final s in kFeedSources) {
    if (s.id == id) return s;
  }
  return null;
}

/// 게시판에서 읽은 글 한 줄 (아직 앱의 Opp 로 바꾸기 전)
class RawNotice {
  final String id, title, url, posted, categoryRaw;
  const RawNotice({
    required this.id,
    required this.title,
    required this.url,
    required this.posted,
    required this.categoryRaw,
  });
}

class FeedBundle {
  final String sourceId;
  final bool fromNetwork;
  final bool loginPending;
  final List<Opp> opps;
  const FeedBundle({
    required this.sourceId,
    required this.fromNetwork,
    required this.loginPending,
    required this.opps,
  });

  String get status {
    final n = opps.length;
    if (loginPending) return '로그인 연동 전 · 예시 $n건';
    if (fromNetwork) return '방금 홈페이지에서 $n건 가져왔어요';
    return '저장해 둔 공지 $n건 (네트워크가 안 될 때)';
  }
}

// ------------------------------------------------------------------ HTML 파서 · 날짜 · 분류

/// 성균관대 CMS(jwxe) 게시판 HTML에서 글 목록을 뽑아요.
class SkkuBoardParser {
  static List<RawNotice> parse(String html, {required String baseUrl}) {
    final out = <RawNotice>[];
    final seen = <String>{};
    final chunks = html.split('board-list-content-wrap');
    for (var i = 1; i < chunks.length; i++) {
      final block = chunks[i];
      final id = _first(RegExp(r'articleNo=(\d+)'), block);
      if (id == null || !seen.add(id)) continue;
      final cat = _first(RegExp(r'c-board-list-category">\[([^\]]+)\]'), block) ?? '';
      final rawTitle = _first(RegExp(r'title="자세히 보기">([\s\S]*?)</a>'), block);
      if (rawTitle == null) continue;
      final title = _plain(rawTitle);
      if (title.isEmpty) continue;
      final posted = _first(RegExp(r'<li>(20\d{2}-\d{2}-\d{2})</li>'), block) ?? '';
      final sep = baseUrl.contains('?') ? '&' : '?';
      out.add(RawNotice(
        id: id,
        title: title,
        url: '$baseUrl${sep}mode=view&articleNo=$id',
        posted: posted,
        categoryRaw: cat,
      ));
    }
    return out;
  }

  static String? _first(RegExp re, String s) => re.firstMatch(s)?.group(1);

  static String _plain(String raw) {
    var t = raw.replaceAll(RegExp(r'<[^>]+>'), ' ');
    t = t.replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('&#39;', "'");
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

/// 제목 안의 "9.27", "~10/7", "9.23.(수)~10.13" 같은 마감일을 찾아요. 없으면 게시일.
({String key, String time}) noticeWhen(String title, String posted) {
  final dates = <(int, int)>[];
  for (final m in RegExp(r'(?:20)?(\d{2})?[.\-/년]?\s*(\d{1,2})[.\-/월]\s*(\d{1,2})').allMatches(title)) {
    var month = int.tryParse(m.group(2) ?? '');
    final day = int.tryParse(m.group(3) ?? '');
    if (month == null || day == null || month < 1 || month > 12 || day < 1 || day > 31) continue;
    dates.add((month, day));
  }
  String key;
  if (dates.isNotEmpty) {
    final last = dates.last;
    key = '${last.$1}-${last.$2}';
  } else {
    key = postedToKey(posted) ?? kToday;
  }
  final tm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(title);
  final time = tm != null ? '${tm.group(1)!.padLeft(2, '0')}:${tm.group(2)}' : '23:59';
  return (key: key, time: time);
}

String? postedToKey(String posted) {
  final m = RegExp(r'^20\d{2}-(\d{2})-(\d{2})$').firstMatch(posted.trim());
  if (m == null) return null;
  return '${int.parse(m.group(1)!)}-${int.parse(m.group(2)!)}';
}

String noticeCat(String raw, String title) {
  final t = '$raw $title';
  if (t.contains('장학')) return 'schol';
  if (t.contains('봉사')) return 'vol';
  if (t.contains('산학') || t.contains('연구') || (t.contains('인턴') && t.contains('랩'))) return 'lab';
  if (t.contains('동아리')) return 'club';
  return 'edu';
}

List<String> noticeFields(String title) {
  final out = <String>[];
  if (RegExp(r'AI|IT|개발|프로그래밍|소프트웨어|SW|코딩|엔지니어').hasMatch(title)) out.add('개발·IT');
  if (RegExp(r'디자인').hasMatch(title)) out.add('디자인');
  if (RegExp(r'경영|마케팅').hasMatch(title)) out.add('경영·마케팅');
  if (RegExp(r'채용|인턴|진로|취업').hasMatch(title)) out.add('취업·진로');
  return out;
}

String noticeSrcName(String sourceId) {
  switch (sourceId) {
    case 'school':
      return '학교 홈페이지';
    case 'dept':
      return '학과 홈페이지';
    case 'icampus':
      return '아이캠퍼스';
    case 'etta':
      return '에타';
    default:
      return sourceId;
  }
}

Opp noticeToOpp(RawNotice n, String sourceId) {
  final when = noticeWhen(n.title, n.posted);
  return Opp(
    'feed-$sourceId-${n.id}',
    n.url,
    noticeCat(n.categoryRaw, n.title),
    sourceId,
    noticeSrcName(sourceId),
    n.title,
    when.key,
    when.time,
    n.categoryRaw.isEmpty ? '공지' : n.categoryRaw,
    noticeFields(n.title),
  );
}

// ------------------------------------------------------------------ JSON 스냅샷

class SnapshotDoc {
  final String sourceId;
  final bool loginRequired;
  final List<Opp> opps;
  const SnapshotDoc({required this.sourceId, required this.loginRequired, required this.opps});
}

SnapshotDoc parseSnapshot(String jsonText) {
  final map = json.decode(jsonText) as Map<String, dynamic>;
  final sourceId = map['sourceId'] as String? ?? '';
  final items = <Opp>[];
  for (final raw in (map['items'] as List? ?? const [])) {
    final m = raw as Map<String, dynamic>;
    final title = m['title'] as String? ?? '';
    final posted = m['posted'] as String? ?? '';
    final catRaw = m['categoryRaw'] as String? ?? '';
    final when = m['key'] is String ? (key: m['key'] as String, time: (m['t'] as String?) ?? '23:59') : noticeWhen(title, posted);
    final rawId = m['id'] as String? ?? 'x';
    final id = rawId.contains('-') ? rawId : 'feed-$sourceId-$rawId';
    items.add(Opp(
      id,
      m['url'] as String? ?? '',
      (m['cat'] as String?) ?? noticeCat(catRaw, title),
      sourceId,
      noticeSrcName(sourceId),
      title,
      when.key,
      when.time,
      (m['meta'] as String?) ?? (catRaw.isEmpty ? '공지' : catRaw),
      ((m['fields'] as List?) ?? noticeFields(title)).cast<String>(),
    ));
  }
  return SnapshotDoc(sourceId: sourceId, loginRequired: map['loginRequired'] == true, opps: items);
}

// ------------------------------------------------------------------ 가져오기

class FeedClient {
  FeedClient({http.Client? httpClient, this.loadAsset}) : _http = httpClient ?? http.Client();

  /// 위젯 테스트에서는 실제 학교 홈페이지를 치지 않아요.
  static bool allowNetwork = true;

  final http.Client _http;
  final Future<String> Function(String asset)? loadAsset;

  Future<String> _asset(String path) async {
    if (loadAsset != null) return loadAsset!(path);
    return rootBundle.loadString(path);
  }

  Future<FeedBundle> load(FeedDef def) async {
    if (def.canFetchLive && allowNetwork) {
      try {
        final html = await _http
            .get(
              Uri.parse(def.liveUrl!),
              headers: const {
                'User-Agent': 'mate-mvp/1.0 (hackathon public notice reader)',
                'Accept': 'text/html',
              },
            )
            .timeout(const Duration(seconds: 8))
            .then((r) {
          if (r.statusCode != 200) throw Exception('status ${r.statusCode}');
          return utf8.decode(r.bodyBytes);
        });
        final notices = SkkuBoardParser.parse(html, baseUrl: def.liveUrl!.split('?').first);
        if (notices.isNotEmpty) {
          return FeedBundle(
            sourceId: def.id,
            fromNetwork: true,
            loginPending: false,
            opps: [for (final n in notices) noticeToOpp(n, def.id)],
          );
        }
      } catch (_) {
        // 크롬(CORS) · 오프라인이면 스냅샷으로 넘어가요.
      }
    }
    final snap = parseSnapshot(await _asset(def.snapshotAsset));
    return FeedBundle(
      sourceId: def.id,
      fromNetwork: false,
      loginPending: def.needsLogin,
      opps: snap.opps,
    );
  }
}
