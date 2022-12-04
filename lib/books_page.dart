import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:ip_semear_sermoes/database/semear_database.dart';
import 'package:ip_semear_sermoes/semear_widgets.dart';
import 'package:ip_semear_sermoes/sermons_page.dart';
import 'package:ip_semear_sermoes/utils/constants.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';
import 'utils/widget_view.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  SermonsBooksPageController createState() => SermonsBooksPageController();
}

class SermonsBooksPageController extends State<BooksPage> {
  late Future<List<Book>?> _pageLoader;
  late bool _hasError;
  late Dio _dio;

  Future<List<Book>?> _getBookList(bool fromInternet) async {
    setState(() => _hasError = false);

    try {
      List<Book> bookList = [];

      if (!fromInternet) {
        bookList = await database.getAllBooks();

        if (bookList.isEmpty) {
          bookList = await _getBooksFromInternet();
          if (bookList.isNotEmpty) {
            _storeBooks(bookList);
          } else {
            throw Exception();
          }
        }
      } else if (fromInternet) {
        await database.deleteAllBooks();
        bookList = await _getBooksFromInternet();
        if (bookList.isNotEmpty) {
          _storeBooks(bookList);
        } else {
          throw Exception();
        }
      }

      return bookList;
    } catch (e) {
      setState(() => _hasError = true);
      return null;
    }
  }

  Future<List<Book>> _getBooksFromInternet() async {
    try {
      final response = await _dio.get('http://ipsemear.org/sermoes-audio/');
      final parsed = parse(response.data);
      final list = parsed.nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5]
          .nodes[1].nodes[7].nodes;
      List<Book> bookList = [];

      for (dom.Node node in list) {
        final data = node.nodes.first;
        final book = Book(
          id: const Uuid().v4(),
          title: data.text ?? '',
          url: data.attributes.values.first,
        );
        bookList.add(book);
      }

      return bookList;
    } catch (e) {
      setState(() => _hasError = true);
      return [];
    }
  }

  Future<void> _storeBooks(List<Book> bookList) async => database.storeAllBooks(bookList);

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

  void _onRetryPressed() => _pageLoader = _getBookList(false);

  Future<void> _onPullToRefresh() => _pageLoader = _getBookList(true);

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(connectTimeout: 15000, receiveTimeout: 15000));
    _hasError = false;

    _pageLoader = _getBookList(false);
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
          : FutureBuilder<List<Book>?>(
              future: state._pageLoader,
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.hasData) {
                  return LiquidPullToRefresh(
                    onRefresh: state._onPullToRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4.0),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            index == 0
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Puxe para atualizar',
                                          style: TextStyle(color: semearLightGrey),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: semearLightGrey,
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            SemearBookCard(
                              onPressed: () => state._onBookPressed(
                                  snapshot.data![index].url, snapshot.data![index].title),
                              sermonBookName: snapshot.data![index].title,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                } else {
                  return const SemearLoadingWidget();
                }
              },
            ),
    );
  }
}
