import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/application.dart';
import 'package:free_books/common/app/app_navigator.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/service/book/google_books_api.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/common/service/database/sqlite_database_api.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookProvider(
            booksApi: GoogleBooksApi(),
            databaseApi: SqliteDatabaseApi(),
          ),
        ),
      ],
      child: buildMaterialApp(context),
    );
  }

  MaterialApp buildMaterialApp(BuildContext context) {
    return MaterialApp(
      // DESIGN
      theme: Application.get().light,
      darkTheme: Application.get().dark,
      debugShowCheckedModeBanner: false,

      // NAVIGATION
      initialRoute: AppNavigator.root,
      onGenerateRoute: AppNavigator.routeFactory(defaultTargetPlatform),

      // LOCALIZATION
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppStrings.delegate,
      ],
      supportedLocales: AppStrings.supportedLocales,
      onGenerateTitle: (context) => I18n.of(context).value("title"),
    );
  }
}
