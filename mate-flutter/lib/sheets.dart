import 'package:flutter/material.dart';

import 'data.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

/// 아래에서 올라오는 창(시트)들이 모여 있어요: 일정 추가, 함께 신청, 밥약 신청, 알림, 내 정보, 시간 선택.

Future<T?> _openSheet<T>(BuildContext context, Widget Function(BuildContext) builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Pal.of(context).paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => ListenableBuilder(listenable: app, builder: (c, _) => builder(c)),
  );
}

/// 시트 공통 틀: 손잡이 + 제목 + 닫기 + 스크롤되는 내용
class SheetFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SheetFrame({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Container(width: 44, height: 5, decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(3))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
          child: Row(children: [
            Expanded(child: Heading(title, size: 24)),
            RoundIconBtn(ic: 'x', label: '닫기', onTap: () => Navigator.of(context).pop()),
          ]),
        ),
        Flexible(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: gapped(children, 14)),
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------ 일정 추가

Future<void> showAddSheet(BuildContext context) {
  app.prepareAdd();
  return _openSheet<void>(context, (_) => const _AddSheet());
}

class _AddSheet extends StatefulWidget {
  const _AddSheet();

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  String? _err;

  void _addType() {
    final name = app.addNewC.text.trim();
    final e = app.addCustomType();
    setState(() => _err = e);
    if (e == null && name.isNotEmpty) FocusScope.of(context).unfocus();
  }

  void _submit() {
    final e = app.submitAdd();
    if (e != null) {
      setState(() => _err = e);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final types = app.filterList().skip(1).toList();
    return ListenableBuilder(listenable: app, builder: (c, _) => _content(c, p, types));
  }

  Widget _content(BuildContext context, Pal p, List<(String, String)> types) {
    return SheetFrame(title: '일정 추가', children: [
      Field('무엇을 하나요?', child: AppInput(controller: app.addTitleC, hint: '예: 카페 알바, 과외, 친구 약속')),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Lbl('종류'),
        const SizedBox(height: 8),
        ChipWrap(children: [
          for (final t in types) PillChip(t.$2, on: app.addType == t.$1, dot: tsOf(context, t.$1), onTap: () => app.setAddType(t.$1)),
          if (app.customTypes.length < kMaxCustom) PillChip('종류 추가', on: app.addNewOpen, dashed: true, leading: 'plus', onTap: app.toggleAddNew),
        ]),
        if (app.addNewOpen) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: AppInput(controller: app.addNewC, maxLength: 8, hint: '새 종류 이름 (예: 스터디)', onSubmitted: (_) => _addType())),
            const SizedBox(width: 8),
            SizedBox(width: 80, child: Btn('추가', small: true, onTap: _addType)),
          ]),
        ],
      ]),
      Field('날짜 (직접 입력)', child: AppInput(controller: app.addDateC, hint: '예: 9/28', maxLength: 10, keyboardType: TextInputType.datetime)),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: TimeField(label: '시작', value: app.addStart, options: timeOpts('00:00', '23:30'), onPicked: (v) => app.setAddTime(true, v))),
        const SizedBox(width: 12),
        Expanded(child: TimeField(label: '끝', value: app.addEnd, options: timeOpts('00:30', '24:00'), onPicked: (v) => app.setAddTime(false, v))),
      ]),
      if (_err != null) Text(_err!, style: TextStyle(color: p.danger, fontSize: 13, fontWeight: FontWeight.w700)),
      Btn('달력에 추가', onTap: _submit),
    ]);
  }
}

// ------------------------------------------------------------------ 친구와 함께 신청

Future<void> showShareSheet(BuildContext context, String oppId) {
  app.openShare(oppId);
  return _openSheet<void>(context, (ctx) {
    final o = kOpps.firstWhere((x) => x.id == app.shareOpp, orElse: () => kOpps.first);
    final n = app.shareCount();
    return SheetFrame(title: '친구와 함께 신청', children: [
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Txt(o.title, bold: true, size: 15),
          Txt('${o.src} · ${shortDate(o.key)} 마감', size: 12, muted: true),
        ]),
      ),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          for (var i = 0; i < kFriends.length; i++)
            PersonRow(
              first: i == 0,
              avatar: Avatar(kFriends[i].n[0], style: pal(ctx).types[kFriends[i].t]),
              name: kFriends[i].n,
              sub: kFriends[i].d,
              trailing: AppSwitch(on: app.shareTo[i] ?? false, label: '${kFriends[i].n}에게 보내기', onTap: () => app.toggleShareTo(i)),
            ),
        ]),
      ),
      Btn('$n명에게 “같이 신청하자” 보내기', onTap: n == 0
          ? null
          : () {
              Navigator.of(ctx).pop();
              app.shareSend();
            }),
    ]);
  });
}

// ------------------------------------------------------------------ 밥약 신청하기

Future<void> showReqSheet(BuildContext context) {
  return _openSheet<void>(context, (ctx) {
    const who = [('senior', '학과 선배'), ('club', '동아리 선배'), ('peer', '동기')];
    return SheetFrame(title: '밥약 신청하기', children: [
      const Txt('만나서 말하기 어려울 때, 먼저 정중하게 신청해 보세요.', size: 13, muted: true),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Lbl('누구에게 신청할까요?'),
        const SizedBox(height: 8),
        ChipGrid(cols: 3, children: [for (final w in who) PillChip(w.$2, expand: true, on: app.reqWho == w.$1, onTap: () => app.reqSetWho(w.$1))]),
      ]),
      Field('보낼 메시지', child: AppInput(controller: app.reqMsgC, maxLines: 4)),
      SwitchCard(title: '익명으로 신청하기', sub: '수락하면 이름이 공개돼요', on: app.reqAnon, onTap: app.reqToggleAnon),
      Btn('신청 보내기', onTap: () {
        Navigator.of(ctx).pop();
        app.reqSend();
      }),
    ]);
  });
}

// ------------------------------------------------------------------ 알림

Future<void> showNotifSheet(BuildContext context) {
  app.readNotifs();
  return _openSheet<void>(context, (ctx) {
    final p = pal(ctx);
    return SheetFrame(title: '알림', children: [
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          for (var i = 0; i < app.notifs.length; i++)
            InkWell(
              onTap: () {
                Navigator.of(ctx).pop();
                app.notifGo(app.notifs[i].go);
              },
              child: PersonRow(
                first: i == 0,
                avatar: IconDisc(app.notifs[i].ic, bg: p.priSoft, fg: p.pri),
                name: app.notifs[i].t,
                sub: app.notifs[i].s,
                trailing: Icon(icon('chev'), color: p.mut),
              ),
            ),
        ]),
      ),
    ]);
  });
}

// ------------------------------------------------------------------ 내 정보

Future<void> showProfileSheet(BuildContext context) {
  return _openSheet<void>(context, (ctx) {
    final p = pal(ctx);
    const src = [
      ('icampus', '아이캠퍼스', '시간표 · 과제 자동 반영'),
      ('dept', '학과 홈페이지', '공지 · 비교과 · 장학금'),
      ('etta', '에브리타임', '내 계정으로, 내 폰에서만'),
    ];
    return SheetFrame(title: '내 정보', children: [
      Row(children: [
        Avatar('혜', size: 52, bg: p.priSoft, fg: p.priText),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Txt('혜인', bold: true, size: 17),
            Txt('소프트웨어학과 · 26학번 · 인증 완료', size: 12, muted: true),
          ]),
        ),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Lbl('정보를 가져올 곳'),
        const SizedBox(height: 8),
        ...gapped([for (final s in src) SwitchCard(title: s.$2, sub: s.$3, on: app.conn[s.$1] ?? false, onTap: () => app.toggleConn(s.$1))], 8),
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
            _JumpRow(
              label: '${i + 1}. ${kJumps[i].$1}',
              onTap: () {
                Navigator.of(ctx).pop();
                app.jump(i);
              },
            ),
        ], 8),
      ]),
      LinkBtn('처음 상태로 되돌리기', onTap: () {
        Navigator.of(ctx).pop();
        app.resetAll();
      }),
    ]);
  });
}

class _JumpRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _JumpRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: p.line)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink))),
            Icon(icon('chev'), color: p.mut),
          ]),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ 시간 고르기 (스크롤)

Future<String?> pickTimeWheel(BuildContext context, {required String title, required String initial, required List<String> options}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Pal.of(context).paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) {
      var picked = options.contains(initial) ? initial : options.first;
      return StatefulBuilder(builder: (c, setS) {
        return SheetFrame(title: '$title 시간', children: [
          SizedBox(
            height: 250,
            child: WheelCol(
              label: '스크롤해서 고르세요',
              value: picked,
              items: [for (final o in options) (o, o)],
              onUserChange: (v) => setS(() => picked = v),
            ),
          ),
          Btn('$picked 로 정하기', onTap: () => Navigator.of(c).pop(picked)),
        ]);
      });
    },
  );
}
