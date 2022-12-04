import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ip_semear_sermoes/semear_widgets.dart';
import 'package:ip_semear_sermoes/sermons_page.dart';

import 'utils/widget_view.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  SermonsBooksPageController createState() => SermonsBooksPageController();
}

class SermonsBooksPageController extends State<BooksPage> {
  late Future<dom.NodeList?> _pageLoader;
  late bool _hasError;
  late Dio _dio;

  Future<dom.NodeList?> _getBookList() async {
    setState(() => _hasError = false);

    try {
      final response = await _dio.get('http://ipsemear.org/sermoes-audio/');
      final parsed = parse(response.data);
      final list = parsed.nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5]
          .nodes[1].nodes[7].nodes;

      return list;
    } catch (e) {
      setState(() => _hasError = true);
      return null;
    }
  }

  Future<void> _getSermonsFromBook(String url, String bookName) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SermonsPage(
          bookSermonUrl: url,
          bookName: bookName,
        ),
      ),
    );
  }

  void _onBookPressed(String url, String bookName) => _getSermonsFromBook(url, bookName);

  void _onRetryPressed() => _pageLoader = _getBookList();

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(connectTimeout: 15000, receiveTimeout: 15000));
    _hasError = false;

    _pageLoader = _getBookList();
  }

  @override
  Widget build(BuildContext context) => _SermonsBooksPageView(this);
}

class _SermonsBooksPageView extends WidgetView<BooksPage, SermonsBooksPageController> {
  const _SermonsBooksPageView(SermonsBooksPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Image.asset(
            'assets/logotipo.png',
            height: kToolbarHeight * 0.8,
          )),
      body: state._hasError
          ? SemearErrorWidget(state._onRetryPressed)
          : FutureBuilder<dom.NodeList?>(
              future: state._pageLoader,
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(4.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index].nodes.first;
                      final sermonBookUrl = data.attributes.values.first;
                      final sermonBookName = data.text ?? '';

                      return SemearBookCard(
                        onPressed: () =>
                            state._onBookPressed(sermonBookUrl, sermonBookName),
                        sermonBookName: sermonBookName,
                      );
                    },
                  );
                } else {
                  return const SemearLoadingWidget();
                }
              }),
    );
  }
}