import 'package:flutter/material.dart';
import 'package:free_books/common/app/app_navigator.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/page/home/phone/content_definition.dart';
import 'package:free_books/widget/book_tile.dart';
import 'package:free_books/widget/tutorial_builder.dart';
import 'package:provider/provider.dart';

abstract class PhoneHomeContentState<T extends StatefulWidget> extends State<T> {

  String getTitle() {
    final i18n = I18n.of(context);
    final canvas = i18n.value("home.composed.title");
    final category = i18n.value(this.selection.i18nKey).toLowerCase();
    return canvas.replaceFirst("####", category);
  }

  HomeContent _selected;

  set selection(HomeContent content) {
    setState(() {
      _selected = content;
    });
  }
  HomeContent get selection => _selected;

  @override
  void initState() {
    super.initState();
    _selected = HomeContent.read;
  }

  Widget buildContent({double verticalMargin}) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        var selectData = () {
          switch (_selected) {
            case HomeContent.favorites:
              return provider.favorites;
            case HomeContent.export:
              return provider.downloaded;
            case HomeContent.downloaded:
              return provider.all;
            case HomeContent.read:
              return provider.read;
            default: return List<Book>();
          }
        };
        List<Book> data = selectData();
        final spacing = 16.0;
        return GridView.builder(
            itemCount: data.length,
            padding: EdgeInsets.symmetric(horizontal: spacing, vertical: verticalMargin),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.75,
              crossAxisCount: 2,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemBuilder: (context, index) => __buildBookTile(book: data[index]));
      },
    );
  }

  Widget __buildBookTile({Book book}) {
    final tile = BookTile(book: book);
    if (book.downloadFilename != null && book.downloadFilename.isNotEmpty) {
      return Tutorial.create(
        key: Tutorial.readBook,
        context: context,
        target: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppNavigator.reader, arguments: book),
          child: tile,
        ),
      );
    }
    return tile;
  }
}