import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/database/database_api.dart';
import 'package:free_books/common/service/database/database_objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabaseApi implements DatabaseApi {
  static Database _db;
  static const String _DB_NAME = "database.db";

  Future<Database> get db async {
    if (_db == null) {
      final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
      final directory =
          isIOS ? await getLibraryDirectory() : await getApplicationSupportDirectory();
      _db = await openDatabase("${directory.path}${Platform.pathSeparator}$_DB_NAME",
          version: 1, onCreate: this._onDatabaseCreation);
      print(_db.path);
    }
    return _db;
  }

  void _onDatabaseCreation(Database db, int version) {
    db.execute('''
    CREATE TABLE ${DatabaseBookDetails.kTableName} (
      ${DatabaseBookDetails.kId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseBookDetails.kWebId} TEXT, 
      ${DatabaseBookDetails.kTitle} TEXT, 
      ${DatabaseBookDetails.kAuthors} TEXT, 
      ${DatabaseBookDetails.kSubtitle} TEXT, 
      ${DatabaseBookDetails.kPublisher} TEXT, 
      ${DatabaseBookDetails.kEditionDate} TEXT, 
      ${DatabaseBookDetails.kPageCount} INTEGER, 
      ${DatabaseBookDetails.kPrintType} TEXT, 
      ${DatabaseBookDetails.kCategories} TEXT, 
      ${DatabaseBookDetails.kRatingCount} INTEGER, 
      ${DatabaseBookDetails.kAverageRating} INTEGER, 
      ${DatabaseBookDetails.kMaturityRating} TEXT, 
      ${DatabaseBookDetails.kDescription} TEXT, 
      ${DatabaseBookDetails.kThumbnailLink} TEXT, 
      ${DatabaseBookDetails.kDownloadLink} TEXT
    );''');
    db.execute('''
    CREATE TABLE ${DatabaseBook.kTableName} (
      ${DatabaseBook.kId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseBook.kDetails} INTEGER NOT NULL, 
      ${DatabaseBook.kStatus} TEXT, 
      ${DatabaseBook.kDownloadPath} TEXT, 
      ${DatabaseBook.kCoverPath} TEXT, 
      ${DatabaseBook.kFavorite} INTEGER DEFAULT 0,
      FOREIGN KEY(${DatabaseBook.kDetails}) REFERENCES ${DatabaseBookDetails.kTableName}(${DatabaseBookDetails.kId})
    );''');

    db.execute('''
    CREATE TABLE ${DatabaseBookmark.kTableName} (
      ${DatabaseBookmark.kId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseBookmark.kCfi} TEXT,
      ${DatabaseBookmark.kLastReading} INTEGER,
      ${DatabaseBookmark.kType} INTEGER,
      ${DatabaseBookmark.kBookId} INTEGER,
      FOREIGN KEY (${DatabaseBookmark.kBookId}) REFERENCES ${DatabaseBook.kTableName}(${DatabaseBook.kId})
    );''');

    db.execute('''
    CREATE TABLE ${DatabaseBookQuery.kTableName} (
      ${DatabaseBookQuery.kId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseBookQuery.kKeywords} TEXT,
      ${DatabaseBookQuery.kDatetime} INTEGER,
      ${DatabaseBookQuery.kSorting} TEXT,
      ${DatabaseBookQuery.kPrintType} TEXT
    );''');

    db.execute('''
    CREATE TABLE ${DatabaseQueryResult.kTableName} (
      ${DatabaseQueryResult.kTotalResult} INTEGER,
      ${DatabaseQueryResult.kBookDetails} INTEGER NOT NULL,
      ${DatabaseQueryResult.kBookQuery} INTEGER NOT NULL,
      FOREIGN KEY(${DatabaseQueryResult.kBookDetails}) REFERENCES ${DatabaseBookDetails.kTableName}(${DatabaseBookDetails.kId}),
      FOREIGN KEY(${DatabaseQueryResult.kBookQuery}) REFERENCES ${DatabaseBookQuery.kTableName}(${DatabaseBookQuery.kId})
    );''');
  }

  @override
  Future<List<Book>> getBooks() async {
    final Database db = await this.db;
    var res = await db.rawQuery('''
    SELECT * FROM ${DatabaseBook.kTableName} AS B, ${DatabaseBookDetails.kTableName} as D 
    WHERE B.${DatabaseBook.kDetails} = D.${DatabaseBookDetails.kId} 
    ORDER BY B.${DatabaseBook.kId};
    ''');

    return res.map((data) => DatabaseBook.fromMap(data)).toList();
  }

  @override
  Future<List<DatabaseBookmark>> getBookmark() async {
    final Database db = await this.db;
    final res = await db.rawQuery('''SELECT * FROM ${DatabaseBookmark.kTableName};''');

    return res.map((data) => DatabaseBookmark.fromMap(data)).toList();
  }

  @override
  Future<int> saveDetails(BookDetails details) async {
    final db = await this.db;
    return db.insert(DatabaseBookDetails.kTableName, details.toMap());
  }

  @override
  Future<DatabaseBookQuery> saveQuery(BookQuery query) async {
    final db = await this.db;
    var dbQuery = DatabaseBookQuery.fromQuery(query: query);
    final id = await db.insert(DatabaseBookQuery.kTableName, dbQuery.toMap());
    dbQuery = dbQuery.withId(id: id);
    return dbQuery;
  }

  @override
  Future<void> saveQueryResult(BookList queryResult, int queryId) async {
    final db = await this.db;
    for (var book in queryResult.books) {
      int id = await this.saveDetails(book);
      await db.insert(
        DatabaseQueryResult.kTableName,
        DatabaseQueryResult.toMap(queryResult.totalLength, id, queryId),
      );
    }
  }

  @override
  Future<int> saveBook(Book book) async {
    final db = await this.db;
    final detailId = await this.saveDetails(book.details);
    return db.insert(DatabaseBook.kTableName, book.toMap(detailId: detailId));
  }

  @override
  Future<void> updateBook(Book book) async {
    final db = await this.db;
    return db.update(DatabaseBook.kTableName, book.toMap(),
        where: "${DatabaseBook.kId} = ${book.id}");
  }

  @override
  Future<DatabaseBookmark> saveBookmark({DatabaseBookmark bookmark}) async {
    final db = await this.db;
    if (bookmark.id != null) {
      return db
          .update(DatabaseBookmark.kTableName, bookmark.toMap(),
              where: "${DatabaseBookmark.kId} = ${bookmark.id}")
          .then((value) => bookmark);
    }
    return db
        .insert(DatabaseBookmark.kTableName, bookmark.toMap())
        .then((id) => bookmark.copyWith(id: id));
  }

  @override
  Future<void> deleteQuery(DatabaseBookQuery query) async {
    final db = await this.db;

    // TODO: find why 'on delete cascade' is not working, to reduce to one unique delete query
    await db.rawDelete('''
    DELETE FROM ${DatabaseBookDetails.kTableName} 
    WHERE ${DatabaseBookDetails.kId} IN (
       SELECT ${DatabaseQueryResult.kBookDetails} FROM ${DatabaseQueryResult.kTableName} 
       WHERE  ${DatabaseQueryResult.kBookQuery} = ${query.id}
    );
    ''');
    await db.rawDelete('''
    DELETE FROM ${DatabaseQueryResult.kTableName} 
    WHERE ${DatabaseQueryResult.kBookQuery} = ${query.id};
    ''');
    return db.delete(DatabaseBookQuery.kTableName, where: "${DatabaseBookQuery.kId} = ${query.id}");
  }

  @override
  Future<List<DatabaseBookQuery>> getQueries() async {
    final db = await this.db;
    final results = await db.query(DatabaseBookQuery.kTableName);
    return results.map((data) => DatabaseBookQuery.fromMap(data)).toList();
  }

  @override
  Future<BookList> getQueryResult({DatabaseBookQuery query}) async {
    final db = await this.db;
    final results = await db.rawQuery('''
    SELECT R.${DatabaseQueryResult.kTotalResult},D.* FROM ${DatabaseQueryResult.kTableName} AS R, ${DatabaseBookDetails.kTableName} as D 
    WHERE R.${DatabaseQueryResult.kBookQuery} = ${query.id} AND D.${DatabaseBookDetails.kId} = R.${DatabaseQueryResult.kBookDetails} 
    ORDER BY R.${DatabaseQueryResult.kBookDetails} ASC
    ''');
    return BookList(
      totalLength: results.first["DatabaseQueryResult.kTotalResult"],
      books: results.map((data) => DatabaseBookDetails.fromMap(data)),
    );
  }
}
