import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'database/semear_database.dart';
import 'dependency_injection.dart';
import 'semear_widgets.dart';
import 'sermons_page.dart';
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
  late SemearDatabase _database;

  Future<List<Book>?> _getBookList(bool fromInternet) async {
    setState(() => _hasError = false);

    try {
      List<Book> bookList = [];

      if (!fromInternet) {
        bookList = await _database.getAllBooks();

        if (bookList.isEmpty) {
          var booksFromInternet = await _getBooksFromInternet();
          if (booksFromInternet.isNotEmpty) {
            _storeAndGetBooks(booksFromInternet);
          } else {
            throw Exception();
          }
        }
      } else if (fromInternet) {
        await _database.deleteAllBooks();
        await _database.deleteAllSermons();
        var booksFromInternet = await _getBooksFromInternet();
        if (booksFromInternet.isNotEmpty) {
          bookList = await _storeAndGetBooks(booksFromInternet);
        } else {
          throw Exception();
        }
      }

      return bookList;
    } catch (_) {
      setState(() => _hasError = true);
      return null;
    }
  }

  Future<List<BooksCompanion>> _getBooksFromInternet() async {
    try {
      final response = await _dio.get('http://ipsemear.org/sermoes-audio/');
      final parsed = parse(response.data);
      final list = parsed.nodes[1].nodes[2].nodes[3].nodes[11].nodes[3].nodes[3].nodes[5]
          .nodes[1].nodes[7].nodes;
      List<BooksCompanion> bookList = [];

      for (dom.Node node in list) {
        final data = node.nodes.first;
        final book = BooksCompanion.insert(
          title: data.text ?? '',
          url: data.attributes.values.first,
        );
        bookList.add(book);
      }

      return bookList;
    } catch (_) {
      setState(() => _hasError = true);
      return [];
    }
  }

  Future<List<Book>> _storeAndGetBooks(List<BooksCompanion> bookList) async {
    await _database.storeAllBooks(bookList);
    return await _database.getAllBooks();
  }

  Future<void> _getSermonsFromBook(Book book) async => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SermonsPage(book: book)),
      );

  Future<void> _onBookPressed(Book book) async => await _getSermonsFromBook(book);

  Future<void> _onReloadData() => _pageLoader = _getBookList(true);

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(connectTimeout: 15000, receiveTimeout: 15000));
    _hasError = false;
    _database = getIt<SemearDatabase>();

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
          ? SemearErrorWidget(state._onReloadData)
          : FutureBuilder<List<Book>?>(
              future: state._pageLoader,
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.hasData) {
                  return LiquidPullToRefresh(
                    onRefresh: state._onReloadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4.0),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => AnimatedListItem(
                        key: ValueKey<int>(snapshot.data![index].id),
                        index: index,
                        child: Column(
                          children: [
                            SemearPullToRefresh(index: index),
                            SemearBookCard(
                              onPressed: () =>
                                  state._onBookPressed(snapshot.data![index]),
                              sermonBookName: snapshot.data![index].title,
                            ),
                          ],
                        ),
                      ),
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
