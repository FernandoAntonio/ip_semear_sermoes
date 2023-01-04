import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../database/semear_database.dart';
import '../repository/semear_repository.dart';
import '../utils/dependency_injection.dart';
import '../utils/widget_view.dart';
import 'semear_widgets.dart';
import 'sermons_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  SermonsBooksPageController createState() => SermonsBooksPageController();
}

class SermonsBooksPageController extends State<BooksPage> {
  late bool _hasError;
  late SemearRepository _repository;
  late SemearDatabase _database;

  Stream<List<Book>> _watchAllBooks() => _database.watchAllBooks();

  Future<void> _getBooksAndStore() async {
    try {
      final booksFromInternet = await _repository.getBooks();
      if (booksFromInternet.isNotEmpty) {
        await _database.storeOrUpdateAllBooks(booksFromInternet);
      }
    } catch (e, stack) {
      debugPrint('$e\n$stack');
      setState(() => _hasError = true);
    }
  }

  Future<void> _getSermonsFromBook(Book book) async => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SermonsPage(book: book)),
      );

  Future<void> _onBookPressed(Book book) async => await _getSermonsFromBook(book);

  Future<void> _onReloadData() async {
    setState(() => _hasError = false);
    return _getBooksAndStore();
  }

  @override
  void initState() {
    super.initState();
    _repository = getIt<SemearRepository>();
    _database = getIt<SemearDatabase>();
    _hasError = false;
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
          : StreamBuilder<List<Book>?>(
              stream: state._watchAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
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
                } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                  state._getBooksAndStore();
                  return const SemearLoadingWidget();
                } else {
                  return const SemearLoadingWidget();
                }
              },
            ),
    );
  }
}
