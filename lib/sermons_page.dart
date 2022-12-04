import 'package:dio/dio.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ip_semear_sermoes/main.dart';
import 'package:ip_semear_sermoes/semear_widgets.dart';

import 'audio_player_handler.dart';
import 'models.dart';
import 'widget_view.dart';

class SermonsPage extends StatefulWidget {
  final String bookSermonUrl;
  final String bookName;

  const SermonsPage({
    required this.bookSermonUrl,
    required this.bookName,
    Key? key,
  }) : super(key: key);

  @override
  SermonsSingleBookPageController createState() => SermonsSingleBookPageController();
}

class SermonsSingleBookPageController extends State<SermonsPage> {
  late Future<List<Sermon>> _pageLoader;
  late Dio _dio;
  late List<ExpandableController> _expandableControllers;
  late bool _showPlayer;
  late bool _isLoadingAudio;
  late bool _hasError;

  Future<List<Sermon>> _getSermons() async {
    setState(() => _hasError = false);

    //Get data from page
    late dom.Node bookSermons;
    try {
      final response = await _dio.get(widget.bookSermonUrl);
      final parsed = parse(response.data);
      bookSermons =
          parsed.nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5].nodes[3];
    } catch (_) {
      _hasError = true;
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
    final List<Sermon> sermons = [];

    try {
      if (paginationSize > 1) {
        for (var index = 2; index <= paginationSize; index++) {
          final response = await _dio.get('${widget.bookSermonUrl}page/$index');
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
        final sermon = Sermon(
            date: node.nodes[1].nodes[0].text?.trim() ?? '',
            title: node.nodes[3].nodes[0].nodes[0].text?.trim() ?? '',
            preacher: node.nodes[6].text?.replaceAll('|', '').trim() ?? '',
            series: node.nodes[8].text?.replaceAll('|', '').trim() ?? '',
            passage: node.nodes[10].text?.trim() ?? '',
            mp3Url: node.nodes[11].nodes[2].attributes['href'].toString());
        sermons.add(sermon);
      }
    } catch (_) {
      _hasError = true;
    }

    return sermons.reversed.toList();
  }

  void _onPlayPressed() => audioHandler.play();

  void _onPausePressed() => audioHandler.pause();

  void _onSeekChanged(double newSecondsValue) =>
      audioHandler.seek(Duration(seconds: newSecondsValue.toInt()));

  void _onStopPressed() {
    audioHandler.stop();
    setState(() => _showPlayer = false);
  }

  void _onReplayXSecondsPressed() => audioHandler
      .seek(audioHandler.progressNotifier.value.current - const Duration(seconds: 10));

  void _onForwardXSecondsPressed() => audioHandler
      .seek(audioHandler.progressNotifier.value.current + const Duration(seconds: 10));

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

    await audioHandler.setSermon(sermon);

    setState(() {
      _showPlayer = true;
      _isLoadingAudio = false;
    });
  }

  void _onRetryPressed() => _pageLoader = _getSermons();

  String _formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${int.parse(hours) > 0 ? '$hours:' : ''}$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(connectTimeout: 15000, receiveTimeout: 15000));
    _expandableControllers = [];
    _showPlayer = false;
    _isLoadingAudio = false;

    _pageLoader = _getSermons();
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
          title: Text(state.widget.bookName),
        ),
        body: state._hasError
            ? SemearErrorWidget(state._onRetryPressed)
            : FutureBuilder<List<Sermon>>(
                future: state._pageLoader,
                builder: (context, snapshot) {
                  if (snapshot.data != null && snapshot.hasData) {
                    snapshot.data?.forEach(
                        (_) => state._expandableControllers.add(ExpandableController()));

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      padding: const EdgeInsets.all(4.0),
                      itemBuilder: (context, index) {
                        final sermon = snapshot.data![index];
                        return Card(
                          child: ExpandableNotifier(
                            child: Expandable(
                              controller: state._expandableControllers[index],
                              theme: const ExpandableThemeData(
                                iconColor: Colors.white,
                              ),
                              collapsed: _buildCollapsed(sermon, index),
                              expanded: _buildExpanded(sermon, index),
                            ),
                          ),
                        );
                      },
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
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        onTap: () async => state._onExpandablePressed(index),
      );

  Widget _buildExpanded(Sermon sermon, int index) => Column(
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
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_up,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Pregador: ${sermon.preacher}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    sermon.date,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            onTap: () => state._onExpandablePressed(index),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: state._isLoadingAudio
                ? _buildLoadingAudio()
                : state._showPlayer
                    ? _buildControls()
                    : TextButton(
                        onPressed: () => state._onLoadAudioPressed(sermon),
                        child: const Text('Carregar Áudio')),
          ),
        ],
      );

  Widget _buildLoadingAudio() => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _buildControls() {
    return Column(
      children: [
        // Play/pause/stop buttons.
        StreamBuilder<bool>(
          stream: audioHandler.playbackState.map((state) => state.playing).distinct(),
          builder: (context, snapshot) {
            final playing = snapshot.data ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  color: semearGreen,
                  icon: const Icon(Icons.replay_10),
                  iconSize: 40.0,
                  onPressed: state._onReplayXSecondsPressed,
                ),
                IconButton(
                  color: semearGreen,
                  icon: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 40.0,
                  onPressed: playing ? state._onPausePressed : state._onPlayPressed,
                ),
                IconButton(
                  color: semearGreen,
                  icon: const Icon(Icons.stop),
                  iconSize: 40.0,
                  onPressed: state._onStopPressed,
                ),
                IconButton(
                  color: semearGreen,
                  icon: const Icon(Icons.forward_10),
                  iconSize: 40.0,
                  onPressed: state._onForwardXSecondsPressed,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24.0),
        ValueListenableBuilder<ProgressBarState>(
          valueListenable: audioHandler.progressNotifier,
          builder: (_, value, __) => value.total != Duration.zero
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state._formatDuration(value.current),
                      style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                    ),
                    Expanded(
                      child: Slider(
                        label: state._formatDuration(value.current),
                        divisions: value.total.inSeconds,
                        max: value.total.inSeconds.toDouble(),
                        value: value.current.inSeconds.toDouble(),
                        onChanged: state._onSeekChanged,
                      ),
                    ),
                    Text(
                      state._formatDuration(value.total),
                      style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ],
    );
  }
}
