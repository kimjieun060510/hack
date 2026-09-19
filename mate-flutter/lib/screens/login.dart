import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../widgets.dart';

/// 로그인 화면 (시안 그대로).
/// 학번/비번 검사는 하지 않아요. 채널톡 연동 전까지는 로그인 버튼을 누르면 들어간 척만 해요.
/// 회원가입 / 인증 화면은 다음 시안에서 붙입니다.

class AuthUi {
  static const bg = Color(0xFFF7F4EE);
  static const blob = Color(0xFFD9EDDF);
  static const blobSoft = Color(0xFFE7F3EA);
  static const ink = Color(0xFF1B2420);
  static const mut = Color(0xFF8A938D);
  static const line = Color(0xFFE1E7E3);
  static const mint = Color(0xFFE5F3EA);
  static const mintBtn = Color(0xFFD2EDDC);
  static const green = Color(0xFF3E7A55);
  static const greenDeep = Color(0xFF2F6B48);
  static const leaf = Color(0xFF9FCBAD);
}

class LoginScreen extends LiveView {
  const LoginScreen({super.key});

  @override
  Widget body(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final top = size.height < 700 ? 28.0 : 52.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: ColoredBox(
        color: AuthUi.bg,
        child: Stack(children: [
          const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _PageBlobPainter()))),
          Positioned(
            top: pad.top + 18,
            right: 28,
            child: const IgnorePointer(child: _CornerLeaves()),
          ),
          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(22, top, 22, 24 + MediaQuery.viewInsetsOf(context).bottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - top - 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AuthUi.ink,
                          letterSpacing: -1.2,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 34,
                        height: 5,
                        decoration: BoxDecoration(color: const Color(0xFFB7DCC4), borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 28),
                      const _LoginCard(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }
}

class _LoginCard extends LiveView {
  const _LoginCard();

  @override
  Widget body(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 28, offset: Offset(0, 10))],
      ),
      child: Column(children: [
        const _MateBanner(),
        const SizedBox(height: 18),
        _AuthField(
          controller: app.studentIdC,
          hint: '학번',
          icon: Icons.school_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 10),
        _AuthField(
          controller: app.passwordC,
          hint: '비밀번호',
          icon: Icons.lock_outline,
          obscure: app.loginObscure,
          onToggleObscure: app.toggleLoginObscure,
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: app.toggleAutoLogin,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: app.autoLogin ? AuthUi.mintBtn : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: app.autoLogin ? AuthUi.green : const Color(0xFFC9D1CC), width: 1.5),
                  ),
                  child: app.autoLogin ? const Icon(Icons.check, size: 14, color: AuthUi.greenDeep) : null,
                ),
                const SizedBox(width: 8),
                const Text('자동 로그인', style: TextStyle(fontSize: 14, color: AuthUi.ink, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: Material(
            color: AuthUi.mintBtn,
            borderRadius: BorderRadius.circular(26),
            child: InkWell(
              key: const Key('loginButton'),
              onTap: app.loginBusy ? null : app.fakeLogin,
              borderRadius: BorderRadius.circular(26),
              child: Center(
                child: app.loginBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: AuthUi.greenDeep),
                      )
                    : const Text('로그인', style: TextStyle(color: AuthUi.greenDeep, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Material(
            color: Colors.white,
            shape: const StadiumBorder(side: BorderSide(color: Color(0xFFC3E0CE))),
            child: InkWell(
              key: const Key('signupButton'),
              customBorder: const StadiumBorder(),
              onTap: app.goSignup,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                child: Text('회원가입 / 인증', style: TextStyle(color: AuthUi.green, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MateBanner extends StatelessWidget {
  const _MateBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          const Positioned.fill(child: ColoredBox(color: AuthUi.mint)),
          const Positioned.fill(child: CustomPaint(painter: _LogoBlobPainter())),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  'Mate',
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: 52,
                    color: AuthUi.greenDeep,
                    height: 1,
                    shadows: [Shadow(color: AuthUi.greenDeep.withValues(alpha: 0.08), offset: const Offset(0, 2), blurRadius: 0)],
                  ),
                ),
                const Positioned(
                  right: -2,
                  top: -10,
                  child: _LogoLeaves(),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _LogoLeaves extends StatelessWidget {
  const _LogoLeaves();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 28,
      child: CustomPaint(painter: _LeafPainter(color: AuthUi.green, sparkle: true)),
    );
  }
}

class _CornerLeaves extends StatelessWidget {
  const _CornerLeaves();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 40,
      child: CustomPaint(painter: _LeafPainter(color: AuthUi.leaf.withValues(alpha: 0.55), sparkle: true, sparkleColor: AuthUi.leaf)),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuthUi.line),
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(icon, size: 20, color: AuthUi.mut),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: onToggleObscure != null && obscure,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            cursorColor: AuthUi.greenDeep,
            style: const TextStyle(fontSize: 15, color: AuthUi.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AuthUi.mut, fontSize: 15, fontWeight: FontWeight.w400),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        if (onToggleObscure != null)
          IconButton(
            onPressed: onToggleObscure,
            visualDensity: VisualDensity.compact,
            tooltip: obscure ? '비밀번호 보기' : '비밀번호 숨기기',
            icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AuthUi.mut),
          )
        else
          const SizedBox(width: 12),
      ]),
    );
  }
}

class _PageBlobPainter extends CustomPainter {
  const _PageBlobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final a = Paint()..color = AuthUi.blob.withValues(alpha: 0.85);
    final b = Paint()..color = AuthUi.blobSoft;

    final top = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.42, 0)
      ..cubicTo(size.width * 0.50, size.height * 0.02, size.width * 0.38, size.height * 0.10, size.width * 0.22, size.height * 0.13)
      ..cubicTo(size.width * 0.08, size.height * 0.16, size.width * 0.12, size.height * 0.22, 0, size.height * 0.20)
      ..close();
    canvas.drawPath(top, a);

    final topSoft = Path()
      ..moveTo(size.width * 0.08, 0)
      ..cubicTo(size.width * 0.30, size.height * 0.01, size.width * 0.34, size.height * 0.08, size.width * 0.18, size.height * 0.12)
      ..cubicTo(size.width * 0.06, size.height * 0.15, 0, size.height * 0.08, 0, 0)
      ..close();
    canvas.drawPath(topSoft, b);

    final bot = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.55, size.height)
      ..cubicTo(size.width * 0.72, size.height * 0.92, size.width * 0.88, size.height * 0.88, size.width, size.height * 0.78)
      ..close();
    canvas.drawPath(bot, a);

    final botSoft = Path()
      ..moveTo(size.width, size.height * 0.90)
      ..cubicTo(size.width * 0.82, size.height * 0.94, size.width * 0.78, size.height, size.width, size.height)
      ..close();
    canvas.drawPath(botSoft, b);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LogoBlobPainter extends CustomPainter {
  const _LogoBlobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD7EBDD);
    final left = Path()
      ..moveTo(0, size.height * 0.25)
      ..cubicTo(size.width * 0.18, size.height * 0.05, size.width * 0.28, size.height * 0.55, 0, size.height * 0.85)
      ..close();
    canvas.drawPath(left, paint);

    final right = Path()
      ..moveTo(size.width, size.height * 0.20)
      ..cubicTo(size.width * 0.78, size.height * 0.05, size.width * 0.70, size.height * 0.70, size.width, size.height)
      ..lineTo(size.width, size.height * 0.20)
      ..close();
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeafPainter extends CustomPainter {
  final Color color;
  final bool sparkle;
  final Color? sparkleColor;
  const _LeafPainter({required this.color, this.sparkle = false, this.sparkleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    void leaf(Offset c, double w, double h, double rot) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      final path = Path()
        ..moveTo(0, -h / 2)
        ..cubicTo(w / 2, -h / 6, w / 2, h / 6, 0, h / 2)
        ..cubicTo(-w / 2, h / 6, -w / 2, -h / 6, 0, -h / 2)
        ..close();
      canvas.drawPath(path, fill);
      canvas.restore();
    }

    leaf(Offset(size.width * 0.32, size.height * 0.58), size.width * 0.42, size.height * 0.72, -0.7);
    leaf(Offset(size.width * 0.62, size.height * 0.42), size.width * 0.38, size.height * 0.68, 0.45);

    if (sparkle) {
      final s = Paint()
        ..color = sparkleColor ?? color
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      final p = Offset(size.width * 0.88, size.height * 0.18);
      canvas.drawLine(p + const Offset(-4, 0), p + const Offset(4, 0), s);
      canvas.drawLine(p + const Offset(0, -4), p + const Offset(0, 4), s);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
