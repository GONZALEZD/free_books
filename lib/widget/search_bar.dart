import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/widget/tutorial_builder.dart';
import 'package:provider/provider.dart';

typedef StringCallback = void Function(String data);

class SearchBar extends StatefulWidget {
  final StringCallback submit;

  SearchBar({this.submit});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void startSearch() {
    // dismiss keyboard
    FocusScope.of(context).unfocus();
    if (_textEditingController.text.isNotEmpty) {
      this.widget.submit(_textEditingController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.white12;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tutorial.create(
            context: context,
            key: Tutorial.searchBar,
            target: TextField(
              controller: _textEditingController,
              onEditingComplete: this.startSearch,
              decoration: InputDecoration(
                fillColor: color,
                suffixIcon: _buildSearchButton(context),
              ),
            ),
          ),
          Consumer<BookProvider>(
            builder: (context, provider, child) => buildQueries(context, provider.queries),
          ),
        ],
      ),
    );
  }

  Widget buildQueries(BuildContext context, List<BookQuery> queries) {
    if(queries.isEmpty) {
      return SizedBox();
    }
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        separatorBuilder: (_, __) => SizedBox(
          width: 8.0,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: queries.length,
        itemBuilder: (context, index) => __buildQueryChip(context, queries[index], index==0),
      ),
    );
  }

  Widget __buildQueryChip(BuildContext context, BookQuery query, bool isFirst) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final chip = GestureDetector(
      onTap: () => selectQuery(query),
      child: Chip(
        label: Text(query.keywords.join(" ")),
        deleteIcon: Icon(
          isIOS ? CupertinoIcons.delete : Icons.delete,
          size: 18,
        ),
        onDeleted: () => deleteQuery(query),
      ),
    );
    if(isFirst) {
      return Tutorial.create(
        context: context,
        key: Tutorial.bookQuery,
        target: chip,
      );
    }
    return chip;
  }

  void deleteQuery(BookQuery query) {
    BookProvider.of(context).deleteQuery(query);
  }

  void selectQuery(BookQuery query) {
    this._textEditingController.text = query.keywords.join(" ");
    setState(() {});
  }

  Widget _buildSearchButton(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    var isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return GestureDetector(
      onTap: this.startSearch,
      child: Container(
        margin: EdgeInsets.all(2.0),
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
          color: primary,
        ),
        child: Icon(isIOS ? CupertinoIcons.search : Icons.search, color: Colors.white),
      ),
    );
  }
}
