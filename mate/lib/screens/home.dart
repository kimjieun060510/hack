import 'package:flutter/material.dart';

import '../data.dart';
import '../feeds.dart';
import '../sheets.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// 메인화면(카드 4개) · 내 약속 · 내 정보

// ------------------------------------------------------------------ 메인화면

class HomeScreen extends LiveView {
  const HomeScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    final todayN = app.eventsOn(kToday).length;
    return Backdrop(
      leaves: false,
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 16, 4),
            child: Row(children: [
              const MateLogo(size: 34),
              const Spacer(),
              const BellBtn(),
              const SizedBox(width: 8),
              const MeBtn(),
            ]),
          ),
          Expanded(
            child: Body(padding: EdgeInsets.fromLTRB(16, 6, 16, 24 + MediaQuery.paddingOf(context).bottom), children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '${app.userName}님, ', style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
                  TextSpan(text: '오늘도 혼자가 아니에요.', style: TextStyle(color: p.mut)),
                ]), style: const TextStyle(fontSize: 16, height: 1.4)),
              ),
              _HomeCard(
                ic: 'utensils',
                title: '밥약',
                sub: '지금 밥 먹을 사람?\n근처에 있는 친구와 함께 맛있는 시간을 보내요.',
                chip: '지금 공강인 친구 6명',
                onTap: () => app.openMeal(),
              ),
              _HomeCard(
                ic: 'heart',
                title: '과팅 / 놀기',
                sub: '함께할 친구를 찾아보세요.\n학교에서, 카페에서, 어디서든 좋아요!',
                chip: '이벤트 확정됨 ${app.confirmedMeetCount()}개',
                onTap: () => app.openMeet(),
              ),
              _HomeCard(
                ic: 'calendar',
                title: '달력',
                sub: '시간표·과제·약속을 한 달력에 모아 보고, 기회도 추천받아요.',
                chip: '오늘 일정 $todayN개',
                onTap: () => app.open('cal'),
              ),
              _HomeCard(
                ic: 'star',
                title: '내 약속',
                sub: '다가오는 약속을 한눈에 확인해요.',
                chip: app.nextMealText(),
                onTap: () => app.open('plans'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String ic, title, sub, chip;
  final VoidCallback onTap;
  const _HomeCard({required this.ic, required this.title, required this.sub, required this.chip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Material(
      color: p.tint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: p.line)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: p.priSoft, shape: BoxShape.circle),
                child: Icon(icon(ic), size: 30, color: p.priText),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: disp(24, p.ink, height: 1.2))),
              Icon(icon('chev'), size: 28, color: p.mut),
            ]),
            const SizedBox(height: 10),
            Text(sub, style: TextStyle(fontSize: 14, height: 1.55, color: p.mut)),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: _StatusChip(chip)),
          ]),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  const _StatusChip(this.text);

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: p.priSoft, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: p.pri, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.priText))),
      ]),
    );
  }
}

// ------------------------------------------------------------------ 내 약속

class PlansScreen extends LiveView {
  const PlansScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final plans = app.myPlans();
    return Column(children: [
      const SafeArea(bottom: false, child: BackHeader('내 약속', actions: [MeBtn()])),
      Expanded(
        child: Body(children: [
          AiCard(
            ic: 'star',
            center: true,
            child: Txt(plans.isEmpty ? '아직 잡힌 약속이 없어요.' : '다가오는 약속이 ${plans.length}개 있어요. ${app.nextMealText()}.', size: 14),
          ),
          if (plans.isEmpty)
            BigMessage(
              lead: const BigIcon('calendar'),
              title: '예정된 약속이 없어요',
              body: '밥약이나 과팅, 놀기로 첫 약속을 잡아 보세요.',
              extra: Padding(padding: const EdgeInsets.only(top: 12), child: Btn('밥약 찾으러 가기', ic: 'utensils', onTap: () => app.openMeal())),
            )
          else
            ...plans.map((e) => _PlanRow(e: e)),
        ]),
      ),
    ]);
  }
}

class _PlanRow extends StatelessWidget {
  final Ev e;
  const _PlanRow({required this.e});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final t = tsOf(context, e.type);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(children: [
        Expanded(
          child: InkWell(
            onTap: () => showEditSheet(context, e),
            borderRadius: BorderRadius.circular(16),
            child: Row(children: [
              Container(
                width: 58,
                height: 62,
                decoration: BoxDecoration(color: p.tint, borderRadius: BorderRadius.circular(18)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${dayOf(e.key)}', style: disp(22, p.ink, height: 1.1)),
                  Text(kDayN[dowOf(e.key)], style: TextStyle(fontSize: 12, color: p.mut)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Pill(ddayText(e.key), style: t),
                    const SizedBox(width: 6),
                    Text(e.end.isEmpty ? e.t : '${e.t}–${e.end}', style: TextStyle(fontSize: 12, color: p.mut)),
                  ]),
                  const SizedBox(height: 4),
                  Text(e.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3, color: p.ink)),
                  Text(e.sub, style: TextStyle(fontSize: 12, height: 1.4, color: p.mut)),
                ]),
              ),
              Semantics(
                button: true,
                label: '${e.title} 수정',
                child: SizedBox(width: 36, height: 44, child: Icon(icon('pencil'), size: 18, color: p.mut)),
              ),
            ]),
          ),
        ),
        Semantics(
          button: true,
          label: '${e.title} 삭제',
          child: InkWell(
            onTap: () => app.deleteEvent(e.id),
            customBorder: const CircleBorder(),
            child: SizedBox(width: 40, height: 44, child: Icon(icon('x'), size: 18, color: p.mut)),
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------ 내 정보

class MeScreen extends LiveView {
  const MeScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    const src = kFeedSources;
    return Backdrop(
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          const BackHeader(''),
          Expanded(
            child: Body(padding: EdgeInsets.fromLTRB(20, 4, 20, 28 + MediaQuery.paddingOf(context).bottom), gap: 16, children: [
              const Padding(padding: EdgeInsets.only(left: 6), child: UnderTitle('내 정보')),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [BoxShadow(color: Color(0x141E3A2A), blurRadius: 30, offset: Offset(0, 10))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Align(alignment: Alignment.centerRight, child: MateLogo(size: 30)),
                  const SizedBox(height: 4),
                  _InfoRow(ic: 'user', label: '이름', value: app.userName),
                  _InfoRow(ic: 'school', label: '학번', value: app.formatStudentNo()),
                  _InfoRow(ic: 'book', label: '학과', value: app.dept),
                  _InfoRow(
                    ic: 'users',
                    label: '성별',
                    valueWidget: Row(children: [
                      Expanded(child: PillChip('남성', expand: true, on: app.gender == 'male', onTap: () => app.setGender('male'))),
                      const SizedBox(width: 8),
                      Expanded(child: PillChip('여성', expand: true, on: app.gender == 'female', onTap: () => app.setGender('female'))),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Btn('채널톡 연동', ic: 'chat', kind: 'soft', onTap: () => app.showToast('채널톡 문의 연동은 데모에서는 준비 중이에요')),
                  const SizedBox(height: 12),
                  Center(child: Btn('로그아웃', ic: 'logout', kind: 'line', small: true, expand: false, onTap: app.logout)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Lbl('정보를 가져올 곳'),
                const SizedBox(height: 8),
                ...gapped([for (final s in src) SourceCard(s: s)], 8),
                const SizedBox(height: 8),
                Btn('지금 가져오기', ic: 'refresh', kind: 'line', small: true, onTap: () => app.syncFeeds()),
                const SizedBox(height: 8),
                Btn('관심사 다시 고르기', ic: 'sparkle', kind: 'line', small: true, onTap: app.redoInterest),
              ]),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const SectionHead('매너 경고', trailing: '3번 쌓이면 과팅 정지'),
                  const SizedBox(height: 10),
                  const Meter(),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Lbl('데모 둘러보기'),
                const SizedBox(height: 8),
                ...gapped([
                  for (var i = 0; i < kJumps.length; i++)
                    _JumpRow(label: '${i + 1}. ${kJumps[i].$1}', sub: kJumps[i].$2, onTap: () => app.jump(i)),
                ], 8),
              ]),
              LinkBtn('처음 상태로 되돌리기', onTap: app.resetAll),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String ic, label;
  final String? value;
  final Widget? valueWidget;
  const _InfoRow({required this.ic, required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: p.tint, shape: BoxShape.circle), child: Icon(icon(ic), size: 22, color: p.priText)),
        const SizedBox(width: 12),
        SizedBox(width: 44, child: Text(label, style: TextStyle(fontSize: 15, color: p.mut))),
        Text(':', style: TextStyle(fontSize: 15, color: p.mut)),
        const SizedBox(width: 12),
        Expanded(child: valueWidget ?? Text(value ?? '', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: p.ink))),
      ]),
    );
  }
}

class _JumpRow extends StatelessWidget {
  final String label, sub;
  final VoidCallback onTap;
  const _JumpRow({required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: p.line)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink)),
                Text(sub, style: TextStyle(fontSize: 12, height: 1.4, color: p.mut)),
              ]),
            ),
            Icon(icon('chev'), color: p.mut),
          ]),
        ),
      ),
    );
  }
}
