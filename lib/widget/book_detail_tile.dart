import 'package:flutter/material.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/widget/tutorial_builder.dart';

class BookDetailsTile extends StatelessWidget {
  final BookDetails book;
  final VoidCallback onStartDownload;

  BookDetailsTile({this.book, this.onStartDownload});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      margin: EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: this.onStartDownload,
        child: Row(
          children: [
            buildCover(),
            Expanded(child: buildDetails(context)),
          ],
        ),
      ),
    );
  }

  Widget buildCover() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image.network(
          book.thumbnailLink,
          alignment: Alignment.center,
          height: 120.0,
        ),
      ),
    );
  }

  Widget buildDetails(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(book.title ?? I18n.of(context).value("search.book.title.unavailable"),
                  style: styles.headline6, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (book.authors.isNotEmpty)
                Text(
                  book.authors.reduce((a1, a2) => "$a1, $a2"),
                  style: styles.bodyText1.copyWith(fontStyle: FontStyle.italic),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              if (book.description != null)
                Text(
                  book.description,
                  style: styles.bodyText2,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        _buildDownloadButton(context),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      height: 20.0,
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(right: 8.0),
      child: Text(
        I18n.of(context).value("search.download"),
        style: Theme.of(context).textTheme.button.copyWith(color: color),
      ),
    );
  }
}
