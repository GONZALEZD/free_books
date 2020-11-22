import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/bookmark.dart';
import 'package:free_books/common/service/database/database_api.dart';
import 'package:free_books/common/service/database/database_objects.dart';

abstract class BookWrapper extends Book {
  Book book;

  BookWrapper({this.book}) : super();

  int get id => this.book.id;

  BookDownloadStatus get status => this.book.status;

  String get downloadFilename => this.book.downloadFilename;

  String get coverFilename => this.book.coverFilename;

  BookDetails get details => this.book.details;

  bool get favorite => this.book.favorite;
}

class ReadingBook extends BookWrapper {
  final List<Bookmark> _bookmarks;
  final DatabaseApi _database;

  ReadingBook({
    List<Bookmark> bookmarks,
    Book book,
    DatabaseApi database,
  })  : _database = database,
        _bookmarks = bookmarks ?? [],
        super(book: book);

  Future<void> addBookMark(Bookmark bookmark) async {
    Bookmark mark = bookmark;
    if (bookmark.type == BookmarkType.automatic) {
      mark = _bookmarks.firstWhere((element) => element.type == BookmarkType.automatic,
          orElse: () => null) ?? bookmark;
      _bookmarks.remove(mark);
      mark = mark.merge(other: bookmark);
    }
    mark = DatabaseBookmark.from(bookmark: mark, bookId: book.id);
    return _database.saveBookmark(bookmark: mark).then((toAdd) => _bookmarks.insert(0, toAdd));
  }

  bool get hasBookmark => _bookmarks.isNotEmpty;
  
  Bookmark get newestBookmark => _bookmarks.isEmpty ? null : _bookmarks.first;

  List<Bookmark> get bookmarks => _bookmarks;
}

class BookDownload extends BookWrapper {
  Future requests;
  final DatabaseApi db;

  final VoidCallback onUpdate;

  BookDownload({Book book, this.db, this.onUpdate}) {
    requests = _insertBook(db, book);
  }
  
  Future<Book> syncBook() async {
    await requests;
    return this.book;
  }

  factory BookDownload.from({BookDetails details, DatabaseApi db, VoidCallback onUpdate}) {
    return BookDownload(
      book: Book(status: BookDownloadStatus.downloading, details: details),
      db: db,
      onUpdate: onUpdate,
    );
  }

  Future<void> _insertBook(DatabaseApi db, Book book) async {
    return db.saveBook(book).then((id) {
      this.book = book.copyWith(id: id);
      if (onUpdate != null) {
        onUpdate();
      }
    });
  }

  Future update({BookDownloadStatus status, String downloadPath, String coverPath}) async {
    requests.then((_) {
      book = book.copyWith(
        status: status,
        downloadPath: downloadPath,
        coverPath: coverPath,
      );
      db.updateBook(book);
      if (onUpdate != null) {
        onUpdate();
      }
    });
  }
}
