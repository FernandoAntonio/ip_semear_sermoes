import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'semear_database.g.dart';

class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get url => text()();
}

class Sermons extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get title => text()();
  TextColumn get preacher => text()();
  TextColumn get series => text()();
  TextColumn get passage => text()();
  TextColumn get mp3Url => text()();
}

@DriftDatabase(tables: [Books, Sermons])
class SemearDatabase extends _$SemearDatabase {
  SemearDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  //CREATE
  Future<void> storeAllBooks(List<Book> bookList) async {
    for (Book book in bookList) {
      await into(books)
          .insert(BooksCompanion.insert(id: book.id, title: book.title, url: book.url));
    }
  }

  //READ
  Future<List<Book>> getAllBooks() => select(books).get();

  //DELETE
  Future<void> deleteAllBooks() => delete(books).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
