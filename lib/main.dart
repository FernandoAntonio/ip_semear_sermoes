import 'package:flutter/material.dart';

import 'books_page.dart';
import 'dependency_injection.dart';
import 'utils/theme.dart';

void main() async {
  await initDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: getTheme(),
      home: const BooksPage(),
    );
  }
}
