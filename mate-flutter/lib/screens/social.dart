import 'package:flutter/material.dart';

import '../data.dart';
import '../sheets.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// 사회생활 탭: 허브 → 밥약 / 과팅 / 놀기

class SocialScreen extends LiveView {
  const SocialScreen({super.key});

  @override
  Widget body(BuildContext context) {
    switch (app.social) {
      case 'meal':
        return const MealScreen();
      case 'meeting':
        return const MeetScreen();
      case 'play':
      case 'playNew':
        return const PlayScreen();
      default:
        return const HubScreen();
    }
  }
}

/// 서브 화면 공통 틀: 머리글 + 본문 + (아래 고정 버튼)
class _SubPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? cta;
  const _SubPage({required this.title, required this.children, this.cta});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SafeArea(bottom: false, child: SubHeader(title)),
      Expanded(child: Body(children: children)),
      if (cta != null) CtaBar(children: cta!),
    ]);
  }
}

Widget _searching(String title, String body) => BigMessage(lead: const Spinner(), title: title, body: body);

// ------------------------------------------------------------------ 허브

class HubScreen extends LiveView {
  const HubScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    final done = app.todayMealDone();
    return Column(children: [
      SafeArea(bottom: false, child: TitleHeader('사회생활')),
      Expanded(
        child: Body(children: [
          Txt('혼자 먹지 말고, 혼자 놀지 말고. 지금 비어있는 새내기와 바로 연결돼요.', size: 13, muted: true),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: p.heroBg, borderRadius: BorderRadius.circular(24)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Heading('지금 밥 먹을 사람?', size: 28, color: p.heroInk),
              const SizedBox(height: 12),
              Text('내 달력에서 비어있는 시간을 보고, 같은 시간에 비어있는 새내기를 찾아드려요.', style: TextStyle(fontSize: 14, height: 1.55, color: p.heroMut)),
              const SizedBox(height: 12),
              Row(children: [
                AvatarStack([for (final f in kFriends) Avatar(f.n[0], style: p.types[f.t], size: 32)]),
                const SizedBox(width: 2),
                Expanded(child: Text('3명이 12:10–13:20에 비어 있어요', style: TextStyle(fontSize: 13, color: p.heroInk))),
              ]),
              const SizedBox(height: 12),
              Btn('밥약 찾기', ic: 'utensils', kind: 'hero', onTap: app.mealNow),
            ]),
          ),
          _Opt(type: 'meet', ic: 'heart', title: '과팅', sub: '우리 학교 3명 팀으로 비슷한 시간대의 팀과 만나요', onTap: () => app.openSocial('meeting')),
          _Opt(type: 'class', ic: 'film', title: '놀기', sub: '“오늘 영화 보러 갈 사람?” 시간 맞는 새내기 모으기', onTap: () => app.openSocial('play')),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SectionHead('오늘 함께한 끼니', trailing: '${done ? 2 : 1} / 3', trailingColor: p.pri),
              const SizedBox(height: 10),
              Meter(on: done ? 2 : 1),
              const SizedBox(height: 10),
              Txt(done ? '점심 밥약이 달력에 들어갔어요. 저녁도 같이 먹어요.' : '내 달력 기준 오늘 저녁 6시 이후가 비어있어요. 저녁 밥약 어때요?', size: 13, muted: true),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

class _Opt extends StatelessWidget {
  final String type, ic, title, sub;
  final VoidCallback onTap;
  const _Opt({required this.type, required this.ic, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final t = p.types[type]!;
    return Material(
      color: t.bg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: p.surface, shape: BoxShape.circle), child: Icon(icon(ic), size: 24, color: t.ink)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Heading(title, size: 20, color: p.ink),
                Text(sub, style: TextStyle(fontSize: 13, height: 1.5, color: p.mut)),
              ]),
            ),
            Icon(icon('chev'), size: 22, color: p.mut),
          ]),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ 밥약

const List<String> _mealSugs = ['같이 밥 먹어요!', '메뉴는 편하게 정해요', '혼밥 말고 같이 먹어요'];

String _dateLabel(String k) => '${k == kToday ? '오늘' : kDayN[dowOf(k)]} ${k.replaceFirst('-', '/')}';

class MealScreen extends LiveView {
  const MealScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final m = app.meal;
    if (m.step == 'searching') {
      return _SubPage(title: '밥약', children: [_searching('비어있는 새내기를 찾고 있어요', '내 달력과 친구들의 달력을 비교하는 중이에요.')]);
    }
    if (m.step == 'posted') {
      return _SubPage(title: '밥약', children: [
        const BigMessage(lead: BigIcon('check'), title: '게시판에 올렸어요', body: '푸시는 가지 않아요. 관심 있는 새내기가 직접 신청하면 배너로 알려드릴게요.'),
        Btn('처음으로', kind: 'line', onTap: app.mealReset),
      ]);
    }
    if (m.step == 'matched') return _MealMatched();
    return _MealForm();
  }
}

class _MealMatched extends LiveView {
  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    final m = app.meal;
    final done = app.mealDone();
    return _SubPage(title: '밥약', children: [
      BigMessage(
        lead: const BigIcon('utensils'),
        title: '3명이 같이 먹기로 했어요!',
        body: '${app.mealAt()} · ${m.anon ? '익명으로 보냈고, 수락하면 이름이 공개돼요' : '실명으로 보냈어요'}',
        extra: m.msg.isEmpty ? null : Padding(padding: const EdgeInsets.only(top: 4), child: Txt('“${m.msg}”', align: TextAlign.center)),
      ),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          for (var i = 0; i < kFriends.length; i++)
            PersonRow(first: i == 0, avatar: Avatar(kFriends[i].n[0], style: p.types[kFriends[i].t]), name: kFriends[i].n, sub: kFriends[i].d, trailing: const OkBadge('수락')),
        ]),
      ),
      Btn(done ? '달력에 추가했어요' : '달력에 추가', ic: done ? 'check' : 'calendar', onTap: done ? null : app.mealAddToCalendar),
      Btn('받는 새내기 화면 보기', ic: 'bell', kind: 'line', onTap: app.showPush),
      LinkBtn('처음으로', onTap: app.mealReset),
    ]);
  }
}

class _MealForm extends LiveView {
  @override
  Widget body(BuildContext context) {
    final m = app.meal;
    final isF = m.mode == 'friends';
    final now = m.time == '지금';
    return _SubPage(
      title: '밥약 보내기',
      cta: [Btn(app.mealCta(), ic: 'utensils', onTap: app.mealSubmit)],
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SectionHead('언제 먹을까요?', trailing: '스크롤해서 고르세요'),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: PillChip('지금 바로', on: now, leading: 'utensils', onTap: app.mealPickNow)),
          const SizedBox(height: 10),
          Opacity(
            opacity: now ? 0.45 : 1,
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: WheelCol(
                    label: '날짜',
                    value: m.date,
                    items: [for (var i = 0; i < 10; i++) ('9-${21 + i}', _dateLabel('9-${21 + i}'))],
                    onUserChange: (v) => app.mealWheel(date: v),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: WheelCol(
                    label: '시간',
                    value: m.clock,
                    items: [for (final t in timeOpts('08:00', '23:30')) (t, t)],
                    onUserChange: (v) => app.mealWheel(clock: v),
                  ),
                ),
              ]),
            ),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Txt('누구와 먹을까요?', bold: true, size: 16),
          const SizedBox(height: 10),
          ChipGrid(cols: 2, children: [
            _Choice(title: '친구에게 보내기', sub: '우리 조·카톡 친구에게 푸시로 바로', on: isF, onTap: () => app.mealMode('friends')),
            _Choice(title: '파티 열기', sub: '같은 학교·과·랜덤 모집, 푸시 없이 게시만', on: !isF, onTap: () => app.mealMode('party')),
          ]),
          const SizedBox(height: 10),
          if (isF) ...[
            ChipGrid(cols: 2, children: [
              PillChip('우리 조', expand: true, on: m.team, onTap: () => app.mealToggleGrp('team')),
              PillChip('카톡 친구', expand: true, on: m.kakao, onTap: () => app.mealToggleGrp('kakao')),
            ]),
            const SizedBox(height: 8),
            ChipGrid(cols: 2, children: [
              PillChip('자동 푸시', expand: true, on: m.send == 'auto', onTap: () => app.mealSend('auto')),
              PillChip('직접 골라 보내기', expand: true, on: m.send == 'manual', onTap: () => app.mealSend('manual')),
            ]),
            const SizedBox(height: 8),
            Txt(m.send == 'auto' ? '받는 사람 폰 화면 위로 “밥 먹자”가 바로 떠요.' : '보낼 친구를 내가 직접 골라요.', size: 13, muted: true),
          ] else ...[
            ChipGrid(cols: 3, children: [
              for (final s in const [('school', '같은 학교'), ('dept', '같은 과'), ('random', '랜덤')]) PillChip(s.$2, expand: true, on: m.scope == s.$1, onTap: () => app.mealScope(s.$1)),
            ]),
            const SizedBox(height: 8),
            const Txt('게시판에만 올라가고, 관심 있는 사람이 직접 눌러 신청해요.', size: 13, muted: true),
          ],
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SectionHead('한마디 남기기', trailing: '선택 · 40자까지'),
          const SizedBox(height: 10),
          AppInput(controller: app.mealMsgC, maxLength: 40, hint: isF ? '예: 학식에서 같이 먹을래요?' : '예: 조용히 밥 먹을 사람 구해요'),
          const SizedBox(height: 10),
          ChipWrap(children: [for (final t in _mealSugs) PillChip(t, on: false, onTap: () => app.mealSuggest(t))]),
        ]),
        SwitchCard(title: '익명으로 보내기', sub: '부끄러움도, 무반응 걱정도 없어요', on: m.anon, onTap: app.mealToggleAnon),
        LinkBtn('직접 말하기 부끄럽다면 · ', bold: '밥약 신청하기', onTap: () => showReqSheet(context)),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  final String title, sub;
  final bool on;
  final VoidCallback onTap;
  const _Choice({required this.title, required this.sub, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Semantics(
      button: true,
      selected: on,
      child: Container(
        decoration: BoxDecoration(color: on ? p.priSoft : p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: on ? p.pri : p.line, width: on ? 1.5 : 1)),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: on ? p.priText : p.ink)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 12, height: 1.45, color: p.mut)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ 과팅

class MeetScreen extends LiveView {
  const MeetScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    final m = app.meet;
    if (m.step == 'searching') {
      return _SubPage(title: '과팅', children: [_searching('비슷한 시간대의 팀을 찾고 있어요', '우리 팀 3명의 가능한 시간을 비교하는 중이에요.')]);
    }
    if (m.step == 'found') {
      final teams = app.meetTeams();
      final colors = [p.types['meet']!, p.types['class']!, p.types['job']!];
      return _SubPage(title: '과팅 팀 찾음', children: [
        const Txt('가능한 시간이 겹치는 팀이에요. 마음에 드는 팀에 수락하세요.', size: 13, muted: true),
        for (var i = 0; i < teams.length; i++)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                AvatarStack([for (var j = 0; j < 3; j++) Avatar(const ['김', '이', '박'][j], style: colors[j], size: 36)]),
                const Spacer(),
                Pill('겹치는 시간 ${fmtH(teams[i].overlap)}시간', style: p.types['meet']),
              ]),
              const SizedBox(height: 10),
              Txt(teams[i].name, bold: true, size: 16),
              Txt('${shortDate(m.date)} ${teams[i].from}–${teams[i].to} · 3 : 3 과팅', size: 13, muted: true),
              const SizedBox(height: 10),
              Btn('수락하기', small: true, onTap: () => app.meetAccept(i)),
            ]),
          ),
        LinkBtn('조건 다시 정하기', onTap: app.meetReset),
      ]);
    }
    if (m.step == 'matched') {
      final t = p.types['meet']!;
      return _SubPage(title: '과팅 매칭', children: [
        BigMessage(lead: BigIcon('heart', bg: t.bg, fg: t.c), title: '과팅 매칭이 성사됐어요!', body: '${shortDate(m.date)} ${m.winFrom ?? ''}–${m.winTo ?? ''} · 3 : 3\n달력에 약속으로 넣어뒀어요.'),
        SafeCard(
          title: '만난 뒤에 불편했다면',
          body: '익명으로 경고를 보낼 수 있어요. 상대 팀에는 누가 보냈는지 알려지지 않아요.',
          extra: Btn(m.warned ? '익명 경고를 보냈어요' : '익명 경고 보내기', kind: 'line', small: true, onTap: m.warned ? null : app.meetWarn),
        ),
        Btn('받는 팀 화면 보기', ic: 'bell', kind: 'line', onTap: app.showPush),
        LinkBtn('처음으로', onTap: app.meetReset),
      ]);
    }
    final members = [
      ('나', '소프트웨어학과 · 26학번', TS(p.pri, p.priSoft, p.priText), '팀장'),
      ('이서윤', '소프트웨어학과 · 26학번', p.types['meet']!, ''),
      ('박도현', '전자전기공학부 · 26학번', p.types['class']!, ''),
    ];
    return _SubPage(
      title: '과팅',
      cta: [Btn('비슷한 시간대 과팅 팀 찾기', ic: 'heart', onTap: app.meetFind)],
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SectionHead('우리 팀 3명', trailing: '학과·학번만 보여요'),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (var i = 0; i < members.length; i++)
                PersonRow(
                  first: i == 0,
                  avatar: Avatar(members[i].$1[0], style: members[i].$3),
                  name: members[i].$1,
                  sub: members[i].$2,
                  trailing: members[i].$4.isNotEmpty ? OkBadge(members[i].$4) : Icon(icon('check'), size: 20, color: p.pri),
                ),
            ]),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SectionHead('언제 가능해요?', trailing: '비슷한 시간대의 팀과 이어줘요'),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(children: [
              Expanded(
                flex: 5,
                child: WheelCol(
                  label: '날짜',
                  value: m.date,
                  items: [for (var i = 0; i < 9; i++) ('9-${22 + i}', '${kDayN[dowOf('9-${22 + i}')]} 9/${22 + i}')],
                  onUserChange: (v) => app.meetWheel(date: v),
                ),
              ),
              Expanded(
                flex: 3,
                child: WheelCol(label: '시작', value: m.from, items: [for (final t in timeOpts('09:00', '23:30')) (t, t)], onUserChange: (v) => app.meetWheel(from: v)),
              ),
              Padding(padding: const EdgeInsets.only(top: 22), child: Text('~', style: TextStyle(fontSize: 18, color: p.mut))),
              Expanded(
                flex: 3,
                child: WheelCol(label: '끝', value: m.to, items: [for (final t in timeOpts('09:30', '24:00')) (t, t)], onUserChange: (v) => app.meetWheel(to: v)),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Txt(app.meetSummary(), size: 13, muted: true, align: TextAlign.center),
        ]),
        SafeCard(
          title: '매너 지킴이',
          body: '무례한 상대는 익명으로 경고를 보낼 수 있어요. 경고가 3번 쌓이면 과팅이 몇 주간 정지돼요.',
          extra: Row(children: [const Expanded(child: Meter()), const SizedBox(width: 12), Txt('내 경고 0 / 3', size: 12, muted: true)]),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ 놀기

class PlayScreen extends LiveView {
  const PlayScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    final pl = app.play;
    if (pl.view == 'done') {
      return _SubPage(title: '놀기', children: [
        const BigMessage(lead: BigIcon('check'), title: '모임을 올렸어요!', body: '같은 시간에 비어 있는 새내기에게\n배너 알림으로 알려드릴게요.'),
        Btn('모임 목록으로', onTap: app.playBackToList),
      ]);
    }
    if (pl.view == 'new') {
      return _SubPage(
        title: '새 모임 만들기',
        cta: [Btn('모임 올리기', onTap: app.playSubmit)],
        children: [
          Field('무엇을 할까요?', child: AppInput(controller: app.playTitleC, hint: '예: 오늘 영화 보러 갈 사람?')),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: TimeField(label: '시작', value: app.playStart, options: timeOpts('06:00', '23:30'), onPicked: (v) => app.playSetTime(true, v))),
            const SizedBox(width: 12),
            Expanded(child: TimeField(label: '끝', value: app.playEnd, options: timeOpts('06:30', '24:00'), onPicked: (v) => app.playSetTime(false, v))),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Lbl('공개 범위'),
            const SizedBox(height: 8),
            ChipGrid(cols: 3, children: [
              for (final s in const [('school', '같은 학교'), ('dept', '같은 학과'), ('random', '랜덤')]) PillChip(s.$2, expand: true, on: pl.scope == s.$1, onTap: () => app.playSetScope(s.$1)),
            ]),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Lbl('내 이름'),
            const SizedBox(height: 8),
            ChipGrid(cols: 2, children: [
              PillChip('익명으로', expand: true, on: pl.anon, onTap: () => app.playSetAnon(true)),
              PillChip('실명으로', expand: true, on: !pl.anon, onTap: () => app.playSetAnon(false)),
            ]),
          ]),
          const SafeCard(title: '안전한 만남', body: '불편한 상대는 익명 경고로 신고할 수 있어요. 누적 3회면 일정 기간 매칭이 제한돼요.'),
        ],
      );
    }
    return _SubPage(title: '놀기', children: [
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionHead('지금 모집 중', trailing: '시간이 맞으면 참여하세요'),
        const SizedBox(height: 10),
        ...gapped([
          for (final x in kPlays)
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  AvatarStack([for (final n in x.names) Avatar(n, style: p.types['class'], size: 36)]),
                  const Spacer(),
                  Pill(x.when, style: p.types['class']),
                ]),
                const SizedBox(height: 10),
                Txt(x.title, bold: true, size: 16),
                Txt(x.who, size: 13, muted: true),
                const SizedBox(height: 10),
                if (pl.joined[x.id] ?? false) Btn('참여했어요', kind: 'soft', small: true, onTap: null) else Btn('참여하기', small: true, onTap: () => app.playJoin(x.id)),
              ]),
            ),
        ], 10),
      ]),
      Btn('새 모임 만들기', ic: 'plus', kind: 'line', onTap: () => app.openSocial('playNew')),
    ]);
  }
}
