import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'semear_tables.dart';

part 'semear_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

@DriftDatabase(tables: [Books, Sermons])
class SemearDatabase extends _$SemearDatabase {
  SemearDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.drop(books);
          await m.drop(sermons);
          await m.createAll();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  //CREATE
  Future<void> storeAllBooks(List<BooksCompanion> bookList) async {
    for (BooksCompanion book in bookList) {
      await into(books).insert(book);
    }
  }

  Future<void> storeAllSermons(List<SermonsCompanion> sermonList) async {
    for (SermonsCompanion sermon in sermonList) {
      await into(sermons).insert(sermon);
    }
  }

  //READ
  Future<List<Book>> getAllBooks() => select(books).get();
  Future<List<Sermon>> getAllSermonsFromBookId(int bookId) =>
      (select(sermons)..where((sermon) => sermon.bookId.equals(bookId))).get();

  //DELETE
  Future<void> deleteAllBooks() => delete(books).go();
  Future<void> deleteAllSermons() => delete(sermons).go();
  Future<void> deleteAllSermonsWithBookId(int bookId) =>
      (delete(sermons)..where((sermon) => sermon.bookId.equals(bookId))).go();
}
