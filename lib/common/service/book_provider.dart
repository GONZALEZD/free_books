import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/domain/bookmark.dart';
import 'package:free_books/common/domain/wrapped_book.dart';
import 'package:free_books/common/service/book/books_api.dart';
import 'package:free_books/common/service/database/database_api.dart';
import 'package:free_books/common/service/database/database_objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:free_books/common/app/setting_keys.dart';

enum DownloadStatus {
  notStarted,
  downloading,
  complete,
  canceled,
}

enum _DownloadDirectory {
  cover,
  book,
}

extension _DownloadDirectoryString on _DownloadDirectory {
  String get string {
    switch (this) {
      case _DownloadDirectory.cover:
        return "covers";
      case _DownloadDirectory.book:
        return "books";
    }
    throw "Unknown string representation for value $this";
  }
}

typedef DownloadCallback = void Function(DownloadStatus);

class BookProvider with ChangeNotifier {
  final HttpBooksApi booksApi;

  final DatabaseApi databaseApi;

  List<ReadingBook> _books;
  List<BookDownload> _downloads;
  List<DatabaseBookQuery> _queries;

  DatabaseBookQuery _currentQuery;

  BookList _searchResult;
  bool isSearching;

  BookProvider({this.booksApi, this.databaseApi})
      : _books = [],
        _searchResult = BookList.empty,
        _downloads = [],
        _queries = [],
        isSearching = false,
        assert(booksApi != null),
        assert(databaseApi != null) {
    __loadBooks();
  }

  static BookProvider of(BuildContext context) {
    return context.read<BookProvider>();
  }

  void __loadBooks() async {
    final books = await databaseApi.getBooks();
    final bookmarks = await databaseApi.getBookmark();
    List<Bookmark> tmp;
    _books = books.map((book) {
      tmp = bookmarks.where((item) => item.bookId == book.id).toList();
      tmp.sort((b1, b2) => b1.lastReading.compareTo(b2.lastReading));
      return ReadingBook(
        database: databaseApi,
        bookmarks: tmp ?? [],
        book: book,
      );
    }).toList();
    final unfinishedBooks = _books.where((book) =>
        [BookDownloadStatus.downloading, BookDownloadStatus.cancelled].contains(book.status));
    _downloads = unfinishedBooks.map((readingBook) {
      return BookDownload(
        db: this.databaseApi,
        book: readingBook.copyWith(status: BookDownloadStatus.cancelled),
        onUpdate: this.notifyListeners,
      );
    }).toList();
    _books.removeWhere((element) => unfinishedBooks.contains(element));
    _queries = await databaseApi.getQueries();
    notifyListeners();
  }

  List<BookQuery> get queries => _queries;

  List<Book> get downloaded => _books.reversed.toList(growable: false);

  List<Book> get downloading => _downloads.reversed.toList(growable: false);

  List<Book> get all => (_books.cast<Book>() + _downloads).reversed.toList(growable: false);

  List<Book> get favorites =>
      this.all.where((book) => book.favorite == true).toList(growable: false);

  List<ReadingBook> get read {
    return _books.reversed.where((book) => book.hasBookmark).toList(growable: false)
      ..sort((book1, book2) {
        return book2.newestBookmark.lastReading.compareTo(book1.newestBookmark.lastReading);
      });
  }

  Future<void> addBookmark({Bookmark bookmark, ReadingBook to}) async {
    final book = _books.firstWhere((item) => item.id == to.id);
    await book.addBookMark(bookmark);
    notifyListeners();
  }

  void startDownload(
      {BookDetails bookDetails,
      DownloadCallback onComplete,
      DownloadCaptchaHandler captchaHandler}) async {
    assert(bookDetails != null);
    assert(captchaHandler != null);

    var bookWrapper =
        BookDownload.from(details: bookDetails, db: databaseApi, onUpdate: this.notifyListeners);
    this._downloads.add(bookWrapper);
    var rawCover = await booksApi.getCover(book: bookDetails, type: CoverType.medium);
    final coverFilename = "${bookDetails.id}.img";

    (await _getFile(location: _DownloadDirectory.cover, filename: coverFilename))
        .writeAsBytesSync(rawCover);
    bookWrapper.update(coverPath: coverFilename);
    var rawBook = await booksApi.download(book: bookDetails, captchaHandler: captchaHandler);
    if (rawBook == null) {
      bookWrapper.update(status: BookDownloadStatus.cancelled);
      // user cancelled
      onComplete?.call(DownloadStatus.canceled);
      notifyListeners();
      return;
    }
    final bookFilename = "${bookDetails.id}.epub";
    (await _getFile(location: _DownloadDirectory.book, filename: bookFilename))
        .writeAsBytesSync(rawBook);
    bookWrapper.update(downloadPath: bookFilename, status: BookDownloadStatus.finished);
    _downloads.remove(bookWrapper);
    _books.add(ReadingBook(book: await bookWrapper.syncBook(), database: databaseApi));
    notifyListeners();
    onComplete?.call(DownloadStatus.complete);
  }

  Future<File> _getFile({_DownloadDirectory location, String filename}) async {
    bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final rootDir = isIOS ? await getLibraryDirectory() : await getApplicationSupportDirectory();
    final downloadDir = Directory("${rootDir.path}${Platform.pathSeparator}${location.string}");
    if (!downloadDir.existsSync()) {
      return downloadDir
          .create(recursive: true)
          .then((dir) => File("${dir.path}${Platform.pathSeparator}$filename"));
    }
    return File("${downloadDir.path}${Platform.pathSeparator}$filename");
  }

  Future<File> getCover({Book book}) async {
    if (book?.coverFilename?.isEmpty ?? true) {
      return null;
    }
    return _getFile(location: _DownloadDirectory.cover, filename: book.coverFilename);
  }

  Future<File> getDownload({Book book}) async {
    return _getFile(location: _DownloadDirectory.book, filename: book.downloadFilename);
  }

  BookList get searchResult => _searchResult ?? BookList.empty;
  
  Future<bool> get _shouldSaveQueryInDatabase {
    return SharedPreferences.getInstance().then((prefs) {
      return prefs.getBool(kSaveQueries) ?? true;
    });
  } 

  Future<void> search({BookQuery query}) async {
    final saveQuery = await _shouldSaveQueryInDatabase;
    print("Should save query: $saveQuery");
    if (saveQuery) {
      _currentQuery = await databaseApi.saveQuery(query);
      _queries.add(_currentQuery);
      notifyListeners();
    }
    else {
      _currentQuery = DatabaseBookQuery.fromQuery(query: query);
    }

    return booksApi.search(query: _currentQuery).then((results) {
      _searchResult = results;
      if(saveQuery) {
        databaseApi.saveQueryResult(_searchResult, _currentQuery.id);
      }
      notifyListeners();
    });
  }

  bool loadMoreResults() {
    if (_searchResult.isFullyLoaded) {
      return false;
    }
    isSearching = true;
    notifyListeners();
    booksApi.search(query: _currentQuery, index: _searchResult.books.length).then((results) async {
      if(await _shouldSaveQueryInDatabase) {
        databaseApi.saveQueryResult(results, _currentQuery.id);  
      }
      _searchResult = _searchResult.merge(other: results);
      isSearching = false;
      notifyListeners();
    });
    return true;
  }

  Future<void> deleteQuery(BookQuery query) async {
    if(query is DatabaseBookQuery) {
      await databaseApi.deleteQuery(query);
      _queries.removeWhere((item) => item.id == query.id);
      notifyListeners();
    }
  }

  void clearSearchResult() {
    _searchResult = BookList.empty;
    _currentQuery = null;
    notifyListeners();
  }
}
