import 'package:drift/drift.dart';

class Books extends Table with AutoIncrementingPrimaryKey {
  TextColumn get title => text()();
  TextColumn get url => text()();
}

class Sermons extends Table with AutoIncrementingPrimaryKey {
  IntColumn get bookId => integer()();
  TextColumn get date => text()();
  TextColumn get title => text()();
  TextColumn get preacher => text()();
  TextColumn get series => text()();
  TextColumn get passage => text()();
  TextColumn get mp3Url => text()();
  IntColumn get bookmarkInSeconds => integer().nullable()();
  TextColumn get downloadedMp3Path => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}
