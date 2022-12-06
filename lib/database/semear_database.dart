import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'semear_database.g.dart';

class Books extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get title => text()();
  TextColumn get url => text()();
}

class Sermons extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get bookId => text()();
  TextColumn get date => text()();
  TextColumn get title => text()();
  TextColumn get preacher => text()();
  TextColumn get series => text()();
  TextColumn get passage => text()();
  TextColumn get mp3Url => text()();
  TextColumn get downloadedMp3Path => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Books, Sermons])
class SemearDatabase extends _$SemearDatabase {
  SemearDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  //CREATE
  Future<void> storeAllBooks(List<Book> bookList) async {
    for (Book book in bookList) {
      await into(books).insert(BooksCompanion.insert(title: book.title, url: book.url));
    }
  }

  Future<void> storeAllSermons(List<Sermon> sermonList) async {
    for (Sermon sermon in sermonList) {
      await into(sermons).insert(SermonsCompanion.insert(
        bookId: sermon.bookId,
        title: sermon.title,
        date: sermon.date,
        mp3Url: sermon.mp3Url,
        passage: sermon.passage,
        series: sermon.series,
        preacher: sermon.preacher,
      ));
    }
  }

  //READ
  Future<List<Book>> getAllBooks() => select(books).get();
  Future<List<Sermon>> getAllSermonsFromBookId(String bookId) =>
      (select(sermons)..where((sermon) => sermon.bookId.equals(bookId))).get();

  //DELETE
  Future<void> deleteAllBooks() => delete(books).go();
  Future<void> deleteAllSermonsWithBookId(String bookId) =>
      (delete(sermons)..where((sermon) => sermon.bookId.equals(bookId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
