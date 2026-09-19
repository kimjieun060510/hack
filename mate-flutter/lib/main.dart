import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MateApp());
}

class MateApp extends StatelessWidget {
  const MateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Pal.light, Brightness.light),
      darkTheme: buildTheme(Pal.dark, Brightness.dark),
      themeMode: ThemeMode.system,
      home: const Shell(),
    );
  }
}
