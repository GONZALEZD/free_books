import 'package:flutter_test/flutter_test.dart';
import 'package:free_books/common/service/database/sqlite_database_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test("Database creation", () async {
    final db = await SqliteDatabaseApi().db;
    print("DB path: ${db.path}");
    expect(db.path, isNotNull);
  });
}