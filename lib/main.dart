import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:ip_semear_sermoes/sermons_books_page.dart';

import 'audio_player_handler.dart';

const semearGreen = Color.fromARGB(255, 167, 205, 79);
const semearOrange = Color.fromARGB(255, 196, 115, 110);
const semearGrey = Color.fromARGB(255, 66, 66, 66);
late AudioPlayerHandler audioHandler;

void main() async {
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
      theme: ThemeData.dark().copyWith(
        sliderTheme: SliderThemeData(
          thumbColor: semearGreen,
          activeTrackColor: semearGreen,
          inactiveTrackColor: semearGreen.withOpacity(0.1),
          valueIndicatorTextStyle: const TextStyle(color: semearGrey),
          valueIndicatorColor: semearGreen,
        ),
        appBarTheme:
            const AppBarTheme(foregroundColor: semearGreen, backgroundColor: semearGrey),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: semearGreen),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: semearGreen)),
        colorScheme: const ColorScheme.dark().copyWith(secondary: semearGreen),
      ),
      home: const SermonsBooksPage(),
    );
  }
}
