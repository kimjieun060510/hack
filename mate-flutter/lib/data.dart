/// 앱 이름 · 예시 데이터 · 날짜/시간 도우미가 모여 있는 파일이에요.
/// 화면에 나오는 이름, 일정, 공지는 모두 예시예요. 여기서 고치면 앱 전체에 반영돼요.

const String kAppName = 'mate';

/// 데모 기준일: 2026-09-21 (월). 날짜는 'M-D' 글자로 다뤄요. 예) '9-21'
const String kToday = '9-21';
const List<String> kDayN = ['월', '화', '수', '목', '금', '토', '일'];
const List<int> kWeek = [21, 22, 23, 24, 25, 26, 27];

/// 일정 목록의 작은 알약에 쓰는 짧은 이름
const Map<String, String> kTypeShort = {
  'class': '시간표',
  'assign': '과제',
  'job': '개인',
  'meet': '약속',
  'dept': '학과',
  'opp': '기회',
};

/// 필터 · 일정 종류 (id, 이름)
const List<(String, String)> kBaseTypes = [
  ('class', '시간표'),
  ('assign', '과제'),
  ('job', '개인 일정'),
  ('meet', '약속'),
  ('dept', '학과 일정'),
  ('opp', '기회'),
];
const int kMaxCustom = 6;

/// 추천 분야
const Map<String, String> kCats = {
  'edu': '비교과',
  'schol': '장학금',
  'lab': '산학협력',
  'vol': '봉사활동',
  'club': '동아리',
};
const List<String> kFields = ['개발·IT', '디자인', '경영·마케팅', '연구·실험', '공연·예술', '취업·진로'];

/// 추천 소식. url 을 누르면 그 사이트가 열려요.
class Opp {
  final String id, url, cat, g, src, title, key, t, meta;
  final List<String> fields;
  const Opp(this.id, this.url, this.cat, this.g, this.src, this.title, this.key, this.t, this.meta, this.fields);
}

const List<Opp> kOpps = [
  Opp('o1', 'https://cse.skku.edu/cse/notice.do', 'edu', 'dept', '학과 홈페이지', '신입생 진로탐색 특강', '9-25', '18:00', '선착순 40명', ['취업·진로']),
  Opp('o2', 'https://www.skku.edu/skku/campus/skk_comm/notice06.do', 'schol', 'dept', '학과 홈페이지', '교내 장학금 신청 안내', '9-25', '17:00', '성적·소득 기준 확인', []),
  Opp('o3', 'https://ranbiz.skku.edu/?p=21', 'lab', 'dept', '산학협력단', '산학협력 프로젝트 모집', '9-25', '23:59', '팀 또는 개인 지원', ['개발·IT', '연구·실험']),
  Opp('o4', 'https://cse.skku.edu/cse/notice.do', 'edu', 'dept', '소프트웨어학과', 'AI 아이디어톤 참가팀 모집', '9-27', '23:59', '3~4인 팀', ['개발·IT']),
  Opp('o5', 'https://www.skku.edu/skku/campus/skk_comm/notice01.do', 'vol', 'dept', '학생지원팀', '겨울 해외봉사단 모집', '10-1', '17:00', '서류 심사 후 면접', []),
  Opp('o6', 'https://everytime.kr', 'club', 'etta', '에타', '해커톤 팀원 모집', '9-22', '23:59', '디자이너·기획자 환영', ['개발·IT', '디자인']),
];

class Friend {
  final String n, d, t; // 이름, 학과·학번, 색 종류
  const Friend(this.n, this.d, this.t);
}

const List<Friend> kFriends = [
  Friend('김민준', '컴퓨터공학 26', 'class'),
  Friend('이서연', '경영학 26', 'meet'),
  Friend('박지훈', '전자전기공학 26', 'job'),
];

class PlayPost {
  final String id, title, when, who, time, end;
  final String? key;
  final List<String> names;
  const PlayPost(this.id, this.title, this.when, this.who, this.names, this.time, this.end, [this.key]);
}

const List<PlayPost> kPlays = [
  PlayPost('p1', '영화 보러 갈 사람?', '오늘 20:00', '2~4명 · 익명 가능', ['최', '정'], '20:00', '22:30'),
  PlayPost('p2', '보드게임 카페 가실 분', '토 9/26 15:00', '3~5명 · 같은 학교', ['한'], '15:00', '17:00', '9-26'),
];

/// 내 정보 화면의 "데모 둘러보기" 목록
const List<(String, String)> kJumps = [
  ('처음 시작', '학생증 인증 · 관심사 한 번만 고르기'),
  ('일정 한눈에', '주간 플래너 · AI 건강 챙기기 · 일정 추가'),
  ('기회 받기', '“이거 관심 있으세요?” → 달력에 추가'),
  ('밥약', '지금 밥 먹을 사람? · 익명 · 한마디'),
  ('과팅', '팀 만들기 · 시간대 매칭 · 매너 경고'),
  ('놀기', '같이 놀 사람 모으기 · 모임 만들기'),
  ('받는 사람 화면', '푸시 알림 · 배너 알림'),
];

/// 달력 일정 하나
class Ev {
  final String id, key, t, end, type, title, sub;
  final bool mine;
  final double? hours;
  final String? src, cat, g, oppId;
  Ev({
    required this.id,
    required this.key,
    required this.t,
    required this.end,
    required this.type,
    required this.title,
    required this.sub,
    this.mine = false,
    this.hours,
    this.src,
    this.cat,
    this.g,
    this.oppId,
  });
}

/// 직접 만든 일정 종류
class CustomType {
  final String id, name;
  final int p; // 색 번호 (0~5)
  CustomType(this.id, this.name, this.p);
}

// ---------------------------------------------------------------- 날짜·시간 도우미

int dowOf(String key) {
  final p = key.split('-');
  return DateTime.utc(2026, int.parse(p[0]), int.parse(p[1])).weekday - 1; // 월=0 … 일=6
}

int dayOf(String key) => int.parse(key.split('-')[1]);

int diffDays(String key) {
  final p = key.split('-');
  return DateTime.utc(2026, int.parse(p[0]), int.parse(p[1])).difference(DateTime.utc(2026, 9, 21)).inDays;
}

String dayLabel(String key) => '${dayOf(key)}일 ${kDayN[dowOf(key)]}요일';

String ddayText(String key) {
  final n = diffDays(key);
  return n == 0 ? 'D-DAY' : (n > 0 ? 'D-$n' : 'D+${n.abs()}');
}

String shortDate(String key) {
  final p = key.split('-');
  return '${p[0]}/${p[1]} (${kDayN[dowOf(key)]})';
}

int toMin(String t) {
  final p = t.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

String fromMin(int n) {
  final v = n.clamp(0, 1440);
  return '${(v ~/ 60).toString().padLeft(2, '0')}:${(v % 60).toString().padLeft(2, '0')}';
}

List<String> timeOpts(String a, String b) {
  final o = <String>[];
  for (var n = toMin(a); n <= toMin(b); n += 30) {
    o.add(fromMin(n));
  }
  return o;
}

double hoursBetween(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final d = (toMin(b) - toMin(a)) / 60;
  return d < 0 ? 0 : d;
}

String fmtH(double h) {
  final r = (h * 2).round() / 2;
  return r == r.roundToDouble() ? r.round().toString() : r.toString();
}

/// "9/28", "9-28", "28", "0928", "9월 28일" 처럼 친 글자를 'M-D' 로 바꿔요. 9월이 아니면 null.
String? parseSeptDate(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final nums = RegExp(r'\d+').allMatches(s).map((m) => m.group(0)!).toList();
  int? month, day;
  if (nums.length >= 2) {
    month = int.tryParse(nums[nums.length - 2]);
    day = int.tryParse(nums[nums.length - 1]);
  } else if (nums.length == 1) {
    final d = nums[0];
    if (d.length <= 2) {
      month = 9;
      day = int.tryParse(d);
    } else if (d.length == 3) {
      month = int.tryParse(d.substring(0, 1));
      day = int.tryParse(d.substring(1));
    } else if (d.length == 4) {
      month = int.tryParse(d.substring(0, 2));
      day = int.tryParse(d.substring(2));
    }
  }
  if (month != 9 || day == null || day < 1 || day > 30) return null;
  return '9-$day';
}
