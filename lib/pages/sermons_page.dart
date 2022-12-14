import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../database/semear_database.dart';
import '../repository/semear_repository.dart';
import '../utils/audio_player_handler.dart';
import '../utils/constants.dart';
import '../utils/dependency_injection.dart';
import '../utils/semear_widgets.dart';
import '../utils/widget_view.dart';

class SermonsPage extends StatefulWidget {
  final Book book;

  const SermonsPage({required this.book, Key? key}) : super(key: key);

  @override
  SermonsSingleBookPageController createState() => SermonsSingleBookPageController();
}

class SermonsSingleBookPageController extends State<SermonsPage> {
  late SemearRepository _repository;
  late List<ExpandableController> _expandableControllers;
  late bool _isLoadingAudio;
  late bool _hasError;
  late AudioPlayerHandler _audioHandler;
  late SemearDatabase _database;

  Stream<List<Sermon>> _watchAllSermonsFromBook() =>
      _database.watchAllSermonsFromBookId(widget.book.id);

  Future<void> _getSermonsAndStore() async {
    try {
      final sermonsFromInternet = await _repository.getSermonsFromBook(widget.book);
      if (sermonsFromInternet.isNotEmpty) {
        await _database.storeAllSermons(sermonsFromInternet);
      }
    } catch (e, stack) {
      debugPrint('$e\n$stack');
      setState(() => _hasError = true);
    }
  }

  void _onPlayPressed() => _audioHandler.play();

  void _onPausePressed() => _audioHandler.pause();

  void _onSeekChanged(double newSecondsValue) =>
      _audioHandler.seek(Duration(seconds: newSecondsValue.toInt()));

  void _stopAudio() => _audioHandler.stop();

  void _onBookmarkAddedPressed(int sermonId, int bookmarkInSeconds) =>
      _database.addBookmarkToSermon(sermonId, bookmarkInSeconds);

  void _onBookmarkRemovedPressed(int sermonId) =>
      _database.removeBookmarkFromSermon(sermonId);

  void _onReplayXSecondsPressed() {
    final finalDuration =
        _audioHandler.progressNotifier.value.current - const Duration(seconds: 10);

    if (finalDuration > Duration.zero) {
      _audioHandler.seek(finalDuration);
    } else {
      _audioHandler.seek(Duration.zero);
    }
  }

  void _onForwardXSecondsPressed() {
    final finalDuration =
        _audioHandler.progressNotifier.value.current + const Duration(seconds: 10);

    if (finalDuration < _audioHandler.progressNotifier.value.total) {
      _audioHandler.seek(finalDuration);
    } else {
      _audioHandler.seek(_audioHandler.progressNotifier.value.total);
    }
  }

  Future<void> _onExpandablePressed(int index, Sermon sermon) async {
    setState(() {
      _expandableControllers[index].toggle();
    });

    if (_expandableControllers[index].expanded) {
      _loadAudio(sermon);
    } else if (!_expandableControllers[index].expanded) {
      _stopAudio();
    }

    for (var i = 0; i < _expandableControllers.length; i++) {
      if (i != index && _expandableControllers[i].expanded) {
        _expandableControllers[i].toggle();
      }
    }
  }

  Future<void> _loadAudio(Sermon sermon) async {
    setState(() => _isLoadingAudio = true);

    await _audioHandler.setSermon(sermon);

    setState(() => _isLoadingAudio = false);
  }

  Future<void> _onReloadData() async => _getSermonsAndStore();

  @override
  void initState() {
    super.initState();
    _database = getIt<SemearDatabase>();
    _repository = getIt<SemearRepository>();
    _audioHandler = getIt<AudioPlayerHandler>();
    _expandableControllers = [];
    _hasError = false;
    _isLoadingAudio = false;
  }

  @override
  Widget build(BuildContext context) => _SermonsSingleBookPageView(this);
}

class _SermonsSingleBookPageView
    extends WidgetView<SermonsPage, SermonsSingleBookPageController> {
  const _SermonsSingleBookPageView(SermonsSingleBookPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        state._stopAudio();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.widget.book.title),
        ),
        body: state._hasError
            ? SemearErrorWidget(state._onReloadData)
            : StreamBuilder<List<Sermon>>(
                stream: state._watchAllSermonsFromBook(),
                builder: (context, snapshot) {
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    snapshot.data?.forEach(
                        (_) => state._expandableControllers.add(ExpandableController()));

                    return LiquidPullToRefresh(
                      onRefresh: state._onReloadData,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        padding: const EdgeInsets.all(4.0),
                        itemBuilder: (context, index) => Column(
                          children: [
                            SemearPullToRefresh(index: index),
                            SemearSermonCard(
                              controller: state._expandableControllers[index],
                              collapsed: _buildCollapsed(snapshot.data![index], index),
                              expanded:
                                  _buildExpanded(context, snapshot.data![index], index),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                    state._onReloadData();
                    return const SemearLoadingWidget();
                  } else {
                    return const SemearLoadingWidget();
                  }
                },
              ),
      ),
    );
  }

  Widget _buildCollapsed(Sermon sermon, int index) => InkWell(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sermon.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: semearOrange,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      sermon.passage,
                      style: const TextStyle(color: semearLightGrey),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: semearLightGrey,
              ),
            ],
          ),
        ),
        onTap: () async => state._onExpandablePressed(index, sermon),
      );

  Widget _buildExpanded(BuildContext context, Sermon sermon, int index) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sermon.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: semearOrange,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              sermon.passage,
                              style: const TextStyle(color: semearLightGrey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_up,
                        color: semearLightGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Pregador: ${sermon.preacher}',
                    style: const TextStyle(color: semearLightGrey),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    sermon.date,
                    style: const TextStyle(color: semearLightGrey),
                  ),
                ],
              ),
            ),
            onTap: () => state._onExpandablePressed(index, sermon),
          ),
          state._isLoadingAudio ? _buildLoadingAudio() : _buildPlayer(context, sermon)
        ],
      );

  Widget _buildLoadingAudio() => const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _buildPlayer(BuildContext context, Sermon sermon) => Stack(
        children: [
          Positioned(
            bottom: 0.0,
            child: ValueListenableBuilder<VisualizerWaveformCapture>(
              valueListenable: state._audioHandler.visualizerNotifier,
              builder: (_, value, __) {
                if (value.data.isNotEmpty) {
                  return Row(
                    children: [
                      Opacity(
                        opacity: 0.05,
                        child: CustomPaint(
                          foregroundPainter: BarVisualizer(
                            waveData: value.data,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
            child: Column(
              children: [
                ValueListenableBuilder<ProgressBarState>(
                  valueListenable: state._audioHandler.progressNotifier,
                  builder: (_, value, __) {
                    if (value.total != const Duration()) {
                      return SemearSlider(
                        progressBarState: value,
                        onSeekChanged: state._onSeekChanged,
                        bookmarkInSeconds: sermon.bookmarkInSeconds,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Future download button
                    _buildDownloadAudio(),
                    Row(
                      children: [
                        _buildReplay10(),
                        const SizedBox(width: 8.0),
                        _buildPlayButton(),
                        const SizedBox(width: 8.0),
                        _buildForward10(),
                      ],
                    ),
                    _buildBookmark(sermon),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildDownloadAudio() {
    return const SizedBox(width: 30.0);
  }

  Widget _buildReplay10() => SemearIcon(
        iconData: Icons.replay_10,
        onPressed: state._onReplayXSecondsPressed,
      );

  Widget _buildPlayButton() => StreamBuilder<bool>(
        stream:
            state._audioHandler.playbackState.map((state) => state.playing).distinct(),
        builder: (context, snapshot) {
          final playing = snapshot.data ?? false;
          return IconButton(
            icon: Container(
              height: 55.0,
              width: 55.0,
              decoration: BoxDecoration(
                gradient: semearGreenGradient,
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: boxShadowsGrey,
              ),
              child: Icon(
                playing ? Icons.pause : Icons.play_arrow,
                size: 30.0,
                color: semearDarkGrey,
              ),
            ),
            iconSize: 60.0,
            onPressed: playing ? state._onPausePressed : state._onPlayPressed,
          );
        },
      );

  Widget _buildForward10() => SemearIcon(
        iconData: Icons.forward_10,
        onPressed: state._onForwardXSecondsPressed,
      );

  Widget _buildBookmark(Sermon sermon) => ValueListenableBuilder<ProgressBarState>(
        valueListenable: state._audioHandler.progressNotifier,
        builder: (_, value, __) => SemearIcon(
          iconData: sermon.bookmarkInSeconds == null
              ? Icons.bookmark_add_outlined
              : Icons.bookmark_remove_outlined,
          onPressed: () => sermon.bookmarkInSeconds == null
              ? state._onBookmarkAddedPressed(sermon.id, value.current.inSeconds)
              : state._onBookmarkRemovedPressed(sermon.id),
        ),
      );
}
