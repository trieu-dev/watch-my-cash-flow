import 'package:drift/drift.dart';
import '../app_database.dart';

part 'entry_dao.g.dart';

@DriftAccessor(tables: [CashFlowEntries])
class EntryDao extends DatabaseAccessor<AppDatabase>
    with _$EntryDaoMixin {

  EntryDao(super.db);

  Future<void> insertEntry(CashFlowEntriesCompanion data) =>
      into(cashFlowEntries).insert(data);

  Future<List<CashFlowEntry>> getAll() =>
      select(cashFlowEntries).get();

  Stream<List<CashFlowEntry>> watchMonth(int month, int year) {
    return (select(cashFlowEntries)
          ..where((t) =>
              t.date.month.equals(month) &
              t.date.year.equals(year)))
        .watch();
  }
}
