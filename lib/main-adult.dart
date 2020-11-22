import 'package:flutter/material.dart';
import 'package:free_books/application.dart';
import 'package:free_books/main_app.dart';

import 'common/app/flavors.dart';

void main() {
  Application.setup(flavor: Flavor.ADULT);
  runApp(MyApp());
}
