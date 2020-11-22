import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/book/books_api.dart';

enum HttpApiEvent {
  downloadEpub,
  downloadCover,
  search,
}


class HttpBookApiStub implements HttpBooksApi {
  final  List<BookDetails> queryResults;
  final int paginationLength;
  final Function(HttpApiEvent event) listener;

  HttpBookApiStub({@required this.listener, this.queryResults, this.paginationLength});
  
  @override
  Future<Uint8List> download({BookDetails book, captchaHandler}) {
    this.listener(HttpApiEvent.downloadEpub);
    return Future.value(Uint8List.fromList(List<int>.generate(100, (index) => index)));
  }

  @override
  Future<Uint8List> getCover({BookDetails book, CoverType type}) {
    this.listener(HttpApiEvent.downloadCover);
    return Future.value(Uint8List.fromList(List<int>.generate(100, (index) => index)));
  }

  @override
  Future<BookList> search({BookQuery query, int index = 0}) {
    this.listener(HttpApiEvent.search);
    final endIndex = min(index + this.paginationLength, this.queryResults.length);
    final bookList = BookList(
      totalLength: this.queryResults.length,
      books: this.queryResults.getRange(index, endIndex).toList(),
    );
    return Future.value(bookList);
  }
  
}