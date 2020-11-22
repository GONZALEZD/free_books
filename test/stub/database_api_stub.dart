
import 'package:flutter/foundation.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/database/database_api.dart';
import 'package:free_books/common/service/database/database_objects.dart';

enum DBEvent {
  insertBook,
  updateBook,
  insertBookmark,
  getBooks,
  getBookmarks,
  insertBookDetails,
  insertQuery,
  insertSearchResult,
}

class FakeDatabaseApi extends DatabaseApi {

  final Function(DBEvent event) listener;

  List<Book> storedBooks;
  List<DatabaseBookmark> storedBookmarks;
  List<DatabaseBookQuery> storedQueries;
  List<BookDetails> storedDetails;
  Map<int, BookList> storedResults;

  FakeDatabaseApi({
    @required this.listener,
    List<Book> storedBooks,
    List<DatabaseBookmark> storedBookmarks,
    List<BookQuery> storedQueries,
    List<BookDetails> storedDetails,
    Map<int, BookList> storedResults,
  }){
    this.storedBooks = storedBooks ?? [];
    this.storedBookmarks = storedBookmarks ?? [];
    this.storedQueries = storedQueries ?? [];
    this.storedDetails = storedDetails ?? [];
    this.storedResults = storedResults ?? {};
  }

  @override
  Future<List<DatabaseBookmark>> getBookmark() {
    this.listener(DBEvent.getBookmarks);
    return Future.value(this.storedBookmarks);
  }

  @override
  Future<List<Book>> getBooks() {
    this.listener(DBEvent.getBooks);
    return Future.value(this.storedBooks);
  }

  @override
  Future<int> saveBook(Book book) {
    final id = this.storedBooks.length;
    this.storedBooks.add(book.copyWith(id: id));
    this.listener(DBEvent.insertBook);
    return Future.value(id);
  }

  @override
  Future<DatabaseBookmark> saveBookmark({DatabaseBookmark bookmark}) {
    final id = this.storedBookmarks.length;
    this.storedBookmarks.add(bookmark.copyWith(id: id));
    this.listener(DBEvent.insertBookmark);
    return Future.value(this.storedBookmarks.last);
  }

  @override
  Future<int> saveDetails(BookDetails details) {
    this.storedDetails.add(details);
    this.listener(DBEvent.insertBookDetails);
    return Future.value(this.storedDetails.length-1);
  }

  @override
  Future<DatabaseBookQuery> saveQuery(BookQuery query) {
    final id = this.storedQueries.length;
    final dbQuery = DatabaseBookQuery.fromQuery(query: query).withId(id: id);
    this.storedQueries.add(dbQuery);
    this.listener(DBEvent.insertQuery);
    return Future.value(dbQuery);
  }

  @override
  Future<void> saveQueryResult(BookList queryResult, int queryId) {
    if(this.storedResults.containsKey(queryId)) {
      this.storedResults[queryId] = BookList(
        totalLength: this.storedResults[queryId].totalLength,
        books: this.storedResults[queryId].books + queryResult.books,
      );
    }
    else {
      this.storedResults[queryId] = queryResult;
    }
    this.storedDetails.addAll(queryResult.books);
    this.listener(DBEvent.insertSearchResult);
    return Future.value(null);
  }

  @override
  Future<int> updateBook(Book book) {
    int index = this.storedBooks.indexWhere((b) => b.id == book.id);
    if(index == -1) {
      throw "updateBook method must be used once book have been saved in database (have an ID)";
    }
    this.storedBooks.replaceRange(index, index, [book]);
    this.listener(DBEvent.updateBook);
    return Future.value(index);
  }

  @override
  Future<void> deleteQuery(DatabaseBookQuery query) {
    this.storedQueries.remove(query);
  }

  @override
  Future<List<DatabaseBookQuery>> getQueries() {
    return Future.value(this.storedQueries);
  }

  @override
  Future<BookList> getQueryResult({DatabaseBookQuery query}) {
    return Future.value(this.storedResults[query.id]);
  }
}