import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/domain/bookmark.dart';

extension DatabaseBookDetails on BookDetails {
  static const kTableName = "bookDetails";
  static const kId = "detailsID";
  static const kWebId = "identifier";
  static const kTitle = "title";
  static const kSubtitle = "subTitle";
  static const kAuthors = "authors";
  static const kPublisher = "publisher";
  static const kEditionDate = "editionDate";
  static const kPageCount = "pageCount";
  static const kPrintType = "printType";
  static const kCategories = "categories";
  static const kRatingCount = "ratingCount";
  static const kAverageRating = "averageRating";
  static const kMaturityRating = "maturityRating";
  static const kDescription = "description";
  static const kThumbnailLink = "thumbnailLink";
  static const kDownloadLink = "downloadLink";

  static BookDetails fromMap(Map<String, dynamic> map) {
    return BookDetails(
      id: map[kWebId],
      title: map[kTitle],
      subTitle: map[kSubtitle],
      authors: (map[kAuthors] as String).split(","),
      description: map[kDescription],
      rating: BookRating(
        maturityRating: RatingMaturityString.parse(map[kMaturityRating]),
        averageRating: map[kAverageRating],
        ratingCount: map[kRatingCount],
      ),
      category: BookCategory(
        type: PrintTypeString.parse(map[kPrintType]),
        categories: (map[kCategories] as String).split(","),
      ),
      pageCount: map[kPageCount],
      edition: BookEdition(
        publisher: map[kPublisher],
        publishedDate: map[kEditionDate],
      ),
      thumbnailLink: map[kThumbnailLink],
      downloadLink: map[kDownloadLink],
    );
  }

  Map<String, dynamic> toMap() => {
        kWebId: this.id,
        kTitle: this.title,
        kSubtitle: this.subTitle,
        kAuthors:
            (this.authors?.isNotEmpty ?? false) ? this.authors.reduce((a1, a2) => "$a1,$a2") : "",
        kPublisher: this.edition?.publisher ?? null,
        kEditionDate: this.edition?.publishedDate ?? null,
        kPageCount: this.pageCount,
        kPrintType: this.category?.type?.string ?? null,
        kCategories: this.category.categories.isNotEmpty
            ? this.category.categories.reduce((c1, c2) => "$c1,$c2")
            : "",
        kRatingCount: this.rating?.ratingCount ?? null,
        kAverageRating: this.rating?.averageRating ?? null,
        kMaturityRating: this.rating?.maturityRating?.string ?? null,
        kDescription: this.description,
        kThumbnailLink: this.thumbnailLink,
        kDownloadLink: this.downloadLink,
      };
}

class DatabaseBookmark extends Bookmark {
  static const kTableName = "bookmark";
  static const kId = "bookmarkID";
  static const kCfi = "cfi";
  static const kLastReading = "lastReading";
  static const kType = "type";
  static const kBookId = "book";

  final int bookId;

  DatabaseBookmark({int id, this.bookId, DateTime lastReading, BookmarkType type, String cfi})
      : super(cfi: cfi, type: type, lastReading: lastReading, id: id);

  factory DatabaseBookmark.from({Bookmark bookmark, int bookId}) {
    return DatabaseBookmark(
      lastReading: bookmark.lastReading,
      type: bookmark.type,
      cfi: bookmark.cfi,
      id: bookmark.id,
      bookId: bookId,
    );
  }

  DatabaseBookmark copyWith({int id}) {
    return DatabaseBookmark(
      id: id ?? this.id,
      bookId: this.bookId,
      cfi: this.cfi,
      lastReading: this.lastReading,
      type: this.type,
    );
  }

  @override
  Bookmark merge({Bookmark other}) {
    return DatabaseBookmark(
      id: other.id ?? this.id,
      bookId: (other is DatabaseBookmark) ? other.bookId ?? this.bookId : this.bookId,
      lastReading: other.lastReading ?? this.lastReading,
      cfi: other.cfi ?? this.cfi,
      type: other.type ?? this.type,
    );
  }

  static DatabaseBookmark fromMap(Map<String, dynamic> map) {
    return DatabaseBookmark(
      id: map[kId],
      bookId: map[kBookId],
      cfi: map[kCfi],
      lastReading: DateTime.fromMillisecondsSinceEpoch(map[kLastReading]),
      type: BookmarkTypeString.parse(map[kType]),
    );
  }

  Map<String, dynamic> toMap() {
    var map = {
      kCfi: this.cfi,
      kLastReading: this.lastReading.millisecondsSinceEpoch,
      kType: this.type?.string ?? BookmarkType.automatic.string,
    };
    if (this.bookId != null) map[kBookId] = this.bookId;
    if (this.id != null) map[kId] = this.id;
    return map;
  }
}

class DatabaseBookQuery extends BookQuery {
  static const kTableName = "bookQuery";
  static const kId = "bookQueryID";

  static const kKeywords = "keywords";
  static const kDatetime = "queryDatetime";
  static const kSorting = "sorting";
  static const kPrintType = "printType";

  final int id;

  DatabaseBookQuery({this.id, List<String> keywords, BookSorting sorting, PrintType printType, DateTime datetime})
      : super(keywords: keywords, sorting: sorting, printType: printType, datetime: datetime);

  factory DatabaseBookQuery.fromQuery({BookQuery query}) {
    return DatabaseBookQuery(
      printType: query.printType,
      sorting: query.sorting,
      keywords: query.keywords,
      datetime: query.datetime,
    );
  }

  DatabaseBookQuery withId({int id}) {
    return DatabaseBookQuery(
      id: id,
      sorting: this.sorting,
      printType: this.printType,
      keywords: this.keywords,
      datetime: this.datetime,
    );
  }

  static DatabaseBookQuery fromMap(Map<String, dynamic> map) {
    return DatabaseBookQuery(
      id: map[kId],
      keywords: map[kKeywords] == null? [] : (map[kKeywords] as String).split(","),
      printType: PrintTypeString.parse(map[kPrintType]),
      sorting: BookSortingString.parse(map[kSorting]),
      datetime: DateTime.fromMillisecondsSinceEpoch(map[kDatetime]),
    );
  }

  Map<String, dynamic> toMap() => {
        kDatetime: this.datetime.millisecondsSinceEpoch,
        kSorting: this.sorting?.string ?? null,
        kPrintType: this.printType?.string ?? null,
        kKeywords: this.keywords.reduce((a1, a2) => "$a1,$a2"),
      };
}

class DatabaseQueryResult {
  static const kTableName = "bookQueryResult";
  static const kTotalResult = "totalResult";

  static const kBookDetails = "bookDetails";
  static const kBookQuery = "bookQuery";

  static Map<String, dynamic> toMap(int totalResults, int details, int query) => {
        kTotalResult: totalResults,
        kBookDetails: details,
        kBookQuery: query,
      };
}

extension DatabaseBook on Book {
  static const kTableName = "book";
  static const kId = "bookID";
  static const kCoverPath = "coverPath";
  static const kDownloadPath = "downloadPath";
  static const kStatus = "status";
  static const kDetails = "book_details";
  static const kFavorite = "isFavorite";

  static Book fromMap(Map<String, dynamic> map) {
    return Book(
      id: map[kId],
      status: BookStatusString.parse(map[kStatus]),
      coverFilename: map[kCoverPath],
      downloadFilename: map[kDownloadPath],
      details: DatabaseBookDetails.fromMap(map),
      favorite: (map[kFavorite] as int) == 1,
    );
  }

  Map<String, dynamic> toMap({int detailId}) {
    Map<String, dynamic> map = {
      kCoverPath: this.coverFilename,
      kDownloadPath: this.downloadFilename,
      kStatus: this.status.string,
      kFavorite: this.favorite ? 1 : 0,
    };
    if (detailId != null) {
      map[kDetails] = detailId;
    }
    ;
    return map;
  }
}
