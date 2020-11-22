import 'package:flutter_test/flutter_test.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/book/books_api.dart';
import 'package:free_books/common/service/book/google_books_api.dart';

void main() {
  group("Google Books Query Builder", () {
    test("query", () {
      final queryBuilder =
          GoogleBooksQueryBuilder(apiKey: "01234567890", root: "https://toto.com/");
      final BookQuery query = BookQuery(
        sorting: BookSorting.newest,
        printType: PrintType.books,
        keywords: ["Fables", "Legendes"],
      );
      final String actual = queryBuilder.search(query: query, startIndex: 12);
      final expected = """
https://toto.com/?q=Fables+Legendes&filter=free-ebooks&download=epub&startIndex=12
&printType=books&orderBy=newest&key=01234567890
""";
      expect(actual, expected.replaceAll("\n", ""));
    });
    test("details", () {
      final queryBuilder =
          GoogleBooksQueryBuilder(apiKey: "01234567890", root: "https://toto.com/");
      final BookDetails book = BookDetails(id: "zyTCAlFPjgYC");
      final String actual = queryBuilder.details(book: book);
      final expected = "https://toto.com/zyTCAlFPjgYC?key=01234567890";
      expect(actual, expected);
    });
    test("download", () {
      final queryBuilder =
          GoogleBooksQueryBuilder(apiKey: "01234567890", root: "https://toto.com/");
      final BookDetails book = BookDetails(downloadLink: "https://coucou.fr/download?id=my_epub");
      final String actual = queryBuilder.download(book: book);
      final expected = "https://coucou.fr/download?id=my_epub&output=epub&key=01234567890";
      expect(actual, expected);
    });
  });

  group("Google Books Api", () {
    test("search", () async {
      final booksApi = GoogleBooksApi();
      final BookQuery query = BookQuery(
        sorting: BookSorting.newest,
        printType: PrintType.books,
        keywords: ["Fables", "Legendes"],
      );
      var actual = await booksApi.search(query: query, index: 0);

      expect(actual, isNotNull);
      expect(actual.books, isNotEmpty);
      expect(actual.totalLength, greaterThan(0));
    });
    test("get medium cover", () async {
      final booksApi = GoogleBooksApi();
      final BookDetails book = BookDetails(
        id: "xnFEAQAAMAAJ",
      );
      var cover = await booksApi.getCover(book: book, type: CoverType.medium);
      expect(cover, isNotNull);
      expect(cover.length, greaterThan(1000));
    });
    test("get thumbnail", () async {
      final booksApi = GoogleBooksApi();
      final BookDetails book = BookDetails(
        id: "gK98gXR8onwC",
        thumbnailLink:
            "http://books.google.com/books/content?id=wAUiAAAAMAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE71G25VAGo5_gDs96kgYxw1qA6rKpqWQebYam_hPq8lt7P1QQsnQWJCJeUcaroh2M1gkoiW3EG0fZTezTN9oL-DoshAKiRKUiEcs702AgZi-kP53ZFUn8FKZlqPxj7oBbKtZaV7t&source=gbs_api",
      );
      var thumbnail = await booksApi.getCover(book: book, type: CoverType.thumbnail);
      expect(thumbnail, isNotNull);
      expect(thumbnail.length, greaterThan(1000));
    });

    test("download", () async {
      final booksApi = GoogleBooksApi();
      final BookDetails book = BookDetails(
          id: "w5ZcAAAAMAAJ",
          downloadLink:
              "http://books.google.fr/books/download/Les_Fleurs_Du_Mal.epub?id=w5ZcAAAAMAAJ&hl=&output=epub&source=gbs_api");
      var epub = await booksApi.download(
        book: book,
        captchaHandler: (str) => Future.value(
            "https://www.gutenberg.org/ebooks/63797.epub.noimages?session_id=7169c5d214e7037ac9ba92f7ff0100f7ed01339a"),
      );
      expect(epub, isNotNull);
      // on the website, epub is shown as 137ko. (so acceptable value is 136ko)
      expect(epub.length, greaterThan(136 * 1024));
    });
  });
}
