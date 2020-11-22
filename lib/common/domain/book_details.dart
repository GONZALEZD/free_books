import 'package:free_books/common/domain/book_query.dart' show PrintType, PrintTypeString;
import 'dart:math' as math;

class BookList {
  final int totalLength;
  final List<BookDetails> books;

  const BookList({this.totalLength, this.books});

  BookList merge({BookList other}) {
    return BookList(
      totalLength: math.max(this.totalLength, other.totalLength),
      books: this.books + other.books
    );
  }

  static const empty = BookList(totalLength: 0, books: []);

  operator [](int index) => this.books[index];

  int get length => this.books?.length ?? 0;

  bool get isFullyLoaded => this.totalLength != 0 && this.length == this.totalLength;
}

class BookCategory {
  final PrintType type;
  final List<String> categories;

  BookCategory({this.type, this.categories});
}

class BookEdition {
  final String publishedDate;
  final String publisher;

  BookEdition({this.publishedDate, this.publisher});
}

enum RatingMaturity {
  notMature,
}

extension RatingMaturityString on RatingMaturity {

  String get string {
    switch(this) {
      case RatingMaturity.notMature: return "NOT_MATURE";
    }
    throw "Unknown String representation of value $this";
  }

  static RatingMaturity parse(String source) {
    switch(source.toUpperCase()) {
      case "NOT_MATURE": return RatingMaturity.notMature;
    }
    return null;
  }
}

class BookRating {
  final int ratingCount;
  final int averageRating;
  final RatingMaturity maturityRating;

  BookRating({this.ratingCount, this.averageRating, this.maturityRating});
}

class BookDetails {
  final String id;
  final String title;
  final String subTitle;
  final List<String> authors;
  final BookEdition edition;
  final int pageCount;
  final BookCategory category;
  final BookRating rating;

  final String description;
  final String thumbnailLink;
  final String downloadLink;

  BookDetails({
    this.id,
    this.title,
    this.subTitle,
    this.authors,
    this.edition,
    this.pageCount,
    this.category,
    this.rating,
    this.description,
    this.thumbnailLink,
    this.downloadLink,
  });

  BookDetails copyWith({
    String key,
    String title,
    String subTitle,
    List<String> authors,
    BookEdition edition,
    int pageCount,
    BookCategory category,
    BookRating rating,
    String description,
    String coverLink,
    String downloadLink,
}) {
    return BookDetails(
      id: key ?? this.id,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      authors: authors ?? this.authors,
      edition: edition ?? this.edition,
      pageCount:  pageCount ?? this.pageCount,
      category: category ?? this.category,
      rating:  rating ?? this.rating,
      thumbnailLink:  coverLink ?? this.thumbnailLink,
      downloadLink:  downloadLink ?? this.downloadLink,
    );
  }

  @override
  String toString() {
    var parameters = {
      "id": id,
      "title": title,
      "subtitle": subTitle,
      "authors": authors,
      "edition": edition,
      "pageCount": pageCount,
      "category" : category,
      "rating" : rating,
      "thumbnailLink" : thumbnailLink,
      "downloadLink" : downloadLink,
    };
    return "$BookDetails($parameters)";
  }
}