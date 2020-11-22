import 'package:flutter_test/flutter_test.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/domain/bookmark.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/common/service/database/database_objects.dart';

import 'stub/database_api_stub.dart';
import 'stub/http_book_api_stub.dart';
import 'tools/event_listener.dart';

void main() {
  var generateDetails = (int index) {
    return BookDetails(
      id: "AAAAA$index",
      downloadLink: "downloadLink$index",
      thumbnailLink: "thumbnailLink$index",
      title: "Title book details $index",
      authors: ["Author $index"],
    );
  };
  var generateBook = (int index, {BookDownloadStatus status = BookDownloadStatus.finished}) {
    return Book(
      id: index,
      favorite: index.isEven,
      status: status,
      coverFilename: "cover$index.img",
      downloadFilename: "book$index.epub",
      details: generateDetails(index),
    );
  };
  var generateBookmark = (int index) {
    return DatabaseBookmark(
      bookId: index,
      id: index,
      lastReading: DateTime.now(),
      type: BookmarkType.user,
      cfi: "cfi__$index",
    );
  };
  var generateBookQuery = (int index) {
    return BookQuery(
      keywords: ["word$index"],
      datetime: DateTime.now(),
      sorting: BookSorting.relevance,
      printType: PrintType.all,
    );
  };
  group("Book Provider", () {
    test("Provider Loading", () async {
      final dbListener = EventListener<DBEvent>();
      final dbApi = FakeDatabaseApi(
          listener: dbListener.receive,
          storedBooks: List<Book>.generate(10, generateBook) + List<Book>.generate(
              3, (index) => generateBook(index, status: BookDownloadStatus.downloading)),
          storedBookmarks: List<DatabaseBookmark>.generate(4, generateBookmark)
      );
      final provider = BookProvider(
        databaseApi: dbApi,
        booksApi: HttpBookApiStub(),
      );
      await Future.delayed(Duration(milliseconds: 100));
      expect(dbListener.occurences(DBEvent.getBooks), greaterThanOrEqualTo(1));
      expect(dbListener.occurences(DBEvent.getBookmarks), greaterThanOrEqualTo(1));
      expect(provider.all, isNotEmpty);
      expect(provider.all.length, 13);

      expect(provider.downloaded, isNotEmpty);
      expect(provider.downloaded.length, 10);

      expect(provider.read, isNotEmpty);
      expect(provider.read.length, 4);

      expect(provider.downloading, isNotEmpty);
      expect(provider.downloading.length, 3);

      expect(provider.favorites, isNotEmpty);
      expect(provider.favorites.length, 7);
    });

    test("Query search", () async {
      final listener = EventListener<HttpApiEvent>();
      final dbListener = EventListener<DBEvent>();
      final dbApi = FakeDatabaseApi(
        listener: dbListener.receive,
      );
      final provider = BookProvider(
        databaseApi: dbApi,
        booksApi: HttpBookApiStub(
          listener: listener.receive,
          paginationLength: 12,
          queryResults: List<BookDetails>.generate(30, generateDetails),
        ),
      );
      final query = generateBookQuery(0);
      await provider.search(query: query);
      expect(provider.searchResult, isNotNull);
      expect(provider.searchResult.length, 12);
      expect(provider.searchResult.totalLength, 30);

      final haveMoreResults = provider.loadMoreResults();
      expect(haveMoreResults, true);
      await Future.delayed(Duration(milliseconds: 100));
      expect(provider.searchResult.length, 24);
      final haveMoreResults2 = provider.loadMoreResults();
      expect(haveMoreResults2, true);
      await Future.delayed(Duration(milliseconds: 100));
      expect(provider.searchResult.length, 30);
      expect(listener.occurences(HttpApiEvent.search), 3);

      expect(dbListener.occurences(DBEvent.insertQuery), 1);
      expect(dbListener.occurences(DBEvent.insertSearchResult), 3);
      expect(dbApi.storedResults.length, 1);
      expect(dbApi.storedResults[0].length, 30);
      expect(dbApi.storedDetails.length, 30);
    });
  });
}
