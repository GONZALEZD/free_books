import 'dart:io';
import 'dart:typed_data';

import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';

enum CoverType {
  thumbnail,
  small,
  medium,
  large,
  extraLarge,
}

extension CoverTypeString on CoverType {
  String get string {
    switch(this) {
      case CoverType.thumbnail: return "thumbnail";
      case CoverType.small: return "small";
      case CoverType.medium: return "medium";
      case CoverType.large: return "large";
      case CoverType.extraLarge: return "extraLarge";
    }
    throw "Unknown value $this";
  }
}

typedef DownloadCaptchaHandler = Future<String> Function(String pageToDisplay);

abstract class HttpBooksApi {

  // Execute query + for each book, execute book detail query
  Future<BookList> search({BookQuery query, int index=0});

  Future<Uint8List> download({BookDetails book, DownloadCaptchaHandler captchaHandler});

  Future<Uint8List> getCover({BookDetails book, CoverType type});
}