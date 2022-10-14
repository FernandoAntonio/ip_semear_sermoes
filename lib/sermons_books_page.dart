import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ip_semear_sermoes/sermons_page.dart';

import 'main.dart';
import 'widget_view.dart';

class SermonsBooksPage extends StatefulWidget {
  const SermonsBooksPage({Key? key}) : super(key: key);

  @override
  SermonsBooksPageController createState() => SermonsBooksPageController();
}

class SermonsBooksPageController extends State<SermonsBooksPage> {
  late Dio _dio;
  late bool _isLoading;

  Future<dom.NodeList?> _getBookList() async {
    try {
      final response = await _dio.get('http://ipsemear.org/sermoes-audio/');
      final parsed = parse(response.data);
      final list = parsed.nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5]
          .nodes[1].nodes[7].nodes;

      return list;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _getSermonsFromBook(String url, String bookName) async {
    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);

    navigator.push(
      MaterialPageRoute(
        builder: (_) => SermonsPage(
          bookSermonUrl: url,
          bookName: bookName,
        ),
      ),
    );

    setState(() => _isLoading = false);
  }

  void _onBookPressed(String url, String bookName) => _getSermonsFromBook(url, bookName);

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) => _SermonsBooksPageView(this);
}

class _SermonsBooksPageView
    extends WidgetView<SermonsBooksPage, SermonsBooksPageController> {
  const _SermonsBooksPageView(SermonsBooksPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Image.asset(
            'assets/logotipo.png',
            height: kToolbarHeight * 0.7,
          )),
      body: state._isLoading
          ? _buildLoading(context)
          : FutureBuilder<dom.NodeList?>(
              future: state._getBookList(),
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index].nodes.first;
                      final sermonBookUrl = data.attributes.values.first;
                      final sermonBookName = data.text ?? '';

                      return InkWell(
                        onTap: () => state._onBookPressed(sermonBookUrl, sermonBookName),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.book_outlined,
                                      color: semearOrange.withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Text(
                                      sermonBookName,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: semearGreen,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: semearOrange.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return _buildLoading(context);
                }
              }),
    );
  }

  Widget _buildLoading(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
