import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/book/books_api.dart';
import 'package:http/http.dart';


class GoogleBooksApi implements HttpBooksApi {
  static const String _apiKey = "AIzaSyAAPEne4gLNaaw6oisjrM_7UNw6HmoGupc";

  static const String _root = "https://www.googleapis.com/books/v1/volumes/";

  final GoogleBooksQueryBuilder _queryBuilder;


  GoogleBooksApi()
      : _queryBuilder = GoogleBooksQueryBuilder(root: _root, apiKey: _apiKey);

  @override
  Future<Uint8List> download({BookDetails book, DownloadCaptchaHandler captchaHandler}) async {
    final query = _queryBuilder.download(book: book);
    Response res = await get(query);
    if (res.statusCode == 200) {
      if (res.headers["content-type"].contains("html")) {
        assert(captchaHandler != null);
        String realQuery;
        Response res2;
        do{
          realQuery = await captchaHandler(query);
          res2 = null;
          if(realQuery != null && realQuery.isNotEmpty) {
            res2 = await get(realQuery);
          }
        }while(res2 != null && res2.statusCode == 200 && res2.headers["content-type"].contains("html"));
        if(res2 != null && res2.statusCode == 200) {
          return res2.bodyBytes;
        }
        // user canceled
        return null;
      }
      return res.bodyBytes;
    }
    throw "Unable to download book id ${book.id}";
  }

  @override
  Future<BookList> search({BookQuery query, int index = 0}) async {
    final httpRequest = _queryBuilder.search(query: query, startIndex: index);
    Response res = await get(httpRequest);
    if (res.statusCode == 200) {
      final mapData = jsonDecode(res.body);
      return JsonBookList.fromJson(mapData);
    } else {
      throw "Can't get posts.";
    }
  }

  @override
  Future<Uint8List> getCover({BookDetails book, CoverType type}) async {
    switch (type) {
      case CoverType.thumbnail:
        Response res = await get(book.thumbnailLink);
        if (res.statusCode == 200) {
          return res.bodyBytes;
        }
        throw "An error occurs";
      case CoverType.small:
      case CoverType.medium:
      case CoverType.large:
      case CoverType.extraLarge:
        Response res1 = await get(_queryBuilder.details(book: book));
        if (res1.statusCode == 200) {
          final dataMap = jsonDecode(res1.body);
          Response res2 = await get(dataMap["volumeInfo"]["imageLinks"][type.string]);
          if (res2.statusCode == 200) {
            return res2.bodyBytes;
          }
          throw "Unable to get image '${type.string}' for book id '${book.id}'";
        }
        throw "Unable to query book details for id '${book.id}'";
    }
    throw "Unknown cover type: $type";
  }
}

class GoogleBooksQueryBuilder {
  final String apiKey;
  final String root;

  GoogleBooksQueryBuilder({this.apiKey, this.root})
      : assert(apiKey != null && apiKey.isNotEmpty),
        assert(root != null && root.isNotEmpty);

  String search({BookQuery query, int startIndex = 0}) {
    assert(query != null);
    assert(query.keywords != null);
    assert(startIndex != null && startIndex >= 0);
    final List<String> parameters = [
      "q=${query.keywords.reduce((s1, s2) => "$s1+$s2")}",
      "filter=free-ebooks",
      "download=epub",
      "startIndex=${startIndex ?? 0}",
      if (query.printType != null) "printType=${query.printType.string}",
      if (query.sorting != null) "orderBy=${query.sorting.string}",
      "key=$apiKey",
    ];
    return "$root?${parameters.reduce((p1, p2) => "$p1&$p2")}";
  }

  String details({BookDetails book}) {
    assert(book != null);
    assert(book.id != null && book.id.isNotEmpty);
    return "$root${book.id}?key=$apiKey";
  }

  String download({BookDetails book}) {
    assert(book != null);
    assert(book.downloadLink != null && book.downloadLink.isNotEmpty);
    var root = book.downloadLink.replaceFirst("http://", "https://");
    return "$root&output=epub&key=$apiKey";
  }
}

extension JsonBookList on BookList {
  static BookList fromJson(Map<String, dynamic> map) {
    return BookList(
      totalLength: map["totalItems"],
      books: (map["items"] as List).map((mapBook) => JsonBook.fromJson(mapBook)).toList(),
    );
  }
}

extension JsonBook on BookDetails {
  static BookDetails fromJson(Map<String, dynamic> map) {
    return BookDetails(
      id: map["id"],
      title: map["volumeInfo"]["title"],
      subTitle: map["volumeInfo"]["subtitle"],
      authors: map["volumeInfo"]["authors"]?.cast<String>()?.toList() ?? [],
      description: map["volumeInfo"]["description"],
      edition: BookEdition(
        publisher: map["volumeInfo"]["publisher"],
        publishedDate: map["volumeInfo"]["publishedDate"],
      ),
      pageCount: map["volumeInfo"]["pageCount"],
      rating: BookRating(
        ratingCount: map["volumeInfo"]["ratingsCount"],
        averageRating: (map["volumeInfo"]["averageRating"] as num)?.toInt() ?? 0,
        maturityRating: RatingMaturityString.parse(map["volumeInfo"]["maturityRating"]),
      ),
      downloadLink: map["accessInfo"]["epub"]["downloadLink"],
      category: BookCategory(
        type: PrintTypeString.parse(map["volumeInfo"]["printType"]),
        categories: map["volumeInfo"]["categories"]?.cast<String>()?.toList() ?? [],
      ),
      thumbnailLink: map["volumeInfo"]["imageLinks"]["thumbnail"],
    );
  }
}
