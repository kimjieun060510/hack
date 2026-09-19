import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// 테스트에서는 웹뷰 없이 상담 화면만 확인해요.
bool channelTalkUseWebView = true;

/// 실행 중에 붙여넣은 플러그인 키. 비어 있으면 [kChannelPluginKey]를 써요.
String channelTalkPluginKey = kChannelPluginKey;

/// MaterialApp 에 붙여서, 어느 화면에서 눌러도 상담창이 꼭 뜨게 해요.
final GlobalKey<NavigatorState> mateNav = GlobalKey<NavigatorState>();

void openChannelTalk([BuildContext? context]) {
  final nav = mateNav.currentState ?? (context == null ? null : Navigator.maybeOf(context, rootNavigator: true));
  if (nav == null) return;
  nav.push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => const ChannelTalkScreen(),
  ));
}

String? channelTalkKeyFrom(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  final uri = Uri.tryParse(s);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    if (uri.host.endsWith('.channel.io') && uri.host != 'channel.io' && uri.host != 'www.channel.io') {
      return uri.host.split('.').first;
    }
    return s;
  }
  return s;
}

String channelTalkPageUrl(String key) {
  if (key.startsWith('http://') || key.startsWith('https://')) return key;
  return 'https://$key.channel.io';
}

/// 채널톡 상담창. 네이티브 SDK 대신 웹 위젯을 열어서 시뮬레이터에서도 바로 이어져요.
class ChannelTalkScreen extends StatefulWidget {
  const ChannelTalkScreen({super.key});

  @override
  State<ChannelTalkScreen> createState() => _ChannelTalkScreenState();
}

class _ChannelTalkScreenState extends State<ChannelTalkScreen> {
  final _keyC = TextEditingController();
  WebViewController? _ctl;
  var _loading = false;
  String? _err;

  String get _key => channelTalkKeyFrom(channelTalkPluginKey) ?? '';

  @override
  void initState() {
    super.initState();
    _keyC.text = channelTalkPluginKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _key.isNotEmpty) _boot();
    });
  }

  @override
  void dispose() {
    _keyC.dispose();
    super.dispose();
  }

  void _saveAndBoot() {
    final next = channelTalkKeyFrom(_keyC.text);
    if (next == null) {
      setState(() => _err = '플러그인 키를 붙여넣은 뒤 다시 눌러 주세요.');
      return;
    }
    channelTalkPluginKey = next;
    _boot();
  }

  void _boot() {
    final key = _key;
    if (key.isEmpty) {
      setState(() {
        _ctl = null;
        _loading = false;
        _err = null;
      });
      return;
    }
    if (kIsWeb || !channelTalkUseWebView) {
      if (kIsWeb) openUrl(channelTalkPageUrl(key));
      if (mounted) {
        setState(() {
          _ctl = null;
          _loading = false;
          _err = null;
        });
      }
      return;
    }
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final ctl = _newController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..enableZoom(false)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (req) {
            final uri = Uri.tryParse(req.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'about') {
              return NavigationDecision.navigate;
            }
            openUrl(req.url);
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (e) {
            if (e.isForMainFrame == false) return;
            if (mounted) setState(() => _err = '채널톡을 불러오지 못했어요. 네트워크를 확인해 주세요.');
          },
        ));
      if (key.startsWith('http://') || key.startsWith('https://')) {
        ctl.loadRequest(Uri.parse(key));
      } else {
        ctl.loadHtmlString(_html(key), baseUrl: 'https://channel.io/');
      }
      if (mounted) setState(() => _ctl = ctl);
    } catch (e) {
      if (mounted) {
        setState(() {
          _ctl = null;
          _loading = false;
          _err = '채널톡을 열 수 없어요. 아래 버튼으로 열어 주세요.';
        });
      }
    }
  }

  WebViewController _newController() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      return WebViewController.fromPlatformCreationParams(
        WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          javaScriptCanOpenWindowsAutomatically: true,
        ),
      );
    }
    return WebViewController();
  }

  String _esc(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', ' ').replaceAll('</', r'<\/');

  String _html(String key) {
    final name = _esc(app.userName);
    final id = _esc(app.studentNo);
    return '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    html,body{margin:0;height:100%;background:#F7F9F7}
  </style>
</head>
<body>
  <script>
    (function(){var w=window;if(w.ChannelIO){return;}var ch=function(){ch.c(arguments);};ch.q=[];ch.c=function(args){ch.q.push(args);};w.ChannelIO=ch;function l(){if(w.ChannelIOInitialized){return;}w.ChannelIOInitialized=true;var s=document.createElement("script");s.type="text/javascript";s.async=true;s.src="https://cdn.channel.io/plugin/ch-plugin-web.js";var x=document.getElementsByTagName("script")[0];if(x.parentNode){x.parentNode.insertBefore(s,x);}}if(document.readyState==="complete"){l();}else{w.addEventListener("DOMContentLoaded",l);w.addEventListener("load",l);}})();
    ChannelIO('boot', {
      pluginKey: '${_esc(key)}',
      memberId: '$id',
      profile: { name: '$name' },
      hideChannelButtonOnBoot: true,
      hidePopup: true,
      language: 'ko',
      zIndex: 10000000
    }, function() {
      ChannelIO('showMessenger');
    });
    setTimeout(function(){ try { ChannelIO('showMessenger'); } catch (e) {} }, 1200);
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Scaffold(
      backgroundColor: p.paper,
      appBar: AppBar(
        title: const Text('채널톡'),
        leading: IconButton(tooltip: '채널톡 닫기', icon: Icon(icon('back')), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Stack(children: [
        if (_ctl != null) Positioned.fill(child: WebViewWidget(controller: _ctl!)),
        if (_key.isEmpty)
          _KeyPane(controller: _keyC, err: _err, onOpen: _saveAndBoot)
        else if (_err != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Txt(_err!, align: TextAlign.center),
                const SizedBox(height: 12),
                Btn('브라우저로 열기', ic: 'ext', onTap: () => openUrl(channelTalkPageUrl(_key))),
              ]),
            ),
          )
        else if (_loading)
          const Center(child: Text('채널톡 상담을 열고 있어요'))
        else if (_ctl == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Txt('채널톡 상담창을 열어요.', align: TextAlign.center),
                const SizedBox(height: 12),
                Btn('채널톡 열기', ic: 'chat', onTap: () => openUrl(channelTalkPageUrl(_key))),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _KeyPane extends StatelessWidget {
  final TextEditingController controller;
  final String? err;
  final VoidCallback onOpen;
  const _KeyPane({required this.controller, required this.err, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const Txt('채널톡으로 바로 이어지게 하려면 플러그인 키가 필요해요.', bold: true, size: 16, align: TextAlign.center),
        const SizedBox(height: 8),
        const Txt('채널톡 데스크 → 설정 → 일반 설정에서 플러그인 키를 복사해 붙여넣으면, 상담창이 열려요.', muted: true, align: TextAlign.center),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '플러그인 키 또는 https://….channel.io',
            filled: true,
            fillColor: p.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: p.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: p.line)),
          ),
        ),
        if (err != null) ...[
          const SizedBox(height: 10),
          Txt(err!, color: p.danger, align: TextAlign.center, size: 13),
        ],
        const SizedBox(height: 14),
        Btn('상담 시작', ic: 'chat', onTap: onOpen),
      ],
    );
  }
}

class ChannelTalkFab extends StatelessWidget {
  const ChannelTalkFab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Semantics(
      button: true,
      label: '채널톡 문의',
      child: Material(
        color: p.pri,
        shape: const CircleBorder(),
        elevation: 8,
        shadowColor: const Color(0x66000000),
        child: InkWell(
          key: const Key('channel-talk-fab'),
          customBorder: const CircleBorder(),
          onTap: () => openChannelTalk(context),
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.chat_bubble, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
