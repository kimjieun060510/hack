import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

/// 색 · 글꼴 · 아이콘을 한곳에 모아둔 파일이에요.
/// 색을 바꾸고 싶으면 아래 Pal.light / Pal.dark 의 값을 고치면 돼요.

Color _c(int rgb) => Color(0xFF000000 | rgb);

/// 일정 종류 하나의 색 (c: 진한 색, bg: 배경색, ink: 글자색)
class TS {
  final Color c, bg, ink;
  const TS(this.c, this.bg, this.ink);
}

class Pal {
  final Color paper, surface, ink, mut, line, seg;
  final Color pri, priInk, priSoft, priLine, priText;
  final Color featBg, featInk, featMut, featBtn, featBtnInk;
  final Color heroBg, heroInk, heroMut, danger, lock;
  final Map<String, TS> types;
  final List<TS> custom;

  const Pal({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.mut,
    required this.line,
    required this.seg,
    required this.pri,
    required this.priInk,
    required this.priSoft,
    required this.priLine,
    required this.priText,
    required this.featBg,
    required this.featInk,
    required this.featMut,
    required this.featBtn,
    required this.featBtnInk,
    required this.heroBg,
    required this.heroInk,
    required this.heroMut,
    required this.danger,
    required this.lock,
    required this.types,
    required this.custom,
  });

  static final Pal light = Pal(
    paper: _c(0xF7F9F7),
    surface: _c(0xFFFFFF),
    ink: _c(0x15201B),
    mut: _c(0x55625B),
    line: _c(0xDCE4DF),
    seg: _c(0xE7EDE9),
    pri: _c(0x1F6B4A),
    priInk: _c(0xFFFFFF),
    priSoft: _c(0xE2F1E9),
    priLine: _c(0xBFDCCB),
    priText: _c(0x17472F),
    featBg: _c(0x17472F),
    featInk: _c(0xFFFFFF),
    featMut: _c(0xCDE5D7),
    featBtn: _c(0xFFFFFF),
    featBtnInk: _c(0x17472F),
    heroBg: _c(0xFBEBD0),
    heroInk: _c(0x4A3208),
    heroMut: _c(0x6E5320),
    danger: _c(0xB4381F),
    lock: _c(0x123B2A),
    types: {
      'class': TS(_c(0x2F62D6), _c(0xE5ECFB), _c(0x1D3F94)),
      'assign': TS(_c(0xC4452C), _c(0xFBE8E2), _c(0x8F2E18)),
      'job': TS(_c(0xB7791F), _c(0xFAEFD7), _c(0x6B4A0F)),
      'meet': TS(_c(0x8A47B8), _c(0xF0E6F8), _c(0x5C2A80)),
      'dept': TS(_c(0x4B5563), _c(0xE9ECEF), _c(0x333B47)),
      'opp': TS(_c(0x1F6B4A), _c(0xE2F1E9), _c(0x17472F)),
    },
    custom: [
      TS(_c(0x0E8A8A), _c(0xDDF1F1), _c(0x0B5C5C)),
      TS(_c(0xC2457D), _c(0xFBE4EE), _c(0x862A55)),
      TS(_c(0x6E8B1F), _c(0xEDF3D9), _c(0x465A0F)),
      TS(_c(0x5B4BD6), _c(0xE9E6FB), _c(0x3B2E96)),
      TS(_c(0xD9601F), _c(0xFCE9DC), _c(0x8F3E0F)),
      TS(_c(0x2A8FBF), _c(0xDFF0F8), _c(0x17607F)),
    ],
  );

  static final Pal dark = Pal(
    paper: _c(0x101713),
    surface: _c(0x18211B),
    ink: _c(0xE8F0EB),
    mut: _c(0x9DABA4),
    line: _c(0x26332B),
    seg: _c(0x212D25),
    pri: _c(0x56C795),
    priInk: _c(0x062015),
    priSoft: _c(0x1B3327),
    priLine: _c(0x2C5A44),
    priText: _c(0xBFE8D3),
    featBg: _c(0x1D4A34),
    featInk: _c(0xF2FAF5),
    featMut: _c(0xB5D3C2),
    featBtn: _c(0xE8F0EB),
    featBtnInk: _c(0x0F2A1D),
    heroBg: _c(0x3A2E14),
    heroInk: _c(0xF8E7C4),
    heroMut: _c(0xD8BF8A),
    danger: _c(0xF08A72),
    lock: _c(0x0B241A),
    types: {
      'class': TS(_c(0x7AA2FF), _c(0x1A2540), _c(0xB7CBFF)),
      'assign': TS(_c(0xF08A72), _c(0x3A1F19), _c(0xFFC0B0)),
      'job': TS(_c(0xE4B25A), _c(0x3A2E14), _c(0xF6D89B)),
      'meet': TS(_c(0xC79BEA), _c(0x2C1F3A), _c(0xE3C8F7)),
      'dept': TS(_c(0xA8B2BD), _c(0x232A30), _c(0xCDD5DC)),
      'opp': TS(_c(0x56C795), _c(0x1B3327), _c(0xBFE8D3)),
    },
    custom: [
      TS(_c(0x5CCFCF), _c(0x163333), _c(0xB5EBEB)),
      TS(_c(0xF08DB8), _c(0x3A1B29), _c(0xFAC3DC)),
      TS(_c(0xB4D35A), _c(0x29300F), _c(0xD9EBA3)),
      TS(_c(0xA79BFF), _c(0x24204A), _c(0xD0CAFF)),
      TS(_c(0xFFA46B), _c(0x3B2314), _c(0xFFCFAE)),
      TS(_c(0x6CC3EE), _c(0x15303D), _c(0xB5E2F7)),
    ],
  );

  static Pal of(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark ? dark : light;
}

/// 제목용 글꼴(주아체). 본문은 폰 기본 글꼴을 써요.
TextStyle disp(double size, Color color, {double height = 1.25}) =>
    TextStyle(fontFamily: 'Jua', fontSize: size, color: color, height: height);

ThemeData buildTheme(Pal p, Brightness b) {
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: ColorScheme.fromSeed(seedColor: p.pri, brightness: b).copyWith(
      primary: p.pri,
      onPrimary: p.priInk,
      surface: p.surface,
      onSurface: p.ink,
    ),
    scaffoldBackgroundColor: p.paper,
    canvasColor: p.paper,
    splashFactory: InkRipple.splashFactory,
    textTheme: Typography.material2021(platform: defaultTargetPlatform).black.apply(bodyColor: p.ink, displayColor: p.ink),
  );
}

/// 이름으로 아이콘을 찾아요.
IconData icon(String name) {
  switch (name) {
    case 'bell':
      return Icons.notifications_none;
    case 'leaf':
      return Icons.eco_outlined;
    case 'sparkle':
      return Icons.auto_awesome_outlined;
    case 'calendar':
      return Icons.calendar_month_outlined;
    case 'users':
      return Icons.groups_outlined;
    case 'utensils':
      return Icons.restaurant;
    case 'heart':
      return Icons.favorite_border;
    case 'film':
      return Icons.movie_outlined;
    case 'plus':
      return Icons.add;
    case 'check':
      return Icons.check;
    case 'back':
      return Icons.chevron_left;
    case 'chev':
      return Icons.chevron_right;
    case 'ext':
      return Icons.open_in_new;
    case 'share':
      return Icons.ios_share;
    case 'camera':
      return Icons.photo_camera_outlined;
    case 'shield':
      return Icons.shield_outlined;
    case 'idcard':
      return Icons.badge_outlined;
    case 'x':
      return Icons.close;
    case 'user':
      return Icons.person_outline;
    case 'clock':
      return Icons.schedule;
    default:
      return Icons.circle_outlined;
  }
}
