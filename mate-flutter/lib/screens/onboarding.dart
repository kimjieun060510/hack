import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// 처음 시작: 1) 학생증 인증  2) 관심사 고르기 (딱 한 번)

class _Progress extends StatelessWidget {
  final int step; // 1 또는 2
  const _Progress(this.step);

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Row(children: [
      for (var i = 1; i <= 2; i++) ...[
        if (i > 1) const SizedBox(width: 6),
        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: i <= step ? p.pri : p.line, borderRadius: BorderRadius.circular(2)))),
      ],
    ]);
  }
}

class VerifyScreen extends LiveView {
  const VerifyScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    final st = app.verify;
    final done = st == 'done';
    final scanning = st == 'scanning';
    return SafeArea(
      bottom: false,
      child: Column(children: [
        Expanded(
          child: Body(padding: const EdgeInsets.fromLTRB(20, 22, 20, 20), children: [
            const _Progress(1),
            const SizedBox(height: 4),
            Text('1 / 2 · 새내기 인증', style: TextStyle(color: p.pri, fontWeight: FontWeight.w700, fontSize: 13)),
            Heading('학생증 한 장이면\n계정이 만들어져요', size: 32, color: p.ink),
            const Txt('같은 학교 새내기끼리만 만날 수 있도록 학생증으로 한 번만 확인해요.', muted: true, height: 1.6),
            _ScanBox(state: st),
            Row(children: [
              Expanded(flex: 3, child: Btn(done ? '다시 찍기' : '사진 찍기', ic: 'camera', onTap: scanning ? null : app.verifyShot)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: Btn('앨범', kind: 'line', onTap: app.verifyShot)),
            ]),
            const AiCard(ic: 'shield', center: true, child: Txt('학과와 학번은 학생증에서 자동으로 입력돼요. 과팅에서는 학과·학번만 보여줘요.', size: 13, height: 1.5)),
          ]),
        ),
        CtaBar(children: [
          Btn('다음', onTap: done ? app.obNext : null),
          LinkBtn('건너뛰고 둘러보기', onTap: app.obSkip),
        ]),
      ]),
    );
  }
}

class _ScanBox extends StatelessWidget {
  final String state;
  const _ScanBox({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final done = state == 'done';
    Widget inner;
    if (state == 'scanning') {
      inner = const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Spinner(), SizedBox(height: 10), Txt('학생증을 읽고 있어요', bold: true)]);
    } else if (done) {
      inner = Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon('check'), size: 40, color: p.pri),
        const SizedBox(height: 8),
        const Txt('인증이 끝났어요', bold: true),
        const Txt('소프트웨어학과 · 26학번', size: 12, muted: true),
      ]);
    } else {
      inner = Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon('idcard'), size: 40, color: p.pri),
        const SizedBox(height: 8),
        const Txt('학생증을 사각형 안에 맞춰주세요', bold: true),
        const Txt('학번과 학과가 잘 보이게 찍어주세요', size: 12, muted: true),
      ]);
    }
    return Container(
      height: 200,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: done ? p.pri : p.priLine, width: 2),
      ),
      child: inner,
    );
  }
}

class InterestScreen extends LiveView {
  const InterestScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final p = pal(context);
    const src = [
      ('icampus', '아이캠퍼스', '수업 시간표와 과제 마감을 자동으로 가져와요'),
      ('dept', '학과 홈페이지', '공지·비교과·장학금·산학협력 소식을 모아와요'),
      ('etta', '에브리타임', '내 계정으로, 내 폰에서만 불러와서 나 혼자 봐요'),
    ];
    return SafeArea(
      bottom: false,
      child: Column(children: [
        Expanded(
          child: Body(padding: const EdgeInsets.fromLTRB(20, 22, 20, 20), children: [
            const _Progress(2),
            const SizedBox(height: 4),
            Text('2 / 2 · 관심사', style: TextStyle(color: p.pri, fontWeight: FontWeight.w700, fontSize: 13)),
            Heading('딱 한 번만 골라요\n나머지는 앱이 해요', size: 32, color: p.ink),
            const Txt('고른 분야의 새 소식이 올라오면 “이거 관심 있으세요?” 하고 알려줄게요.', muted: true, height: 1.6),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Lbl('어떤 소식이 궁금해요?', small: '추천 탭에서 언제든 바꿀 수 있어요'),
              const SizedBox(height: 8),
              ChipWrap(children: [for (final e in kCats.entries) PillChip(e.value, on: app.cats[e.key] ?? false, onTap: () => app.toggleCat(e.key))]),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Lbl('관심 분야'),
              const SizedBox(height: 8),
              ChipWrap(children: [for (final f in kFields) PillChip(f, on: app.fields[f] ?? false, onTap: () => app.toggleField(f))]),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Lbl('소식을 가져올 곳'),
              const SizedBox(height: 8),
              ...gapped([for (final s in src) SwitchCard(title: s.$2, sub: s.$3, on: app.conn[s.$1] ?? false, onTap: () => app.toggleConn(s.$1))], 8),
            ]),
          ]),
        ),
        CtaBar(children: [Btn('시작하기', onTap: app.obDone)]),
      ]),
    );
  }
}
