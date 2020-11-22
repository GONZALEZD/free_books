import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/database/database_objects.dart';

abstract class DatabaseApi {
  Future<List<Book>> getBooks();

  Future<List<DatabaseBookmark>> getBookmark();

  Future<int> saveDetails(BookDetails details);

  Future<DatabaseBookQuery> saveQuery(BookQuery query);

  Future<void> saveQueryResult(BookList queryResult, int queryId);

  Future<int> saveBook(Book book);

  Future<void> updateBook(Book book);

  Future<DatabaseBookmark> saveBookmark({DatabaseBookmark bookmark});

  Future<List<DatabaseBookQuery>> getQueries();

  Future<BookList> getQueryResult({DatabaseBookQuery query});

  Future<void> deleteQuery(DatabaseBookQuery query);

}
