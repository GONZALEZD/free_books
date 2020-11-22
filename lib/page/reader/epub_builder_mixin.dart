import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/epub_view.dart' as epub;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:free_books/common/app/setting_keys.dart';
import 'package:free_books/common/domain/bookmark.dart';
import 'package:free_books/common/domain/wrapped_book.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/widget/bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin EputBuilderMixin<T extends StatefulWidget> on State<T> {
  SharedPreferences _preferences;

  epub.EpubController epubReaderController;

  epub.EpubBook _epubBook;

  Map<Bookmark, int> _bookmarksLocation;
  Map<int, int> _chapterIndexes;

  TextStyle getBookTextStyle(BuildContext context, Color background) {
    Color textColor =
        background.computeLuminance() > 0.5 ? Colors.grey.shade800 : Colors.grey.shade100;

    return TextStyle(fontSize: 16, color: textColor);
  }

  Color _getBackgroundColor(BuildContext context) {
    int value = _preferences?.getInt(kReaderBackgroundColor) ?? -1;
    if(value == -1) {
      return Theme.of(context).colorScheme.background;
    }
    return Color(value);
  }

  Future<bool> loadBook({ReadingBook book}) async {
    File file = await BookProvider.of(context).getDownload(book: book);

    String cfi;
    if (book.hasBookmark) {
      cfi = book.bookmarks.first.cfi;
    }
    _epubBook = await epub.EpubReader.readBook(await file.readAsBytes());
    epubReaderController = epub.EpubController(data: file.readAsBytes(), epubCfi: cfi);
    return true;
  }

  void locateBookmarks(
      List<epub.EpubChapter> chapters, List<epub.Paragraph> paragraphs, ReadingBook book) {
    final reader = epub.EpubCfiReader.parser(
      cfiInput: "",
      chapters: chapters,
      paragraphs: paragraphs,
    );
    _bookmarksLocation = book.bookmarks.asMap().map((_, bookmark) {
      reader.cfiInput = bookmark.cfi;
      return MapEntry(bookmark, reader.paragraphIndexByCfiFragment);
    }).cast();
  }

  void locateChapterBeginning(List<epub.Paragraph> paragraphs) {
    final chapterIndexes = paragraphs.map((p) => p.chapterIndex).toSet();
    _chapterIndexes = chapterIndexes.toList().asMap().map((_, chapterIndex) {
      return MapEntry(chapterIndex, paragraphs.indexWhere((p) => p.chapterIndex == chapterIndex));
    });
  }

  Future<bool> _buildFuture(ReadingBook book) {
    Future prefsFuture;
    Future<bool> loadBookFuture;
    if (_preferences == null) {
      prefsFuture = SharedPreferences.getInstance().then((prefs) => _preferences = prefs);
    }
    if (epubReaderController == null) {
      loadBookFuture = Future.delayed(Duration(milliseconds: 300), () => this.loadBook(book: book));
    }
    else {
      loadBookFuture = Future.value(true);
    }

    return prefsFuture == null ? loadBookFuture : prefsFuture.then((_) => loadBookFuture);
  }

  Widget buildEpubContent(BuildContext context, {Widget indicator, ReadingBook book}) {
    return FutureBuilder(
      future: _buildFuture(book),
      initialData: this.epubReaderController,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data && this.epubReaderController != null) {
          return epub.EpubView(
            controller: this.epubReaderController,
            itemBuilder: (context, chapters, paragraphs, index) {
              if (_bookmarksLocation == null) {
                locateBookmarks(chapters, paragraphs, book);
              }
              if (_chapterIndexes == null) {
                locateChapterBeginning(paragraphs);
              }
              return _bookItemBuilder(context, chapters, paragraphs, index);
            },
            loader: indicator,
            dividerBuilder: (_) => Divider(color: Theme.of(context).disabledColor, thickness: 2.0),
          );
        } else {
          return Center(child: indicator);
        }
      },
    );
  }

  Widget buildChapterDivider() {
    return Divider(color: Theme.of(context).disabledColor, thickness: 2.0);
  }

  Widget buildBookmark(Bookmark bookmark) {
    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Colors.greenAccent.withOpacity(0.25),
                  width: 2.0,
                  style: BorderStyle.solid))),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: EdgeInsets.only(right: 20.0),
          width: 30,
          height: 80,
          child:
              BookmarkWidget(color: Colors.greenAccent, colorDarker: Colors.greenAccent.shade700),
        ),
      ),
    );
  }

  Widget _bookItemBuilder(BuildContext context, List<epub.EpubChapter> chapters,
      List<epub.Paragraph> paragraphs, int index) {
    if (paragraphs.isEmpty) {
      return Container();
    }

    final paragraph = paragraphs[index];

    final isFirstParagraph = _chapterIndexes[paragraph.chapterIndex] == index;
    final isFirstChapter = paragraph.chapterIndex == 1;

    final bookmark = _bookmarksLocation.entries
        .firstWhere((entry) => entry.value == index, orElse: () => null)
        ?.key;

    final hasBookmark = bookmark != null;

    if ((paragraph?.element?.text?.isEmpty ?? true) && !isFirstParagraph && !hasBookmark) {
      return Container();
    }
    final backgroundColor = _getBackgroundColor(context);
    return ColoredBox(
      color: backgroundColor,
      child: Column(
        children: <Widget>[
          if (!isFirstChapter && isFirstParagraph) buildChapterDivider(),
          if (hasBookmark) buildBookmark(bookmark),
          Html(
            data: paragraph.element.outerHtml,
            onLinkTap: (href) => print("Tapped on link: $href"),
            style: {
              'html': Style(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
              ).merge(Style.fromTextStyle(this.getBookTextStyle(context, backgroundColor))),
            },
            customRender: {
              'img': (context, child, attributes, node) {
                final url = attributes['src'].replaceAll('../', '');
                return Image(
                  image: MemoryImage(
                    Uint8List.fromList(_epubBook.Content.Images[url].Content),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
