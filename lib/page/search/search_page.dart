import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/page/search_mixins.dart';
import 'package:free_books/widget/book_detail_tile.dart';
import 'package:free_books/widget/search_bar.dart';
import 'package:free_books/widget/tutorial_builder.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return isIos ? _buildIOSLayout(context) : _buildAndroidLayout(context);
  }

  Widget _buildIOSLayout(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: true,
          middle: Text(I18n.of(context).value("search.title")),
        ),
        child: _SearchBody(),
      ),
    );
  }

  Widget _buildAndroidLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).value("search.title")),
        leading: BackButton(),
      ),
      body: _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> with SearchMixin<_SearchBody> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        final searchResult = provider.searchResult;
        final isSearching = provider.isSearching;
        final isFullLoad = provider.searchResult.isFullyLoaded;
        return Column(
          children: [
            SearchBar(submit: this.startSearch),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: searchResult.length + (isSearching || isFullLoad ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == searchResult.length) {
                    return isSearching ? __buildQueryLoading(context) : __buildNoMoreResult(context);
                  }
                  return _buildBookDetails(context, book: searchResult[index], isFirst: index == 0);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget __buildQueryLoading(context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return ListTile(
      leading: isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
      title: Text(
        I18n.of(context).value("search.loading"),
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget __buildNoMoreResult(context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      alignment: Alignment.center,
      child: Text(
        I18n.of(context).value("search.no_more_result"),
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, {BookDetails book, bool isFirst}) {
    final tile = BookDetailsTile(
      book: book,
      onStartDownload: () => startDownload(book: book),
    );
    if (isFirst) {
      return Tutorial.create(
        context: context,
        key: Tutorial.bookDetails,
        target: tile,
      );
    }
    return tile;
  }
}
