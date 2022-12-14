import 'package:dio/dio.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'audio_player_handler.dart';
import 'database/semear_database.dart';
import 'dependency_injection.dart';
import 'semear_widgets.dart';
import 'utils/constants.dart';
import 'utils/widget_view.dart';

class SermonsPage extends StatefulWidget {
  final Book book;

  const SermonsPage({required this.book, Key? key}) : super(key: key);

  @override
  SermonsSingleBookPageController createState() => SermonsSingleBookPageController();
}

class SermonsSingleBookPageController extends State<SermonsPage> {
  late Future<List<Sermon>?> _pageLoader;
  late Dio _dio;
  late List<ExpandableController> _expandableControllers;
  late bool _showPlayer;
  late bool _isLoadingAudio;
  late bool _hasError;
  late AudioPlayerHandler _audioHandler;
  late SemearDatabase _database;

  Future<List<Sermon>?> _getSermonList(bool fromInternet) async {
    setState(() => _hasError = false);

    try {
      List<Sermon> sermonList = [];

      if (!fromInternet) {
        sermonList = await _database.getAllSermonsFromBookId(widget.book.id);

        if (sermonList.isEmpty || sermonList.first.bookId != widget.book.id) {
          var sermonsFromInternet = await _getSermonsFromInternet();
          if (sermonsFromInternet.isNotEmpty) {
            sermonList = await _storeAndGetSermons(sermonsFromInternet);
          } else {
            throw Exception();
          }
        }
      } else if (fromInternet) {
        await _database.deleteAllSermonsWithBookId(widget.book.id);
        var sermonsFromInternet = await _getSermonsFromInternet();
        if (sermonsFromInternet.isNotEmpty) {
          sermonList = await _storeAndGetSermons(sermonsFromInternet);
        } else {
          throw Exception();
        }
      }

      return sermonList;
    } catch (_) {
      setState(() => _hasError = true);
      return null;
    }
  }

  Future<List<SermonsCompanion>> _getSermonsFromInternet() async {
    //Get data from page
    late dom.Node bookSermons;
    try {
      final response = await _dio.get(widget.book.url);
      final parsed = parse(response.data);
      bookSermons =
          parsed.nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5].nodes[3];
    } catch (_) {
      setState(() => _hasError = true);
    }

    //Pagination
    int paginationSize;
    try {
      final paginationIndex = bookSermons.nodes.length - 2;

      paginationSize = bookSermons.nodes[paginationIndex].nodes[1].nodes.length;
    } catch (e) {
      paginationSize = 1;
    }

    final nodes = bookSermons;
    final List<dom.Node> sermonNodes = [];
    final List<SermonsCompanion> sermons = [];

    try {
      if (paginationSize > 1) {
        for (var index = 2; index <= paginationSize; index++) {
          final response = await _dio.get('${widget.book.url}page/$index');
          final parsed = parse(response.data);
          final list = parsed
              .nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5].nodes[3];
          nodes.nodes.addAll(list.nodes);
        }
      }

      for (var index = 0; index < nodes.nodes.length; index++) {
        dynamic comment;
        try {
          comment = nodes.nodes[index] as dom.Comment;
        } catch (_) {}
        if (comment is dom.Comment && comment.data == 'Start Post') {
          sermonNodes.add(nodes.nodes[index + 2]);
        }
      }

      for (dom.Node node in sermonNodes) {
        final sermon = SermonsCompanion.insert(
          bookId: widget.book.id,
          date: node.nodes[1].nodes[0].text?.trim() ?? '',
          title: node.nodes[3].nodes[0].nodes[0].text?.trim() ?? '',
          preacher: node.nodes[6].text?.replaceAll('|', '').trim() ?? '',
          series: node.nodes[8].text?.replaceAll('|', '').trim() ?? '',
          passage: node.nodes[10].text?.trim() ?? '',
          mp3Url: node.nodes[11].nodes[2].attributes['href'].toString(),
        );
        sermons.add(sermon);
      }
    } catch (_) {
      setState(() => _hasError = true);
    }

    return sermons.reversed.toList();
  }

  Future<List<Sermon>> _storeAndGetSermons(List<SermonsCompanion> sermonList) async {
    await _database.storeAllSermons(sermonList);
    return _database.getAllSermonsFromBookId(widget.book.id);
  }

  void _onPlayPressed() => _audioHandler.play();

  void _onPausePressed() => _audioHandler.pause();

  void _onSeekChanged(double newSecondsValue) =>
      _audioHandler.seek(Duration(seconds: newSecondsValue.toInt()));

  void _onStopPressed() {
    _audioHandler.stop();
    setState(() => _showPlayer = false);
  }

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

  Future<void> _onExpandablePressed(int index) async {
    _onStopPressed();
    setState(() {
      _expandableControllers[index].toggle();
      _showPlayer = false;
      _isLoadingAudio = false;
    });

    for (var i = 0; i < _expandableControllers.length; i++) {
      if (i != index && _expandableControllers[i].expanded) {
        _expandableControllers[i].toggle();
      }
    }
  }

  Future<void> _onLoadAudioPressed(Sermon sermon) async {
    setState(() {
      _showPlayer = false;
      _isLoadingAudio = true;
    });

    await _audioHandler.setSermon(sermon);

    setState(() {
      _showPlayer = true;
      _isLoadingAudio = false;
    });
  }

  Future<void> _onReloadData() => _pageLoader = _getSermonList(true);

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(connectTimeout: 15000, receiveTimeout: 15000));
    _expandableControllers = [];
    _showPlayer = false;
    _isLoadingAudio = false;
    _audioHandler = getIt<AudioPlayerHandler>();
    _database = getIt<SemearDatabase>();

    _pageLoader = _getSermonList(false);
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
        state._onStopPressed();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.widget.book.title),
        ),
        body: state._hasError
            ? SemearErrorWidget(state._onReloadData)
            : FutureBuilder<List<Sermon>?>(
                future: state._pageLoader,
                builder: (context, snapshot) {
                  if (snapshot.data != null && snapshot.hasData) {
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
        onTap: () async => state._onExpandablePressed(index),
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
                                color: semearGreen,
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
            onTap: () => state._onExpandablePressed(index),
          ),
          state._isLoadingAudio
              ? _buildLoadingAudio()
              : state._showPlayer
                  ? _buildPlayer(context)
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: () => state._onLoadAudioPressed(sermon),
                        child: const Text('Carregar Áudio'),
                      ),
                    ),
        ],
      );

  Widget _buildLoadingAudio() => const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _buildPlayer(context) => Stack(
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
                  builder: (_, value, __) => value.total != Duration.zero
                      ? SemearSlider(
                          progressBarState: value,
                          onSeekChanged: state._onSeekChanged,
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                          child:
                              LinearProgressIndicator(backgroundColor: semearLightGrey),
                        ),
                ),
                StreamBuilder<bool>(
                  stream: state._audioHandler.playbackState
                      .map((state) => state.playing)
                      .distinct(),
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SemearIcon(
                          iconData: Icons.replay_10,
                          onPressed: state._onReplayXSecondsPressed,
                        ),
                        const SizedBox(width: 16.0),
                        IconButton(
                          icon: Container(
                            height: 60.0,
                            width: 60.0,
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
                          onPressed:
                              playing ? state._onPausePressed : state._onPlayPressed,
                        ),
                        const SizedBox(width: 16.0),
                        SemearIcon(
                          iconData: Icons.forward_10,
                          onPressed: state._onForwardXSecondsPressed,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
}
