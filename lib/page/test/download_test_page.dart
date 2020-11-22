import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:free_books/common/domain/book_details.dart';
import 'package:free_books/common/service/book/google_books_api.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:epub_view/epub_view.dart';


class DownloadTestPage extends StatefulWidget {
  @override
  _DownloadTestPageState createState() => _DownloadTestPageState();
}

enum _DownloadStatus {
  notStarted,
  downloading,
  complete,
  canceled,
}

class _DownloadTestPageState extends State<DownloadTestPage> {
  GoogleBooksApi booksApi;
  _DownloadStatus status;
  EpubController _epubReaderController;

  @override
  void initState() {
    super.initState();
    this.status = _DownloadStatus.notStarted;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    booksApi = GoogleBooksApi();
  }

  void startDownLoad() async {
    setState(() {
      this.status = _DownloadStatus.downloading;
    });
    var data = await this.booksApi.download(
            book: BookDetails(
          downloadLink:
              "http://books.google.fr/books/download/Les_Fleurs_Du_Mal.epub?id=w5ZcAAAAMAAJ&hl=&output=epub&source=gbs_api",
        ),
    captchaHandler: this.displayIntermediateDownloadPage);
    if(data != null) {
      _epubReaderController = EpubController(data: Future.value(data));
      setState(() {
        this.status = _DownloadStatus.complete;
      });
    }
    else {
      setState(() {
        this.status = _DownloadStatus.canceled;
      });
    }
  }

  Future<String> displayIntermediateDownloadPage(String pageToDisplay) async {
    var urlString = await showDialog(
        context: this.context,
        child: Dialog(
          insetPadding: EdgeInsets.all(8),
          child: WebView(
            initialUrl: pageToDisplay,
            javascriptMode: JavascriptMode.unrestricted,
            debuggingEnabled: true,
            navigationDelegate: (navigation) {
              print(navigation.url);
              if (navigation.url.contains("captcha=")){
                Navigator.pop(this.context, navigation.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        ));
    return urlString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Download test Page"),
        actions: [_buildDownloadButton()],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildDownloadButton() {
    return IconButton(
        icon: Icon(
          Icons.file_download,
          color: Colors.white,
        ),
        onPressed: this.startDownLoad);
  }

  Widget _buildBody() {
    switch (this.status) {
      case _DownloadStatus.notStarted:
        return Center(child: Text("Download not started"));
      case _DownloadStatus.complete:
        return EpubView(
          controller: _epubReaderController,
          onDocumentLoaded: (document) {
            print('isLoaded: $document');
          },
          dividerBuilder: (_) => Divider(),
        );
      case _DownloadStatus.downloading:
        return Center(child: Text("Downloading ... "));
      case _DownloadStatus.canceled:
        return Center(child: Text("Download canceled"));
    }
    return Container();
  }
}
