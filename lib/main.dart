import 'package:flutter/material.dart';
import 'package:ip_semear_sermoes/sermons_books_page.dart';

const semearGreen = Color.fromARGB(255, 167, 205, 79);
const semearOrange = Color.fromARGB(255, 196, 115, 110);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(foregroundColor: semearGreen),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: semearGreen),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: semearGreen)),
      ),
      home: const SermonsBooksPage(),
    );
  }
}
