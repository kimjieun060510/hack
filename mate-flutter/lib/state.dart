import 'dart:async';

import 'package:flutter/material.dart';

import 'data.dart';

/// 앱의 모든 상태와 "버튼을 눌렀을 때 일어나는 일"이 들어 있는 파일이에요.
/// 화면(screens/*.dart)은 여기 있는 app 을 읽고, 버튼에서 app.○○() 를 불러요.

class Notif {
  final String id, ic, t, s, go;
  Notif(this.id, this.ic, this.t, this.s, this.go);
}

class BannerData {
  final String t, ic, k, title, body, cta, go;
  const BannerData({required this.t, required this.ic, required this.k, required this.title, required this.body, this.cta = '', this.go = ''});
}

class MealState {
  String time = '지금'; // '지금' 또는 'HH:MM'
  String date = kToday;
  String clock = '12:30';
  String mode = 'friends'; // friends | party
  String send = 'auto'; // auto | manual
  String scope = 'school';
  String msg = '';
  String step = 'form'; // form | searching | matched | posted
  bool team = true, kakao = false, anon = true;
}

class MeetState {
  String date = '9-26';
  String from = '18:00';
  String to = '21:00';
  String? winFrom, winTo;
  String step = 'form'; // form | searching | found | matched
  bool warned = false;
}

class PlayState {
  String view = 'list'; // list | new | done
  final Map<String, bool> joined = {};
  String scope = 'school';
  bool anon = true;
}

class Load {
  final double score, jobH;
  final int assigns, n, lvl;
  const Load(this.score, this.jobH, this.assigns, this.n, this.lvl);
}

class Team {
  final String name, from, to;
  final double overlap;
  const Team(this.name, this.from, this.to, this.overlap);
}

class AppState extends ChangeNotifier {
  AppState() {
    _init();
  }

  int _uid = 100;
  Timer? _toastT, _bannerT, _searchT, _loginT, _signupT;

  // ---- 로그인 (채널톡 연동 전 · 된 척만)
  bool loggedIn = false;
  bool autoLogin = false;
  bool loginObscure = true;
  bool loginBusy = false;
  String authPage = 'login'; // login | signup
  final studentIdC = TextEditingController();
  final passwordC = TextEditingController();

  // ---- 회원가입
  String signupPhoto = 'idle'; // idle | scanning | done
  String signupGender = 'm'; // m | f
  bool signupBusy = false;
  final signupNameC = TextEditingController();
  final signupIdC = TextEditingController();
  final signupDeptC = TextEditingController();

  // ---- 화면 상태
  int? onboard; // 0 인증, 1 관심사, null 이면 메인 화면. 로그인이 먼저라 시작은 null.
  String verify = 'idle'; // idle | scanning | done
  String tab = 'cal'; // reco | cal | social
  String calView = 'week';
  String sel = kToday;
  String filter = 'all';
  String social = 'hub'; // hub | meal | meeting | play
  bool push = false;
  BannerData? banner;
  String toastMsg = '';
  int unread = 2;

  late List<Ev> events;
  late Map<String, bool> cats, fields, conn;
  late List<CustomType> customTypes;
  late List<Notif> notifs;
  late MealState meal;
  late MeetState meet;
  late PlayState play;

  // 밥약 신청 / 함께 신청
  String reqWho = 'senior';
  bool reqAnon = true;
  String shareOpp = 'o1';
  late Map<int, bool> shareTo;

  // 일정 추가
  String addType = 'job';
  bool addNewOpen = false;
  String addStart = '18:00', addEnd = '22:00';
  String playStart = '19:00', playEnd = '22:00';

  // 글자 입력칸
  final mealMsgC = TextEditingController();
  final addTitleC = TextEditingController();
  final addDateC = TextEditingController();
  final addNewC = TextEditingController();
  final reqMsgC = TextEditingController();
  final playTitleC = TextEditingController();

  void _init() {
    loggedIn = false;
    autoLogin = false;
    loginObscure = true;
    loginBusy = false;
    authPage = 'login';
    studentIdC.clear();
    passwordC.clear();
    signupPhoto = 'idle';
    signupGender = 'm';
    signupBusy = false;
    signupNameC.clear();
    signupIdC.clear();
    signupDeptC.clear();
    onboard = null;
    verify = 'idle';
    tab = 'cal';
    calView = 'week';
    sel = kToday;
    filter = 'all';
    social = 'hub';
    push = false;
    banner = null;
    toastMsg = '';
    unread = 2;
    events = _initialEvents();
    cats = {'edu': true, 'schol': true, 'lab': true, 'vol': true, 'club': true};
    fields = {'개발·IT': true, '경영·마케팅': true};
    conn = {'icampus': true, 'dept': true, 'etta': true};
    customTypes = [];
    notifs = [
      Notif('n1', 'sparkle', '새 기회 2개가 도착했어요', '관심 분야에 맞는 공고예요', 'reco'),
      Notif('n2', 'utensils', '익명의 새내기가 밥약을 보냈어요', '12:30 같이 밥 먹을래요?', 'push'),
    ];
    meal = MealState();
    meet = MeetState();
    play = PlayState();
    reqWho = 'senior';
    reqAnon = true;
    shareOpp = 'o1';
    shareTo = {0: true, 1: true, 2: false};
    addType = 'job';
    addNewOpen = false;
    addStart = '18:00';
    addEnd = '22:00';
    playStart = '19:00';
    playEnd = '22:00';
    mealMsgC.clear();
    addTitleC.clear();
    addDateC.text = '9/21';
    addNewC.clear();
    reqMsgC.text = '안녕하세요! 같은 학과 새내기예요. 시간 되실 때 밥 한 끼 같이 먹어도 될까요?';
    playTitleC.clear();
  }

  void _n() => notifyListeners();

  // ------------------------------------------------------------ 예시 일정

  Ev _ev(String key, String t, String end, String type, String title, String sub,
      {bool mine = false, double? hours, String? src}) {
    return Ev(id: 'e${_uid++}', key: key, t: t, end: end, type: type, title: title, sub: sub, mine: mine, hours: hours, src: src);
  }

  Ev oppEvent(Opp o) => Ev(
        id: 'opp-${o.id}',
        key: o.key,
        t: o.t,
        end: '',
        type: 'opp',
        title: o.title,
        sub: '기회 추천에서 추가 · ${o.src}',
        cat: o.cat,
        g: o.g,
        oppId: o.id,
      );

  List<Ev> _initialEvents() {
    const ic = 'icampus';
    const from = '아이캠퍼스에서 가져옴';
    final base = <Ev>[
      _ev('9-21', '09:00', '10:15', 'class', '자료구조', from, src: ic),
      _ev('9-21', '13:00', '14:15', 'class', '논리회로', from, src: ic),
      _ev('9-21', '23:59', '', 'assign', '자료구조 과제 2', '아이캠퍼스 · 마감', src: ic),
      _ev('9-21', '23:59', '', 'assign', '영어 에세이', '아이캠퍼스 · 마감', src: ic),
      _ev('9-21', '23:59', '', 'assign', '논리회로 실험 보고서', '아이캠퍼스 · 마감', src: ic),
      _ev('9-22', '10:30', '12:00', 'class', '프로그래밍 실습', from, src: ic),
      _ev('9-22', '12:00', '18:00', 'job', '카페 알바', '6시간 · 직접 입력', mine: true, hours: 6),
      _ev('9-23', '09:00', '10:15', 'class', '자료구조', from, src: ic),
      _ev('9-23', '15:00', '16:15', 'class', '영어 회화', from, src: ic),
      _ev('9-23', '18:30', '20:00', 'meet', '동기들과 저녁 약속', '캠퍼스 앞 · 3명', mine: true),
      _ev('9-24', '10:30', '12:00', 'class', '프로그래밍 실습', from, src: ic),
      _ev('9-24', '17:00', '', 'dept', '학과 신입생 멘토링 설명회', '학과 홈페이지 · 공지'),
      _ev('9-25', '13:00', '14:15', 'class', '논리회로', from, src: ic),
      _ev('9-25', '19:00', '21:00', 'meet', '동아리 첫 모임', '에타에서 찾은 일정', mine: true),
      _ev('9-26', '15:00', '17:00', 'job', '과외', '2시간 · 직접 입력', mine: true, hours: 2),
      oppEvent(kOpps[5]),
      oppEvent(kOpps[2]),
    ];
    return base..addAll(_fillerEvents());
  }

  /// 21~27일 밖의 날들: 월간 보기가 비어 보이지 않도록 넣은 예시 일정
  List<Ev> _fillerEvents() {
    final out = <Ev>[];
    const ic = 'icampus';
    const from = '아이캠퍼스에서 가져옴';
    final days = <int>[for (var d = 1; d <= 20; d++) d, 28, 29, 30];
    for (final d in days) {
      final k = '9-$d';
      final w = dowOf(k);
      Ev cls(String t, String e, String n) => _ev(k, t, e, 'class', n, from, src: ic);
      if (w == 0) out.addAll([cls('09:00', '10:15', '자료구조'), cls('13:00', '14:15', '논리회로')]);
      if (w == 1) {
        out.addAll([cls('10:30', '12:00', '프로그래밍 실습'), _ev(k, '12:00', '18:00', 'job', '카페 알바', '6시간 · 직접 입력', mine: true, hours: 6)]);
      }
      if (w == 2) out.addAll([cls('09:00', '10:15', '자료구조'), cls('15:00', '16:15', '영어 회화')]);
      if (w == 3) out.add(cls('10:30', '12:00', '프로그래밍 실습'));
      if (w == 4) out.add(cls('13:00', '14:15', '논리회로'));
      if (w == 5) out.add(_ev(k, '15:00', '17:00', 'job', '과외', '2시간 · 직접 입력', mine: true, hours: 2));
    }
    Ev a(String k, String title) => _ev(k, '23:59', '', 'assign', title, '아이캠퍼스 · 마감', src: ic);
    out.addAll([
      a('9-4', '영어 에세이 1'),
      a('9-7', '자료구조 과제 1'),
      _ev('9-11', '17:00', '', 'dept', '학과 신입생 OT', '학과 홈페이지 · 공지'),
      _ev('9-12', '18:00', '20:00', 'meet', '동기 첫 모임', '캠퍼스 앞 · 5명', mine: true),
      a('9-14', '논리회로 과제 1'),
      _ev('9-16', '12:00', '13:00', 'meet', '밥약 · 학식', '이서연 외 2명', mine: true),
      a('9-18', '실험 보고서 1'),
      _ev('9-19', '19:00', '21:00', 'meet', '동아리 설명회', '에타에서 찾은 일정', mine: true),
      a('9-28', '자료구조 과제 3'),
      _ev('9-29', '17:00', '', 'dept', '졸업생 특강', '학과 홈페이지 · 공지'),
      a('9-30', '영어 에세이 2'),
    ]);
    return out;
  }

  // ------------------------------------------------------------ 조회 도우미

  CustomType? customOf(String t) {
    for (final c in customTypes) {
      if (c.id == t) return c;
    }
    return null;
  }

  String typeName(String t) => customOf(t)?.name ?? kTypeShort[t] ?? t;

  /// 필터 · 일정 종류 목록 (맨 앞이 '전체')
  List<(String, String)> filterList() => [('all', '전체'), ...kBaseTypes, ...customTypes.map((c) => (c.id, c.name))];

  bool isAdded(String oppId) => events.any((e) => e.id == 'opp-$oppId');

  bool visible(Ev e) {
    if (e.src == 'icampus' && conn['icampus'] != true) return false;
    if (e.type == 'opp') {
      if (cats[e.cat] != true) return false;
      if (e.g == 'etta' && conn['etta'] != true) return false;
      if (e.g == 'dept' && conn['dept'] != true) return false;
    }
    return true;
  }

  List<Ev> eventsOn(String key) {
    final l = events.where((e) => e.key == key && visible(e)).toList();
    l.sort((a, b) => a.t.compareTo(b.t));
    return l;
  }

  Load loadOf(String key) {
    final es = eventsOn(key);
    double score = 0, jobH = 0;
    var assigns = 0;
    for (final e in es) {
      if (e.type == 'class') {
        score += 1;
      } else if (e.type == 'assign') {
        score += 1.5;
        assigns++;
      } else if (e.type == 'job') {
        final h = e.hours ?? 2;
        score += h * 0.5;
        jobH += h;
      } else {
        score += 0.5;
      }
    }
    final lvl = score >= 6 ? 2 : (score >= 3 ? 1 : 0);
    return Load(score, jobH, assigns, es.length, lvl);
  }

  String aiText(String key) {
    final l = loadOf(key);
    final p = key.split('-');
    final prev = '${p[0]}-${int.parse(p[1]) - 1}';
    final pl = loadOf(prev);
    if (l.n == 0) return '비어있는 하루예요. 밥약이나 산책으로 기분 전환 어때요?';
    if (l.assigns >= 3) return '마감이 ${l.assigns}개예요. 충분히 자고, 영양가 있는 저녁을 챙겨요.';
    if (l.jobH >= 6) return '알바가 ${fmtH(l.jobH)}시간이에요. 내일은 쉬어가는 날로 비워두는 게 좋겠어요.';
    if (pl.jobH >= 6) return '어제 알바가 길었어요. 오늘은 물 자주 마시고 일찍 쉬어요.';
    if (l.lvl == 2) return '오늘은 빡빡한 하루예요. 끼니를 거르지 말고 중간에 쉬어가요.';
    if (l.lvl == 1) return '적당히 바쁜 날이에요. 점심은 꼭 챙겨 먹어요.';
    return '오늘은 여유로워요. 저녁 전에 가볍게 산책해 보는 건 어때요?';
  }

  List<Ev> upcoming() {
    final l = events.where((e) => visible(e) && (e.type == 'assign' || e.type == 'opp') && diffDays(e.key) >= 0).toList();
    l.sort((a, b) {
      final d = diffDays(a.key) - diffDays(b.key);
      return d != 0 ? d : a.t.compareTo(b.t);
    });
    return l.take(6).toList();
  }

  String? fieldMatch(Opp o) {
    for (final f in o.fields) {
      if (fields[f] == true) return f;
    }
    return null;
  }

  List<Opp> recoList() => kOpps.where((o) => cats[o.cat] == true && (o.g != 'etta' || conn['etta'] == true) && (o.g != 'dept' || conn['dept'] == true)).toList();

  // 밥약 도우미
  String mealClock() => meal.time == '지금' ? '12:10' : meal.time;
  String mealAt() => (meal.date == kToday ? '' : '${shortDate(meal.date)} ') + mealClock();
  String mealWhen() => meal.time == '지금' ? '지금' : mealAt();
  String mealCta() => '${mealWhen()} 밥약 ${meal.mode == 'friends' ? '보내기' : '올리기'}';
  bool mealDone() => events.any((e) => e.title == '밥약' && e.t == mealClock() && e.key == meal.date);
  bool todayMealDone() => events.any((e) => e.key == kToday && e.title.startsWith('밥약'));

  // 과팅 도우미
  String meetSummary() => '${shortDate(meet.date)} ${meet.from}–${meet.to}에 가능한 팀을 찾아요';
  List<Team> meetTeams() {
    final dur = hoursBetween(meet.from, meet.to);
    return [
      Team('경영학과 26학번 3명', meet.from, meet.to, dur),
      Team('심리학과 26학번 3명', fromMin(toMin(meet.from) + 30), fromMin(toMin(meet.to) + 30), dur - 0.5 < 0.5 ? 0.5 : dur - 0.5),
    ];
  }

  // ------------------------------------------------------------ 알림 · 토스트 · 배너

  void showToast(String m) {
    toastMsg = m;
    _toastT?.cancel();
    _toastT = Timer(const Duration(milliseconds: 2400), () {
      toastMsg = '';
      _n();
    });
    _n();
  }

  void showBanner(BannerData b) {
    banner = b;
    _bannerT?.cancel();
    _bannerT = Timer(const Duration(seconds: 6), () {
      banner = null;
      _n();
    });
    _n();
  }

  void _notify(String ic, String t, String s, String go) {
    notifs.insert(0, Notif('n${_uid++}', ic, t, s, go));
    unread++;
  }

  void addEvent(Ev e) => events.add(e);

  // ------------------------------------------------------------ 이동

  void go(String t, [String soc = 'hub']) {
    tab = t;
    social = soc;
    push = false;
    banner = null;
  }

  void resetFlows() {
    _searchT?.cancel();
    meal = MealState();
    meet = MeetState();
    play = PlayState();
    mealMsgC.clear();
    playTitleC.clear();
  }

  void setTab(String v) {
    go(v);
    onboard = null;
    if (v == 'social') resetFlows();
    _n();
  }

  /// 안드로이드 뒤로가기. 처리했으면 true, 앱을 나가도 되면 false.
  bool back() {
    if (!loggedIn) {
      if (authPage == 'signup') {
        backToLogin();
        return true;
      }
      return false;
    }
    if (push) {
      push = false;
      _n();
      return true;
    }
    if (onboard == 1) {
      onboard = 0;
      _n();
      return true;
    }
    if (onboard != null) return false;
    if (tab == 'social' && social != 'hub') {
      if (social == 'play' && play.view == 'new') {
        play.view = 'list';
      } else {
        social = 'hub';
        resetFlows();
      }
      _n();
      return true;
    }
    if (tab != 'cal') {
      go('cal');
      _n();
      return true;
    }
    return false;
  }

  void jump(int i) {
    push = false;
    banner = null;
    resetFlows();
    if (i == 0) {
      loggedIn = false;
      loginBusy = false;
      authPage = 'login';
      onboard = null;
      verify = 'idle';
      _n();
      return;
    }
    onboard = null;
    if (i == 1) {
      go('cal');
      calView = 'week';
      sel = kToday;
      filter = 'all';
    }
    if (i == 2) go('reco');
    if (i == 3) go('social', 'meal');
    if (i == 4) go('social', 'meeting');
    if (i == 5) go('social', 'play');
    if (i == 6) push = true;
    _n();
  }

  void resetAll() {
    _searchT?.cancel();
    _toastT?.cancel();
    _bannerT?.cancel();
    _loginT?.cancel();
    _signupT?.cancel();
    _init();
    _n();
  }

  // ------------------------------------------------------------ 로그인 (가짜 · 채널톡 연동 예정)

  void toggleAutoLogin() {
    autoLogin = !autoLogin;
    _n();
  }

  void toggleLoginObscure() {
    loginObscure = !loginObscure;
    _n();
  }

  /// 학번/비번을 검사하지 않고, 잠시 기다렸다가 메인으로 들어가요.
  void fakeLogin() {
    if (loginBusy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    loginBusy = true;
    _n();
    _loginT?.cancel();
    _loginT = Timer(const Duration(milliseconds: 550), () {
      loginBusy = false;
      loggedIn = true;
      onboard = null;
      go('cal');
      _n();
    });
  }

  /// 회원가입 시안으로 이동해요. 채널톡 연동은 아직 없습니다.
  void goSignup() {
    _signupT?.cancel();
    authPage = 'signup';
    signupPhoto = 'idle';
    signupBusy = false;
    signupGender = 'm';
    signupNameC.clear();
    signupIdC.clear();
    signupDeptC.clear();
    _n();
  }

  void backToLogin() {
    _signupT?.cancel();
    authPage = 'login';
    signupBusy = false;
    signupPhoto = 'idle';
    _n();
  }

  void setSignupGender(String v) {
    signupGender = v;
    _n();
  }

  /// 카메라/앨범을 실제로 열지 않고, 학생증을 읽은 척한 뒤 예시 값을 채워요.
  void fakeSignupPhoto() {
    if (signupPhoto == 'scanning') return;
    FocusManager.instance.primaryFocus?.unfocus();
    signupPhoto = 'scanning';
    _n();
    _signupT?.cancel();
    _signupT = Timer(const Duration(milliseconds: 800), () {
      signupPhoto = 'done';
      signupNameC.text = '혜인';
      signupIdC.text = '20231234';
      signupDeptC.text = '소프트웨어학과';
      _n();
    });
  }

  void submitSignup() {
    if (signupBusy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final name = signupNameC.text.trim();
    final id = signupIdC.text.trim();
    final dept = signupDeptC.text.trim();
    if (name.isEmpty || id.isEmpty || dept.isEmpty) {
      showToast('이름, 학번, 학과를 입력해주세요');
      return;
    }
    signupBusy = true;
    _n();
    _signupT?.cancel();
    _signupT = Timer(const Duration(milliseconds: 450), () {
      studentIdC.text = id;
      signupBusy = false;
      authPage = 'login';
      showToast('계정이 만들어졌어요. 로그인해주세요');
    });
  }

  void logout() {
    _loginT?.cancel();
    loggedIn = false;
    loginBusy = false;
    authPage = 'login';
    _n();
  }

  // ------------------------------------------------------------ 온보딩

  void verifyShot() {
    verify = 'scanning';
    _n();
    Timer(const Duration(milliseconds: 900), () {
      if (verify == 'scanning') {
        verify = 'done';
        _n();
      }
    });
  }

  void obNext() {
    onboard = 1;
    _n();
  }

  void obSkip() {
    onboard = null;
    go('cal');
    _n();
  }

  void obDone() {
    onboard = null;
    go('cal');
    showToast('끝났어요! 이제 앱이 알아서 소식을 모아요');
  }

  void toggleCat(String k) {
    cats[k] = !(cats[k] ?? false);
    _n();
  }

  void toggleField(String k) {
    fields[k] = !(fields[k] ?? false);
    _n();
  }

  void toggleConn(String k) {
    conn[k] = !(conn[k] ?? false);
    _n();
  }

  // ------------------------------------------------------------ 달력

  void setView(String v) {
    calView = v;
    if (v == 'week' && !kWeek.map((d) => '9-$d').contains(sel)) sel = kToday;
    _n();
  }

  void selectDay(String k) {
    sel = k;
    _n();
  }

  void setFilter(String k) {
    filter = k;
    _n();
  }

  void deleteEvent(String id) {
    events.removeWhere((e) => e.id == id);
    showToast('일정을 지웠어요');
  }

  void toggleOpp(String id) {
    final o = kOpps.firstWhere((x) => x.id == id);
    if (isAdded(id)) {
      events.removeWhere((e) => e.id == 'opp-$id');
      showToast('달력에서 뺐어요');
    } else {
      events.add(oppEvent(o));
      if (o.key.startsWith('9-')) sel = o.key;
      showToast('${shortDate(o.key)} 마감일을 달력에 추가했어요');
    }
  }

  void openShare(String oppId) {
    shareOpp = oppId;
    _n();
  }

  void toggleShareTo(int i) {
    shareTo[i] = !(shareTo[i] ?? false);
    _n();
  }

  int shareCount() => shareTo.values.where((v) => v).length;

  void shareSend() => showToast('${shareCount()}명에게 “같이 신청하자”를 보냈어요');

  // 일정 추가 창
  void prepareAdd() {
    addDateC.text = shortDate(sel).split(' ')[0];
    addNewOpen = false;
  }

  void setAddType(String v) {
    addType = v;
    _n();
  }

  void toggleAddNew() {
    addNewOpen = !addNewOpen;
    _n();
  }

  void setAddTime(bool start, String v) {
    if (start) {
      addStart = v;
    } else {
      addEnd = v;
    }
    _n();
  }

  /// 새 종류 추가. 문제가 있으면 안내 문구를, 성공하면 null 을 돌려줘요.
  String? addCustomType() {
    final name = addNewC.text.trim();
    String norm(String x) => x.replaceAll(RegExp(r'\s'), '');
    if (name.isEmpty) return '종류 이름을 적어주세요';
    if (filterList().any((e) => norm(e.$2) == norm(name))) return '이미 있는 종류예요';
    if (customTypes.length >= kMaxCustom) return '종류는 6개까지 추가할 수 있어요';
    final id = 'x${_uid++}';
    customTypes.add(CustomType(id, name, customTypes.length % 6));
    addType = id;
    addNewOpen = false;
    addNewC.clear();
    _n();
    return null;
  }

  /// 일정 추가. 문제가 있으면 안내 문구를, 성공하면 null 을 돌려줘요.
  String? submitAdd() {
    final key = parseSeptDate(addDateC.text);
    if (key == null) return '9월 안의 날짜를 입력해주세요 (예: 9/28)';
    final job = addType == 'job';
    final h = job ? hoursBetween(addStart, addEnd) : 0.0;
    final title = addTitleC.text.trim();
    events.add(Ev(
      id: 'e${_uid++}',
      key: key,
      t: addStart.isEmpty ? '18:00' : addStart,
      end: addEnd,
      type: addType,
      title: title.isEmpty ? typeName(addType) : title,
      sub: job ? '${fmtH(h)}시간 · 직접 입력' : '직접 입력',
      mine: true,
      hours: job ? (h == 0 ? 2 : h) : null,
    ));
    sel = key;
    addTitleC.clear();
    if (calView == 'week' && !kWeek.map((d) => '9-$d').contains(key)) calView = 'month';
    showToast('달력에 추가했어요');
    return null;
  }

  // ------------------------------------------------------------ 밥약

  void mealNow() {
    go('social', 'meal');
    resetFlows();
    meal.time = '지금';
    _n();
  }

  void mealPickNow() {
    meal.time = '지금';
    meal.date = kToday;
    _n();
  }

  /// 스크롤 칸을 사람이 직접 돌렸을 때
  void mealWheel({String? date, String? clock}) {
    if (date != null) meal.date = date;
    if (clock != null) meal.clock = clock;
    meal.time = meal.clock;
    _n();
  }

  void mealMode(String v) {
    meal.mode = v;
    _n();
  }

  void mealSend(String v) {
    meal.send = v;
    _n();
  }

  void mealScope(String v) {
    meal.scope = v;
    _n();
  }

  void mealToggleGrp(String v) {
    if (v == 'team') {
      meal.team = !meal.team;
    } else {
      meal.kakao = !meal.kakao;
    }
    _n();
  }

  void mealToggleAnon() {
    meal.anon = !meal.anon;
    _n();
  }

  void mealSuggest(String v) {
    mealMsgC.text = v;
    mealMsgC.selection = TextSelection.collapsed(offset: v.length);
    _n();
  }

  void mealSubmit() {
    final m = meal;
    m.msg = mealMsgC.text.trim();
    if (m.mode == 'party') {
      m.step = 'posted';
      _n();
      return;
    }
    m.step = 'searching';
    _searchT?.cancel();
    _searchT = Timer(const Duration(milliseconds: 1500), () {
      if (meal.step != 'searching') return;
      meal.step = 'matched';
      showBanner(BannerData(
        t: 'job',
        ic: 'utensils',
        k: '밥약 매칭',
        title: '3명이 같이 먹기로 했어요!',
        body: '${mealAt()} · 김민준, 이서연, 박지훈${meal.msg.isEmpty ? '' : ' · “${meal.msg}”'}',
        cta: '약속 확인',
        go: 'social',
      ));
      _notify('utensils', '밥약 매칭이 성사됐어요', '3명이 같이 먹기로 했어요', 'social');
      _n();
    });
    _n();
  }

  void mealAddToCalendar() {
    final m = meal;
    events.add(Ev(
      id: 'e${_uid++}',
      key: m.date,
      t: mealClock(),
      end: '',
      type: 'meet',
      title: '밥약',
      sub: m.msg.isEmpty ? '김민준 외 2명' : '김민준 외 2명 · ${m.msg}',
      mine: true,
    ));
    showToast('달력에 밥약을 추가했어요');
  }

  void mealReset() {
    meal = MealState();
    mealMsgC.clear();
    _n();
  }

  void reqSetWho(String v) {
    reqWho = v;
    _n();
  }

  void reqToggleAnon() {
    reqAnon = !reqAnon;
    _n();
  }

  void reqSend() => showToast('밥약 신청을 보냈어요. 답장이 오면 배너로 알려드려요');

  // ------------------------------------------------------------ 사회생활 이동

  void openSocial(String v) {
    resetFlows();
    if (v == 'playNew') {
      social = 'play';
      play.view = 'new';
    } else {
      social = v;
    }
    _n();
  }

  // ------------------------------------------------------------ 과팅

  void meetWheel({String? date, String? from, String? to}) {
    if (date != null) meet.date = date;
    if (from != null) {
      meet.from = from;
      if (toMin(meet.to) <= toMin(from)) meet.to = fromMin(toMin(from) + 60);
    }
    if (to != null) {
      meet.to = to;
      if (toMin(to) <= toMin(meet.from)) {
        final f = toMin(to) - 60;
        meet.from = fromMin(f < 540 ? 540 : f);
      }
    }
    _n();
  }

  void meetFind() {
    meet.step = 'searching';
    _searchT?.cancel();
    _searchT = Timer(const Duration(milliseconds: 1200), () {
      if (meet.step == 'searching') {
        meet.step = 'found';
        _n();
      }
    });
    _n();
  }

  void meetAccept(int i) {
    final t = meetTeams()[i];
    final when = '${shortDate(meet.date)} ${t.from}–${t.to}';
    meet.step = 'matched';
    meet.winFrom = t.from;
    meet.winTo = t.to;
    events.add(Ev(
      id: 'e${_uid++}',
      key: meet.date,
      t: t.from,
      end: t.to,
      type: 'meet',
      title: '과팅 3 : 3',
      sub: '${t.name.split(' ')[0]} 팀과 함께',
      mine: true,
    ));
    showBanner(BannerData(t: 'meet', ic: 'heart', k: '과팅 매칭', title: '상대 팀과 이어졌어요', body: '$when · 3 : 3', cta: '달력 보기', go: 'cal'));
    _notify('heart', '과팅 매칭이 성사됐어요', when, 'cal');
    _n();
  }

  void meetWarn() {
    meet.warned = true;
    showToast('익명 경고를 보냈어요');
  }

  void meetReset() {
    meet = MeetState();
    _n();
  }

  // ------------------------------------------------------------ 놀기

  void playJoin(String id) {
    final x = kPlays.firstWhere((p) => p.id == id);
    play.joined[id] = true;
    events.add(Ev(id: 'e${_uid++}', key: x.key ?? kToday, t: x.time, end: x.end, type: 'meet', title: x.title, sub: '놀기 · 참여 확정', mine: true));
    showBanner(BannerData(t: 'class', ic: 'film', k: '놀기 매칭', title: '같이 갈 사람이 모였어요', body: '${x.when} · ${x.title}', cta: '달력 보기', go: 'cal'));
  }

  void playSetScope(String v) {
    play.scope = v;
    _n();
  }

  void playSetAnon(bool v) {
    play.anon = v;
    _n();
  }

  void playSetTime(bool start, String v) {
    if (start) {
      playStart = v;
    } else {
      playEnd = v;
    }
    _n();
  }

  void playSubmit() {
    final t = playTitleC.text.trim();
    events.add(Ev(
      id: 'e${_uid++}',
      key: kToday,
      t: playStart.isEmpty ? '19:00' : playStart,
      end: playEnd,
      type: 'meet',
      title: t.isEmpty ? '오늘 영화 보러 갈 사람?' : t,
      sub: '내가 올린 모임',
      mine: true,
    ));
    play.view = 'done';
    playTitleC.clear();
    _n();
  }

  void playBackToList() {
    play = PlayState();
    _n();
  }

  // ------------------------------------------------------------ 푸시 · 배너

  void showPush() {
    push = true;
    _n();
  }

  void hidePush() {
    push = false;
    _n();
  }

  void pushYes() {
    push = false;
    go('cal');
    sel = kToday;
    events.add(Ev(id: 'e${_uid++}', key: kToday, t: '12:30', end: '13:00', type: 'meet', title: '밥약', sub: '익명의 새내기와', mine: true));
    showBanner(const BannerData(t: 'job', ic: 'utensils', k: '밥약 확정', title: '12:30 밥약이 달력에 들어갔어요', body: '수락하면 서로 이름이 공개돼요'));
  }

  void closeBanner() {
    banner = null;
    _n();
  }

  void bannerGo(String g) {
    banner = null;
    if (g == 'cal') go('cal');
    if (g == 'social') go('social');
    _n();
  }

  void notifGo(String g) {
    if (g == 'reco') {
      go('reco');
    } else if (g == 'push') {
      push = true;
    } else if (g == 'cal') {
      go('cal');
    } else {
      go('social');
    }
    _n();
  }

  void readNotifs() {
    unread = 0;
    _n();
  }

  /// 화면 뒤에서 바뀐 값을 화면에 알려줘요 (시트 안에서 쓰는 도우미)
  void refresh() => _n();

  @override
  void dispose() {
    _toastT?.cancel();
    _bannerT?.cancel();
    _searchT?.cancel();
    _loginT?.cancel();
    _signupT?.cancel();
    studentIdC.dispose();
    passwordC.dispose();
    signupNameC.dispose();
    signupIdC.dispose();
    signupDeptC.dispose();
    mealMsgC.dispose();
    addTitleC.dispose();
    addDateC.dispose();
    addNewC.dispose();
    reqMsgC.dispose();
    playTitleC.dispose();
    super.dispose();
  }
}

/// 앱 어디서든 쓰는 상태 하나
final AppState app = AppState();
