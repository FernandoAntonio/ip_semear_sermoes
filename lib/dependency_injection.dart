import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import 'audio_player_handler.dart';
import 'database/semear_database.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjection() async {
  getIt.registerLazySingleton<SemearDatabase>(() => SemearDatabase());

  await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

  getIt.registerLazySingleton<AudioPlayerHandler>(() => AudioPlayerHandler());
}
