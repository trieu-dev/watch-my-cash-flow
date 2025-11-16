import 'package:drift/drift.dart';
import '../app_database.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {

  CategoryDao(super.db);

  Future<List<Category>> getAll() => select(categories).get();

  Stream<List<Category>> watchAll() => select(categories).watch();

  Future<void> insertCategory(CategoriesCompanion data) =>
      into(categories).insert(data);

  Future<void> deleteCategory(String id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();
}
