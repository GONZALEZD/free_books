import 'package:flutter/material.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/domain/book_query.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  ScrollController scrollController;
  WebViewController webController;

  @override
  void initState() {
    super.initState();
    this.scrollController = ScrollController(keepScrollOffset: true);
    this.scrollController.addListener(this.loadMoreResults);
  }

  @override
  void dispose() {
    this.scrollController.removeListener(this.loadMoreResults);
    this.scrollController.dispose();
    super.dispose();
  }

  void loadMoreResults() {
    if (this.scrollController.position.atEdge && this.scrollController.position.pixels > 0.0) {
      BookProvider.of(context).loadMoreResults();
    }
  }

  void startDownload({BookDetails book}) {
    BookProvider.of(context).startDownload(
      bookDetails: book,
      captchaHandler: this.displayIntermediateDownloadPage,
      onComplete: (status) => print("Download $status"),
    );
  }

  void startSearch(String words,
      {PrintType type = PrintType.all, BookSorting sorting = BookSorting.relevance}) {
    final searchProvider = BookProvider.of(context);
    final query = BookQuery(
      keywords: words.split(" "),
      datetime: DateTime.now(),
      printType: type,
      sorting: sorting,
    );
    print("Start query: $query");
    searchProvider.search(query: query);
  }

  void _changeInputType() {
    this.webController.evaluateJavascript('''
    document.getElementById("captcha").autocomplete = 'off';
    document.getElementById("captcha").autocorrect = 'off';
    document.getElementById("captcha").autocapitalize = 'off';
    ''');
  }

  Future<String> displayIntermediateDownloadPage(String pageToDisplay) async {
    var urlString = await showDialog(
        context: this.context,
        child: Dialog(
          insetPadding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: WebView(
              initialUrl: pageToDisplay,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                this.webController = controller;
              },
              onPageFinished: (_) {
                _changeInputType();
              },
              debuggingEnabled: true,
              navigationDelegate: (navigation) {
                if (navigation.url.contains("captcha=")) {
                  Navigator.pop(this.context, navigation.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          ),
        ));
    return urlString;
  }
}
