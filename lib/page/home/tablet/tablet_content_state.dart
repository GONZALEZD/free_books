import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_books/common/app/app_navigator.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/domain/book.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/wrapped_book.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/page/search_mixins.dart';
import 'package:free_books/widget/book_detail_tile.dart';
import 'package:free_books/widget/book_tile.dart';
import 'package:free_books/widget/search_bar.dart';
import 'package:free_books/widget/tutorial_builder.dart';
import 'package:provider/provider.dart';

abstract class TabletContentState<T extends StatefulWidget> extends State<T>
    with SearchMixin<T> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(child: _buildBookList(context)),
        Flexible(child: _buildSearch(context)),
      ],
    );
  }

  Widget _buildBookList(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        final allBooks = Set.of(List<Book>()
              ..addAll(provider.read)
              ..addAll(provider.favorites)
              ..addAll(provider.downloaded)
              ..addAll(provider.downloading))
            .toList();
        if (allBooks.length == 0) {
          return SizedBox();
        }
        final firstBook = allBooks.removeAt(0);
        return Row(
          children: [
            _buildFirstBook(firstBook),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: allBooks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  return __buildBookTile(book: allBooks[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget __buildBookTile({Book book}) {
    final tile = BookTile(book: book);
    Function action;
    if (book is ReadingBook && (book.downloadFilename?.isNotEmpty ?? false)) {
      action = () => readBook(book: book);
    }
    else {
      print("Unreadable book: $book");
    }
    return (action != null) ? GestureDetector(onTap: action, child: tile) : tile;
  }

  void readBook({ReadingBook book}) {
    Navigator.of(context).pushNamed(AppNavigator.reader, arguments: book);
  }

  Widget _buildFirstBook(Book book) {
    Widget tile = BookTile(book: book);
    tile = Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(aspectRatio: 0.75, child: tile),
    );
    if(book.status == BookDownloadStatus.finished && book is ReadingBook) {
      return Tutorial.create(
        key: Tutorial.readBook,
        context: context,
        target: GestureDetector(
          onTap: () => this.readBook(book: book),
          child: tile,
        ),
      );
    }
    return tile;
  }

  Widget _buildSearch(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          submit: this.startSearch,
        ),
        Expanded(
          child: Consumer<BookProvider>(
            builder: (context, provider, child) {
              final searchResult = provider.searchResult;
              final isSearching = provider.isSearching;
              final isFullLoad = provider.searchResult.isFullyLoaded;
              return ListView.builder(
                controller: this.scrollController,
                padding: EdgeInsets.only(bottom: 16.0),
                scrollDirection: Axis.horizontal,
                itemExtent: 240.0,
                itemCount: searchResult.length + (isSearching || isFullLoad ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == searchResult.length) {
                    return isSearching ? __buildSearchItem(context) : __buildNoMoreResult(context);
                  }
                  return __buildSearchResultItem(searchResult[index], isFirst:index==0);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget __buildSearchItem(context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
          Text(
            I18n.of(context).value("search.loading"),
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget __buildNoMoreResult(context) {
    return Center(
      child: Text(
        I18n.of(context).value("search.no_more_result"),
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget __buildSearchResultItem(BookDetails item, {bool isFirst}) {
    final tile = BookDetailsTile(book: item, onStartDownload: () => this.startDownload(book: item));;
    if(isFirst) {
      return Tutorial.create(
        key: Tutorial.bookDetails,
        context: context,
        target: tile,
      );
    }
    return tile;
  }
}
