import 'package:flutter/foundation.dart' show required;

enum BookSorting {
  relevance,
  newest,
}

extension BookSortingString on BookSorting {
  String get string {
    switch (this) {
      case BookSorting.relevance:
        return "relevance";
      case BookSorting.newest:
        return "newest";
    }
    throw "Unknown value $this";
  }

  static BookSorting parse(String source) {
    switch(source.toUpperCase()) {
      case "RELEVANCE" : return BookSorting.relevance;
      case "NEWEST" : return BookSorting.newest;
    }
    throw "Unknown String representation $source";
  }
}

enum BookSearchField {
  inAuthor,
  inTitle,
  inPublisher,
}

extension BookSearchFieldString on BookSearchField {
  String get string {
    switch (this) {
      case BookSearchField.inAuthor:
        return "inauthor";
      case BookSearchField.inTitle:
        return "intitle";
      case BookSearchField.inPublisher:
        return "inpublisher";
    }
    throw "Unknown value $this";
  }
}

enum PrintType {
  all,
  books,
  magazines,
}

extension PrintTypeString on PrintType {

  static PrintType parse(String source) {
    switch(source.toUpperCase()) {
      case "BOOK": return PrintType.books;
      case "MAGAZINE": return PrintType.magazines;
      default: return PrintType.all;
    }
  }

  String get string {
    switch (this) {
      case PrintType.all:
        return "all";
      case PrintType.books:
        return "books";
      case PrintType.magazines:
        return "magazines";
    }
    throw "Unknown value $this";
  }
}

class BookQuery {
  final List<String> keywords;
  final BookSorting sorting;
  final PrintType printType;
  final DateTime datetime;

  BookQuery({@required this.keywords, this.sorting, this.printType, this.datetime});
  
  @override
  String toString() {
    return "$BookQuery(keyWords: $keywords, sorting: $sorting, support:$printType)";
  }
}