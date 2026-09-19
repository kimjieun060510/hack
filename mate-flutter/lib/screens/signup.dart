import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth_ui.dart';
import '../state.dart';
import '../widgets.dart';

/// 회원가입 / 인증 화면 (시안 그대로).
/// 사진 찍기·앨범은 카메라를 켜지 않고, 학생증을 읽은 척만 해요. 채널톡 연동은 아직 없습니다.

class SignupScreen extends LiveView {
  const SignupScreen({super.key});

  @override
  Widget body(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: ColoredBox(
        color: AuthUi.bg,
        child: SafeArea(
          child: Stack(children: [
            Positioned.fill(
              child: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(22, 12, 22, 16 + MediaQuery.viewInsetsOf(context).bottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                    child: const _SignupForm(),
                  ),
                );
              }),
            ),
            Positioned(
              left: 4,
              top: 2,
              child: IconButton(
                key: const Key('signupBack'),
                tooltip: '로그인으로',
                onPressed: app.backToLogin,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AuthUi.ink),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SignupForm extends LiveView {
  const _SignupForm();

  @override
  Widget body(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text(
        '학생증 한 장이면\n계정이 만들어져요',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AuthUi.ink,
          height: 1.35,
          letterSpacing: -0.8,
        ),
      ),
      const SizedBox(height: 16),
      const _PhotoBox(),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          flex: 3,
          child: _FillBtn(
            key: const Key('signupCamera'),
            label: '사진 찍기',
            icon: Icons.photo_camera,
            onTap: app.signupPhoto == 'scanning' ? null : app.fakeSignupPhoto,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _GhostBtn(
            key: const Key('signupAlbum'),
            label: '앨범',
            icon: Icons.image_outlined,
            onTap: app.signupPhoto == 'scanning' ? null : app.fakeSignupPhoto,
          ),
        ),
      ]),
      const SizedBox(height: 10),
      const _InfoBanner(),
      const SizedBox(height: 14),
      _LabeledField(label: '이름', hint: '이름을 입력해주세요', controller: app.signupNameC),
      const SizedBox(height: 10),
      _LabeledField(
        label: '학번',
        hint: '학번을 입력해주세요',
        controller: app.signupIdC,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      const SizedBox(height: 10),
      _LabeledField(label: '학과', hint: '학과를 입력해주세요', controller: app.signupDeptC),
      const SizedBox(height: 10),
      const _GenderRow(),
      const SizedBox(height: 16),
      _FillBtn(
        key: const Key('signupSubmit'),
        label: '제출',
        busy: app.signupBusy,
        onTap: app.signupBusy ? null : app.submitSignup,
      ),
    ]);
  }
}

class _PhotoBox extends LiveView {
  const _PhotoBox();

  @override
  Widget body(BuildContext context) {
    final st = app.signupPhoto;
    Widget inner;
    if (st == 'scanning') {
      inner = const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6, color: AuthUi.greenDeep)),
        SizedBox(height: 12),
        Text('학생증을 읽고 있어요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuthUi.ink)),
      ]);
    } else if (st == 'done') {
      inner = const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _IdBadge(done: true),
        SizedBox(height: 12),
        Text('학생증이 인식됐어요.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AuthUi.ink)),
        SizedBox(height: 4),
        Text('아래 정보가 맞는지 확인해주세요.', style: TextStyle(fontSize: 12, color: AuthUi.mut)),
      ]);
    } else {
      inner = const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _IdBadge(done: false),
        SizedBox(height: 12),
        Text('학생증 사진을 입력해주세요.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuthUi.ink)),
      ]);
    }

    return CustomPaint(
      painter: _DashPainter(color: st == 'done' ? AuthUi.green : const Color(0xFF9ECBB0)),
      child: Container(
        height: 148,
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: inner,
      ),
    );
  }
}

class _IdBadge extends StatelessWidget {
  final bool done;
  const _IdBadge({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(color: AuthUi.mint, shape: BoxShape.circle),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: AuthUi.greenDeep, size: 28)
            : CustomPaint(size: const Size(30, 22), painter: _MiniIdPainter()),
      ),
    );
  }
}

class _MiniIdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AuthUi.greenDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(0.8, 1.2, size.width - 1.6, size.height - 2.4), const Radius.circular(4));
    canvas.drawRRect(r, stroke);
    canvas.drawCircle(Offset(size.width * 0.30, size.height * 0.52), 3.4, stroke);
    canvas.drawLine(Offset(size.width * 0.50, size.height * 0.40), Offset(size.width * 0.84, size.height * 0.40), stroke);
    canvas.drawLine(Offset(size.width * 0.50, size.height * 0.62), Offset(size.width * 0.76, size.height * 0.62), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(color: AuthUi.mint, borderRadius: BorderRadius.circular(14)),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.verified_user_outlined, size: 18, color: AuthUi.greenDeep),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '학과와 학번은 학생증에서 자동으로 입력돼요. 미팅과 과팅에서는 학과 · 학번만 보여줘요.',
            style: TextStyle(fontSize: 12.5, height: 1.45, color: AuthUi.greenDeep, fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AuthUi.ink)),
      const SizedBox(height: 6),
      Container(
        height: 46,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AuthUi.line),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          cursorColor: AuthUi.greenDeep,
          style: const TextStyle(fontSize: 15, color: AuthUi.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B8B3), fontSize: 14),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    ]);
  }
}

class _GenderRow extends LiveView {
  const _GenderRow();

  @override
  Widget body(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('성별', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AuthUi.ink)),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(child: _GenderChip(id: 'm', label: '남')),
        const SizedBox(width: 8),
        Expanded(child: _GenderChip(id: 'f', label: '여')),
      ]),
    ]);
  }
}

class _GenderChip extends StatelessWidget {
  final String id, label;
  const _GenderChip({required this.id, required this.label});

  @override
  Widget build(BuildContext context) {
    final on = app.signupGender == id;
    return Material(
      color: on ? AuthUi.mintBtn : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: Key('gender-$id'),
        onTap: () => app.setSignupGender(id),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: on ? AuthUi.mintBtn : AuthUi.line),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: on ? AuthUi.greenDeep : const Color(0xFFB0B8B3)),
          ),
        ),
      ),
    );
  }
}

class _FillBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool busy;
  const _FillBtn({super.key, required this.label, this.icon, this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: AuthUi.priFill,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Center(
            child: busy
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
                    Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
          ),
        ),
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _GhostBtn({super.key, required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AuthUi.line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 18, color: AuthUi.ink),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AuthUi.ink, fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2), const Radius.circular(22));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const dash = 6.5;
    const gap = 4.5;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = (d + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(d, next), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) => oldDelegate.color != color;
}
