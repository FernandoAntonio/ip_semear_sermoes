import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:ip_semear_sermoes/books_page.dart';
import 'package:ip_semear_sermoes/database/semear_database.dart';
import 'package:ip_semear_sermoes/utils/theme.dart';

import 'audio_player_handler.dart';

late AudioPlayerHandler audioHandler;
late SemearDatabase database;

void main() async {
  database = SemearDatabase();

  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
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
