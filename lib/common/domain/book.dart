import 'package:flutter/cupertino.dart';
import 'package:free_books/common/domain/book_details.dart';

enum BookDownloadStatus {
  finished,
  downloading,
  cancelled,
}

extension BookStatusString on BookDownloadStatus {
  String get string {
    switch (this) {
      case BookDownloadStatus.cancelled:
        return "cancelled";
      case BookDownloadStatus.finished:
        return "downloaded";
      case BookDownloadStatus.downloading:
        return "downloading";
    }
    throw "Unknown value $this";
  }

  static BookDownloadStatus parse(String source) {
    switch (source) {
      case "cancelled":
        return BookDownloadStatus.cancelled;
      case "downloaded":
        return BookDownloadStatus.finished;
      case "downloading":
        return BookDownloadStatus.downloading;
    }
    throw "Unknown $BookDownloadStatus for string $source";
  }
}

class Book {
  final int id;
  final BookDetails details;
  final String coverFilename;
  final String downloadFilename;
  final BookDownloadStatus status;
  final bool favorite;

  Book(
      {this.id,
      this.details,
      this.coverFilename,
      this.downloadFilename,
      this.status,
      this.favorite = false});

  Book copyWith(
      {int id,
      BookDetails details,
      String coverPath,
      String downloadPath,
      BookDownloadStatus status,
      bool favorite}) {
    return Book(
      id: id ?? this.id,
      details: details ?? this.details,
      coverFilename: coverPath ?? this.coverFilename,
      downloadFilename: downloadPath ?? this.downloadFilename,
      status: status ?? this.status,
      favorite: favorite ?? this.favorite,
    );
  }

  @override
  String toString() {
    var parameters = {
      "id": id,
      "coverFilename": coverFilename,
      "downloadFilename": downloadFilename,
      "status": status,
      "favorite": favorite,
    };
    return "$Book($parameters)";
  }

  @override
  int get hashCode => hashValues(id, status, downloadFilename, coverFilename, details, favorite);

  @override
  bool operator ==(Object other) {
    if (other != null && other is Book) {
      return id == other.id &&
          coverFilename == other.coverFilename &&
          downloadFilename == other.downloadFilename &&
          favorite == other.favorite &&
          status == other.status;
    }
    return false;
  }
}
