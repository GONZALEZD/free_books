import 'package:epub_view/epub_view.dart' as epub;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_books/common/domain/bookmark.dart';
import 'package:free_books/common/domain/wrapped_book.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/page/reader/epub_builder_mixin.dart';
import 'package:free_books/widget/tutorial_builder.dart';

class ReaderPage extends StatefulWidget {
  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> with EputBuilderMixin<ReaderPage> {
  BookProvider _bookProvider;

  ReadingBook book;

  String get bookTitle => this.book.details.title;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildCupertinoLayout(context) : _buildAndroidLayout(context);
  }


  @override
  void deactivate() {
    // do no save user progression in dispose method
    // (epub controller half deallocated, cfi won't work).
    this.addAutomaticBookmark();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookProvider = BookProvider.of(context);
    book = ModalRoute.of(context).settings.arguments as ReadingBook;
  }

  Widget _buildCupertinoLayout(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // leading: CupertinoNavigationBarBackButton(onPressed: this.addAutomaticBookmark),
          middle: Text(this.bookTitle),
          trailing: _buildMenu(context),
        ),
        child: buildEpubContent(
          context,
          indicator: CupertinoActivityIndicator(
            radius: 20.0,
            animating: true,
          ),
          book: this.book,
        ),
      ),
    );
  }

  Widget _buildAndroidLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.bookTitle),
        actions: [_buildMenu(context)],
      ),
      body: buildEpubContent(
        context,
        indicator: CircularProgressIndicator(
          strokeWidth: 8.0,
        ),
        book: this.book,
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final iconData = isIOS ? CupertinoIcons.list_bullet : Icons.more_vert;
    final button = Material(
      type: MaterialType.transparency,
      child: IconButton(
        icon: Icon(iconData),
        onPressed:  showTableOfContent,
      ),
    );
    if (this.epubReaderController?.isBookLoaded ?? false) {
      return Tutorial.create(
        key: Tutorial.bookChapters,
        context: context,
        target: button,
      );
    }
    return button;
  }

  void showTableOfContent() {
    showDialog(
      context: context,
      builder: (context) {
        final selectedChapter = this.epubReaderController?.currentValue?.chapterNumber ?? -1;
        return Dialog(
          child: epub.EpubReaderTableOfContents(
            controller: this.epubReaderController,
            itemBuilder: (context, index, chapter, total) {
              return ListTile(
                selected: selectedChapter == index + 1,
                leading: Text("${index + 1}"),
                title: Text(chapter.title),
                onTap: () {
                  this.epubReaderController.scrollTo(index: chapter.startIndex);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> addAutomaticBookmark() async {
    final auto = Bookmark.automatic(cfi: this.epubReaderController.generateEpubCfi());
    await _bookProvider.addBookmark(bookmark: auto, to: this.book);
  }
}
