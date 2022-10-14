import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ip_semear_sermoes/main.dart';

import 'models.dart';
import 'player_widget.dart';
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
  late Dio _dio;
  late AudioPlayer _player;
  late List<ExpandableController> _expandableControllers;
  late bool _showPlayer;
  late bool _isLoadingAudio;

  Future<List<Sermon>> _getSermons() async {
    //Get data from page
    final response = await _dio.get(widget.bookSermonUrl);
    final parsed = parse(response.data);
    final bookSermons =
        parsed.nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5].nodes[3];

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

    return sermons.reversed.toList();
  }

  Future<void> _onExpandablePressed(int index) async {
    setState(() => _expandableControllers[index].toggle());

    for (var i = 0; i < _expandableControllers.length; i++) {
      if (i != index && _expandableControllers[i].expanded) {
        _expandableControllers[i].toggle();
      }
    }

    await _player.stop();
    setState(() => _showPlayer = false);
  }

  _onStartPressed(String mp3Url) async {
    setState(() {
      _showPlayer = false;
      _isLoadingAudio = true;
    });

    await _player.setSource(UrlSource(mp3Url));

    setState(() {
      _showPlayer = true;
      _isLoadingAudio = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _player = AudioPlayer();
    _expandableControllers = [];
    _showPlayer = false;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(state.widget.bookName),
      ),
      body: FutureBuilder<List<Sermon>>(
        future: state._getSermons(),
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.hasData) {
            snapshot.data?.forEach(
                (_) => state._expandableControllers.add(ExpandableController()));

            return ListView.builder(
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
            return _buildLoading();
          }
        },
      ),
    );
  }

  Widget _buildCollapsed(Sermon sermon, int index) => InkWell(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
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
                      Column(
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
                ? _buildLoading()
                : state._showPlayer
                    ? PlayerWidget(player: state._player)
                    : TextButton(
                        onPressed: () => state._onStartPressed(sermon.mp3Url),
                        child: const Text('Carregar Áudio')),
          ),
        ],
      );

  Widget _buildLoading() => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
}
