import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/wrapped_book.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/widget/bookmark.dart';
import 'package:provider/provider.dart';

class BookTile extends StatelessWidget {
  final Book _book;

  BookTile({Book book}) : _book = book;

  @override
  Widget build(BuildContext context) {
    if (_book is ReadingBook) {
      return _buildReadingBook(context, _book);
    } else if (_book is BookDownload) {
      return _buildBookDownload(context, _book);
    }
    return _buildBook(context, _book);
  }

  List<BookmarkWidget> __buildBookmarks(ReadingBook book) {
    return [
      if (book.hasBookmark)
        BookmarkWidget(
          color: Colors.greenAccent,
          colorDarker: Colors.greenAccent.shade700,
        ),
      if (book.favorite)
        BookmarkWidget(
          color: Colors.pinkAccent.shade100,
          colorDarker: Colors.pink.shade600,
          icon: Icon(
            Icons.favorite,
            color: Colors.white,
            size: 14,
          ),
        ),
    ];
  }

  Widget _buildReadingBook(BuildContext context, ReadingBook book) {
    final bookmarks = __buildBookmarks(book);
    var child;
    if (bookmarks.isNotEmpty) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bookmarks.map((bookmark) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            width: 14,
            height: 40,
            child: bookmark,
          );
        }).toList(),
      );
    }

    return _layoutImage(context: context, book: book, child: child);
  }

  Widget _buildBookDownload(BuildContext context, BookDownload book) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final icon = isIOS ? CupertinoIcons.square_arrow_down_fill : Icons.download_sharp;

    final textKey = book.status == BookDownloadStatus.downloading
        ? "home.book.downloading"
        : "home.book.retry_download";
    final text = I18n.of(context).value(textKey);
    return __buildBookIcon(context, book, text, icon);
  }

  Widget _buildBook(BuildContext context, Book book) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final icon = isIOS ? CupertinoIcons.refresh_thick : Icons.refresh;
    final text = I18n.of(context).value("home.book.retry_download");
    return __buildBookIcon(context, book, text, icon);
  }

  Widget __buildBookIcon(BuildContext context, BookDownload book, String text, IconData icon) {
    return _layoutImage(
      context: context,
      book: book,
      filter: ColorFilter.mode(Colors.grey.withOpacity(0.5), BlendMode.srcOver),
      child: Column(
        children: [
          Expanded(child: Center(child: LayoutBuilder(
            builder: (context, constraints) {
              return Icon(
                icon,
                size: constraints.biggest.shortestSide / 2,
                color: Colors.white,
              );
            },
          ))),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.0)),
            ),
            padding: EdgeInsets.symmetric(vertical: 8.0),
            alignment: Alignment.center,
            child: Text(text, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _layoutImage({BuildContext context, Book book, ColorFilter filter, Widget child}) {
    return FutureBuilder(
      future: context.select<BookProvider, Future<File>>((value) => value.getCover(book: book)),
      builder: (context, snapshot) {
        final img = snapshot.data != null
            ? DecorationImage(
                fit: BoxFit.fill,
                colorFilter: filter,
                image: FileImage(snapshot.data),
              )
            : null;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [BoxShadow(spreadRadius: 0.0, blurRadius: 4.0, color: Colors.black12)],
            color: Theme.of(context).dialogBackgroundColor,
            image: img,
          ),
          child: child,
        );
      },
    );
  }
}
