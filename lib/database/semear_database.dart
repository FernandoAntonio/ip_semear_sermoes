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
    for (BooksCompanion bookCompanion in bookList) {
      final book = await (select(books)
            ..where((b) => b.title.equals(bookCompanion.title.value))
            ..where((s) => s.url.equals(bookCompanion.url.value)))
          .getSingleOrNull();
      if (book != null) {
        await update(books).replace(book);
      } else {
        await into(books).insert(bookCompanion);
      }
    }
  }

  Future<void> storeAllSermons(List<SermonsCompanion> sermonList) async {
    for (SermonsCompanion sermonCompanion in sermonList) {
      final sermon = await (select(sermons)
            ..where((s) => s.bookId.equals(sermonCompanion.bookId.value))
            ..where((s) => s.title.equals(sermonCompanion.title.value))
            ..where((s) => s.mp3Url.equals(sermonCompanion.mp3Url.value)))
          .getSingleOrNull();
      if (sermon != null) {
        await update(sermons).replace(sermon);
      } else {
        await into(sermons).insert(sermonCompanion);
      }
    }
  }

  //READ
  Stream<List<Book>> watchAllBooks() => select(books).watch();
  Stream<List<Sermon>> watchAllSermonsFromBookId(int bookId) =>
      (select(sermons)..where((sermon) => sermon.bookId.equals(bookId))).watch();

  //UPDATE
  Future<void> addBookmarkToSermon(int sermonId, int bookmarkInSeconds) =>
      (update(sermons)..where((sermon) => sermon.id.equals(sermonId)))
          .write(SermonsCompanion(bookmarkInSeconds: Value(bookmarkInSeconds)));

  Future<void> removeBookmarkFromSermon(int sermonId) =>
      (update(sermons)..where((sermon) => sermon.id.equals(sermonId)))
          .write(const SermonsCompanion(bookmarkInSeconds: Value(null)));

  //DELETE
  Future<void> deleteAllBooks() => delete(books).go();

  Future<void> deleteAllSermons() => delete(sermons).go();

  Future<void> deleteAllSermonsWithBookId(int bookId) =>
      (delete(sermons)..where((sermon) => sermon.bookId.equals(bookId))).go();
}
