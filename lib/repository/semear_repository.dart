import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '../database/semear_database.dart';

class SemearRepository {
  final Dio _dio;

  SemearRepository({required Dio dio}) : _dio = dio;

  Future<List<BooksCompanion>> getBooks() async {
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
  }

  Future<List<SermonsCompanion>> getSermonsFromBook(Book book) async {
    //Get data from page
    late dom.Node bookSermons;

    final response = await _dio.get(book.url);
    final parsed = parse(response.data);
    bookSermons =
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
    final List<SermonsCompanion> sermons = [];

    if (paginationSize > 1) {
      for (var index = 2; index <= paginationSize; index++) {
        final response = await _dio.get('${book.url}page/$index');
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
        bookId: book.id,
        date: node.nodes[1].nodes[0].text?.trim() ?? '',
        title: node.nodes[3].nodes[0].nodes[0].text?.trim() ?? '',
        preacher: node.nodes[6].text?.replaceAll('|', '').trim() ?? '',
        series: node.nodes[8].text?.replaceAll('|', '').trim() ?? '',
        passage: node.nodes[10].text?.trim() ?? '',
        mp3Url: node.nodes[11].nodes[2].attributes['href'].toString(),
      );
      sermons.add(sermon);
    }

    return sermons.reversed.toList();
  }
}
