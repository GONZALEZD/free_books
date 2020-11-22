import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:flutter_tools/widget/tutorial/tutorial_manager.dart';
import 'package:flutter_tools/widget/tutorial/tutorial_widget.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/widget/bookmark.dart';

class Tutorial {
  Tutorial._();

  static TutorialKey homeSearch = TutorialKey(name: "search", priority: 1);
  static TutorialKey homeSettings = TutorialKey(name: "settings", priority: 2);
  static TutorialKey homeDrawerMenu = TutorialKey(name: "drawer", priority: 3);
  static TutorialKey homeDrawerDownloadedBook = TutorialKey(name: "downloaded_book", priority: 9);
  static TutorialKey searchBar = TutorialKey(name: "search_bar", priority: 20);
  static TutorialKey bookDetails = TutorialKey(name: "book_details", priority: 30);
  static TutorialKey bookQuery = TutorialKey(name: "book_query", priority: 35);
  static TutorialKey readBook = TutorialKey(name: "read_book", priority: 40);
  static TutorialKey bookChapters = TutorialKey(name: "book_chapter", priority: 50);

  static List<TutorialKey> get all => [
        homeSearch,
        homeSettings,
        homeDrawerMenu,
        homeDrawerDownloadedBook,
        searchBar,
        bookDetails,
        bookQuery,
        readBook,
        bookChapters,
      ];

  static TutorialWidget create({TutorialKey key, BuildContext context, Widget target}) {
    return TutorialWidget(
      tutorialID: key,
      explanation: key == Tutorial.readBook
          ? _buildReadBookExplanation(context, key)
          : _buildExplanationForKey(context, key),
      child: target,
    );
  }

  static Widget _buildExplanationForKey(BuildContext context, TutorialKey key,
      {List<Widget> subContent}) {
    final i18n = I18n.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Text(
            __getTitle(i18n, key),
            style: Theme.of(context).textTheme.headline6,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(__getDescription(i18n, key), maxLines: 10),
          ),
          if (subContent != null) ...subContent,
        ],
      ),
    );
  }

  static Widget _buildReadBookExplanation(BuildContext context, TutorialKey key) {
    return _buildExplanationForKey(
      context,
      key,
      subContent: [
        __buildBookmarkExplanation(
            context, Colors.greenAccent, "tutorial.${key.name}.bookmark.read"),
        __buildBookmarkExplanation(context, Colors.pink, "tutorial.${key.name}.bookmark.favorite",
            icon: Icon(
              Icons.favorite,
              size: 8,
              color: Colors.white,
            )),
      ],
    );
  }

  static Widget __buildBookmarkExplanation(BuildContext context, Color color, String key,
      {Icon icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 6.0, right: 16.0, left: 8.0),
            child: SizedBox.fromSize(
              size: Size(10, 30),
              child: BookmarkWidget(color: color, icon: icon),
            ),
          ),
          Expanded(
              child: Text(
            I18n.of(context).value(key),
            maxLines: 3,
          )),
        ],
      ),
    );
  }

  static String __getTitle(I18n i18n, TutorialKey key) {
    return i18n.value("tutorial.${key.name}.title");
  }

  static String __getDescription(I18n i18n, TutorialKey key) {
    return i18n.value("tutorial.${key.name}.description");
  }
}
