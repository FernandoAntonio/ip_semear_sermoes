import 'package:background_mode_new/background_mode_new.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'utils/dependency_injection.dart';
import 'view/books_page.dart';
import 'view/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundMode.start();
  await initDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    Permission.microphone.isGranted.then((value) {
      if (!value) {
        Permission.microphone.request();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: getTheme(),
      home: const BooksPage(),
    );
  }
}
