import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:watch_my_cash_flow/data/database/dao/category_dao.dart';
import 'package:watch_my_cash_flow/data/database/dao/entry_dao.dart';

part 'app_database.g.dart';

late final AppDatabase db;

void initDatabase() {
  db = AppDatabase();
}

@DriftDatabase(
  tables: [Categories, CashFlowEntries],
  daos: [CategoryDao, EntryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isIncome => boolean()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CashFlowEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get categoryId =>
      text().references(Categories, #id)();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
