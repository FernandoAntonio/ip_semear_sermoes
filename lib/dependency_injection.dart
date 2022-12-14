import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ip_semear_sermoes/repository/semear_repository.dart';

import 'audio_player_handler.dart';
import 'database/semear_database.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjection() async {
  //DATABASE
  getIt.registerLazySingleton<SemearDatabase>(() => SemearDatabase());

  //REPOSITORY
  final Dio dio = Dio(BaseOptions(connectTimeout: 15000, receiveTimeout: 15000));
  getIt.registerLazySingleton<Dio>(() => dio);
  getIt.registerLazySingleton<SemearRepository>(() => SemearRepository(dio: getIt()));

  //AUDIO SERVICE
  final AudioPlayerHandler audioPlayerHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  getIt.registerLazySingleton<AudioPlayerHandler>(() => audioPlayerHandler);
}
