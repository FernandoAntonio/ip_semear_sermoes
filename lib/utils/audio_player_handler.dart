import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../database/semear_database.dart';

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _player.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    _player.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    _player.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });

    _player.playerStateStream.listen((state) {
      if (state.playing &&
          state.processingState != ProcessingState.idle &&
          state.processingState != ProcessingState.completed) {
        _player.startVisualizer(
            enableWaveform: true, enableFft: true, captureRate: 8000, captureSize: 256);
      } else {
        _player.stopVisualizer();
      }
    });

    _player.visualizerWaveformStream
        .listen((visualizer) => visualizerNotifier.value = visualizer);
  }

  final visualizerNotifier = ValueNotifier<VisualizerWaveformCapture>(
    VisualizerWaveformCapture(
      samplingRate: 0,
      data: Uint8List(0),
    ),
  );

  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  Future<bool> setSermon(Sermon sermon) async {
    try {
      // Load the player.
      final duration =
          await _player.setAudioSource(AudioSource.uri(Uri.parse(sermon.mp3Url)));
      final imageFile = await _getImageFileFromAssets('logotipo.png');
      final imageFilePath = 'file://${imageFile.path}';

      final MediaItem currentItem = MediaItem(
        id: sermon.mp3Url,
        album: sermon.series,
        title: sermon.title,
        artist: sermon.preacher,
        artUri: Uri.parse(imageFilePath),
        duration: duration,
      );

      mediaItem.add(currentItem);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<File> _getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stopVisualizer();
    await _player.stop();
    await _player.seek(const Duration());
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
