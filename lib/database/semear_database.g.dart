// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semear_database.dart';

// ignore_for_file: type=lint
class Book extends DataClass implements Insertable<Book> {
  final String id;
  final String title;
  final String url;
  const Book({required this.id, required this.title, required this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
    };
  }

  Book copyWith({String? id, String? title, String? url}) => Book(
        id: id ?? this.id,
        title: title ?? this.title,
        url: url ?? this.url,
      );
  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> url;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    required String url,
  })  : id = Value(id),
        title = Value(title),
        url = Value(url);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
    });
  }

  BooksCompanion copyWith(
      {Value<String>? id, Value<String>? title, Value<String>? url}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, url];
  @override
  String get aliasedName => _alias ?? 'books';
  @override
  String get actualTableName => 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Sermon extends DataClass implements Insertable<Sermon> {
  final String id;
  final String bookId;
  final String date;
  final String title;
  final String preacher;
  final String series;
  final String passage;
  final String mp3Url;
  const Sermon(
      {required this.id,
      required this.bookId,
      required this.date,
      required this.title,
      required this.preacher,
      required this.series,
      required this.passage,
      required this.mp3Url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['date'] = Variable<String>(date);
    map['title'] = Variable<String>(title);
    map['preacher'] = Variable<String>(preacher);
    map['series'] = Variable<String>(series);
    map['passage'] = Variable<String>(passage);
    map['mp3_url'] = Variable<String>(mp3Url);
    return map;
  }

  SermonsCompanion toCompanion(bool nullToAbsent) {
    return SermonsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      date: Value(date),
      title: Value(title),
      preacher: Value(preacher),
      series: Value(series),
      passage: Value(passage),
      mp3Url: Value(mp3Url),
    );
  }

  factory Sermon.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sermon(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      date: serializer.fromJson<String>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      preacher: serializer.fromJson<String>(json['preacher']),
      series: serializer.fromJson<String>(json['series']),
      passage: serializer.fromJson<String>(json['passage']),
      mp3Url: serializer.fromJson<String>(json['mp3Url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'date': serializer.toJson<String>(date),
      'title': serializer.toJson<String>(title),
      'preacher': serializer.toJson<String>(preacher),
      'series': serializer.toJson<String>(series),
      'passage': serializer.toJson<String>(passage),
      'mp3Url': serializer.toJson<String>(mp3Url),
    };
  }

  Sermon copyWith(
          {String? id,
          String? bookId,
          String? date,
          String? title,
          String? preacher,
          String? series,
          String? passage,
          String? mp3Url}) =>
      Sermon(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        date: date ?? this.date,
        title: title ?? this.title,
        preacher: preacher ?? this.preacher,
        series: series ?? this.series,
        passage: passage ?? this.passage,
        mp3Url: mp3Url ?? this.mp3Url,
      );
  @override
  String toString() {
    return (StringBuffer('Sermon(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('preacher: $preacher, ')
          ..write('series: $series, ')
          ..write('passage: $passage, ')
          ..write('mp3Url: $mp3Url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, date, title, preacher, series, passage, mp3Url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sermon &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.date == this.date &&
          other.title == this.title &&
          other.preacher == this.preacher &&
          other.series == this.series &&
          other.passage == this.passage &&
          other.mp3Url == this.mp3Url);
}

class SermonsCompanion extends UpdateCompanion<Sermon> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> date;
  final Value<String> title;
  final Value<String> preacher;
  final Value<String> series;
  final Value<String> passage;
  final Value<String> mp3Url;
  const SermonsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.preacher = const Value.absent(),
    this.series = const Value.absent(),
    this.passage = const Value.absent(),
    this.mp3Url = const Value.absent(),
  });
  SermonsCompanion.insert({
    required String id,
    required String bookId,
    required String date,
    required String title,
    required String preacher,
    required String series,
    required String passage,
    required String mp3Url,
  })  : id = Value(id),
        bookId = Value(bookId),
        date = Value(date),
        title = Value(title),
        preacher = Value(preacher),
        series = Value(series),
        passage = Value(passage),
        mp3Url = Value(mp3Url);
  static Insertable<Sermon> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? date,
    Expression<String>? title,
    Expression<String>? preacher,
    Expression<String>? series,
    Expression<String>? passage,
    Expression<String>? mp3Url,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (preacher != null) 'preacher': preacher,
      if (series != null) 'series': series,
      if (passage != null) 'passage': passage,
      if (mp3Url != null) 'mp3_url': mp3Url,
    });
  }

  SermonsCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String>? date,
      Value<String>? title,
      Value<String>? preacher,
      Value<String>? series,
      Value<String>? passage,
      Value<String>? mp3Url}) {
    return SermonsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      date: date ?? this.date,
      title: title ?? this.title,
      preacher: preacher ?? this.preacher,
      series: series ?? this.series,
      passage: passage ?? this.passage,
      mp3Url: mp3Url ?? this.mp3Url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (preacher.present) {
      map['preacher'] = Variable<String>(preacher.value);
    }
    if (series.present) {
      map['series'] = Variable<String>(series.value);
    }
    if (passage.present) {
      map['passage'] = Variable<String>(passage.value);
    }
    if (mp3Url.present) {
      map['mp3_url'] = Variable<String>(mp3Url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SermonsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('preacher: $preacher, ')
          ..write('series: $series, ')
          ..write('passage: $passage, ')
          ..write('mp3Url: $mp3Url')
          ..write(')'))
        .toString();
  }
}

class $SermonsTable extends Sermons with TableInfo<$SermonsTable, Sermon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SermonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preacherMeta =
      const VerificationMeta('preacher');
  @override
  late final GeneratedColumn<String> preacher = GeneratedColumn<String>(
      'preacher', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seriesMeta = const VerificationMeta('series');
  @override
  late final GeneratedColumn<String> series = GeneratedColumn<String>(
      'series', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passageMeta =
      const VerificationMeta('passage');
  @override
  late final GeneratedColumn<String> passage = GeneratedColumn<String>(
      'passage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mp3UrlMeta = const VerificationMeta('mp3Url');
  @override
  late final GeneratedColumn<String> mp3Url = GeneratedColumn<String>(
      'mp3_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, date, title, preacher, series, passage, mp3Url];
  @override
  String get aliasedName => _alias ?? 'sermons';
  @override
  String get actualTableName => 'sermons';
  @override
  VerificationContext validateIntegrity(Insertable<Sermon> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('preacher')) {
      context.handle(_preacherMeta,
          preacher.isAcceptableOrUnknown(data['preacher']!, _preacherMeta));
    } else if (isInserting) {
      context.missing(_preacherMeta);
    }
    if (data.containsKey('series')) {
      context.handle(_seriesMeta,
          series.isAcceptableOrUnknown(data['series']!, _seriesMeta));
    } else if (isInserting) {
      context.missing(_seriesMeta);
    }
    if (data.containsKey('passage')) {
      context.handle(_passageMeta,
          passage.isAcceptableOrUnknown(data['passage']!, _passageMeta));
    } else if (isInserting) {
      context.missing(_passageMeta);
    }
    if (data.containsKey('mp3_url')) {
      context.handle(_mp3UrlMeta,
          mp3Url.isAcceptableOrUnknown(data['mp3_url']!, _mp3UrlMeta));
    } else if (isInserting) {
      context.missing(_mp3UrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Sermon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sermon(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      preacher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preacher'])!,
      series: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series'])!,
      passage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}passage'])!,
      mp3Url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mp3_url'])!,
    );
  }

  @override
  $SermonsTable createAlias(String alias) {
    return $SermonsTable(attachedDatabase, alias);
  }
}

abstract class _$SemearDatabase extends GeneratedDatabase {
  _$SemearDatabase(QueryExecutor e) : super(e);
  late final $BooksTable books = $BooksTable(this);
  late final $SermonsTable sermons = $SermonsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books, sermons];
}
