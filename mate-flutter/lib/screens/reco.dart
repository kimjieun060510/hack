import 'package:flutter/material.dart';

import '../data.dart';
import '../sheets.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// 추천 탭: 관심사에 맞는 소식을 모아 보여주고, 누르면 달력에 마감일이 들어가요.
/// 제목이나 카드를 누르면 원문 사이트가 열려요 (주소는 data.dart 의 kOpps).

const Map<String, String> _catStyle = {'schol': 'job', 'lab': 'class', 'vol': 'meet', 'club': 'dept'};

class RecoScreen extends LiveView {
  const RecoScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final list = app.recoList();
    Opp? feat;
    for (final o in list) {
      if (!app.isAdded(o.id)) {
        feat = o;
        break;
      }
    }
    final rest = list.where((o) => o != feat).toList();
    final srcs = ['아이캠퍼스', if (app.conn['dept'] == true) '학과 홈페이지', if (app.conn['etta'] == true) '에타'].join(' · ');

    return Column(children: [
      SafeArea(bottom: false, child: TitleHeader('추천')),
      Expanded(
        child: Body(children: [
          Txt('$srcs에서 내 관심사에 맞는 소식만 모았어요.', size: 13, muted: true),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionHead('달력에 띄울 분야', trailing: '눌러서 켜고 끄기'),
            const SizedBox(height: 10),
            ChipWrap(children: [
              for (final e in kCats.entries) PillChip(e.value, on: app.cats[e.key] ?? false, leading: (app.cats[e.key] ?? false) ? 'check' : null, onTap: () => app.toggleCat(e.key)),
            ]),
          ]),
          if (feat != null)
            _FeatCard(o: feat)
          else if (list.isNotEmpty)
            const AiCard(ic: 'check', center: true, child: Txt('지금 나온 소식은 모두 달력에 추가했어요.')),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionHead(feat != null ? '이런 것도 있어요' : '추가한 소식', trailing: '+ 누르면 마감일이 달력에 들어가요'),
            const SizedBox(height: 10),
            ...gapped([for (final o in rest) _OppRow(o: o)], 10),
            if (list.isEmpty)
              AppCard(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Txt('켜둔 분야가 없어요. 위에서 하나 이상 켜주세요.', muted: true, align: TextAlign.center))),
          ]),
        ]),
      ),
    ]);
  }
}

String _time(Opp o) => o.t == '23:59' ? '자정' : o.t;

class _FeatCard extends StatelessWidget {
  final Opp o;
  const _FeatCard({required this.o});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final f = app.fieldMatch(o);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.featBg, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text('이거 관심 있으세요?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.featMut))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(color: const Color(0x29FFFFFF), borderRadius: BorderRadius.circular(99)),
            child: Text(ddayText(o.key), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.featInk)),
          ),
        ]),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => openUrl(o.url),
          borderRadius: BorderRadius.circular(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text.rich(TextSpan(children: [
              TextSpan(text: o.title),
              const TextSpan(text: '  '),
              WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(icon('ext'), size: 18, color: p.featMut)),
            ]), style: disp(22, p.featInk, height: 1.3)),
            const SizedBox(height: 10),
            Text('${o.src} · ${kCats[o.cat]} · ${shortDate(o.key)} ${_time(o)} 마감${f != null ? ' · $f 관심사와 일치' : ''}', style: TextStyle(fontSize: 13, height: 1.5, color: p.featMut)),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Material(
              color: p.featBtn,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => app.toggleOpp(o.id),
                borderRadius: BorderRadius.circular(14),
                child: Container(height: 44, alignment: Alignment.center, child: Text('좋아, 달력에 추가', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: p.featBtnInk))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => showShareSheet(context, o.id),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x73FFFFFF))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon('share'), size: 18, color: p.featInk),
                const SizedBox(width: 6),
                Text('친구와 함께', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: p.featInk)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final String ic, kind; // kind: line | pri | on
  final String label;
  final VoidCallback onTap;
  const _RoundBtn({required this.ic, required this.kind, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final bg = kind == 'pri' ? p.pri : (kind == 'on' ? p.priSoft : p.surface);
    final fg = kind == 'pri' ? p.priInk : (kind == 'on' ? p.pri : p.ink);
    final bd = kind == 'pri' ? p.pri : (kind == 'on' ? p.priLine : p.line);
    return Semantics(
      button: true,
      label: label,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: bd)),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Icon(icon(ic), size: 22, color: fg)),
        ),
      ),
    );
  }
}

class _OppRow extends StatelessWidget {
  final Opp o;
  const _OppRow({required this.o});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final on = app.isAdded(o.id);
    final f = app.fieldMatch(o);
    final ts = p.types[_catStyle[o.cat] ?? 'opp'];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(children: [
        Expanded(
          child: InkWell(
            onTap: () => openUrl(o.url),
            borderRadius: BorderRadius.circular(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 6, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Pill(kCats[o.cat] ?? '', style: ts),
                Text(o.src, style: TextStyle(fontSize: 12, color: p.mut)),
                Text(ddayText(o.key), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.types['assign']!.ink)),
              ]),
              const SizedBox(height: 5),
              Text.rich(TextSpan(children: [
                TextSpan(text: o.title),
                const TextSpan(text: ' '),
                WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(icon('ext'), size: 14, color: p.mut)),
              ]), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.4, color: p.ink)),
              const SizedBox(height: 5),
              Text.rich(TextSpan(children: [
                TextSpan(text: '${shortDate(o.key)} ${_time(o)} 마감 · ${o.meta}'),
                if (f != null) TextSpan(text: ' · $f 관심사', style: TextStyle(color: p.priText, fontWeight: FontWeight.w700)),
              ]), style: TextStyle(fontSize: 12, color: p.mut)),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Column(mainAxisSize: MainAxisSize.min, children: [
          _RoundBtn(ic: 'share', kind: 'line', label: '${o.title} 친구와 함께 신청', onTap: () => showShareSheet(context, o.id)),
          const SizedBox(height: 4),
          _RoundBtn(ic: on ? 'check' : 'plus', kind: on ? 'on' : 'pri', label: '${on ? '달력에서 빼기' : '달력에 추가'}: ${o.title}', onTap: () => app.toggleOpp(o.id)),
        ]),
      ]),
    );
  }
}
