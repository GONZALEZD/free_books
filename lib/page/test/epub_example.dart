import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:epub_view/epub_view.dart';

class EpubExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Epub demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    ),
    darkTheme: ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    ),
    home: MyHomePage(),
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  EpubController _epubReaderController;

  @override
  void initState() {
    final loadedBook =
    _loadFromAssets('assets/test.epub');
    _epubReaderController = EpubController(
      data: loadedBook,
    );
    super.initState();
  }

  Future<Uint8List> _loadFromAssets(String assetName) async {
    final bytes = await rootBundle.load(assetName);
    return bytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
      title: EpubActualChapter(
        controller: _epubReaderController,
        builder: (chapterValue) => Text(
          (chapterValue?.chapter?.Title?.trim() ?? '').replaceAll('\n', ''),
          textAlign: TextAlign.start,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.save_alt),
          color: Colors.white,
          onPressed: () => _showCurrentEpubCfi(context),
        ),
      ],
    ),
    drawer: Drawer(
      child: EpubReaderTableOfContents(controller: _epubReaderController),
    ),
    body: EpubView(
      controller: _epubReaderController,
      onDocumentLoaded: (document) {
        print('isLoaded: $document');
      },
      dividerBuilder: (_) => Divider(),
    ),
  );

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController.generateEpubCfi();

    if (cfi != null) {
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(cfi),
            action: SnackBarAction(
              label: 'GO',
              onPressed: () {
                _epubReaderController.gotoEpubCfi(cfi);
              },
            ),
          ),
        );
    }
  }
}