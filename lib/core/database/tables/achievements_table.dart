import 'package:drift/drift.dart';
import 'societies_table.dart';

class Achievements extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get monthYear => text()(); // "MM-YYYY" e.g. "09-2026"
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get societyId => text().nullable().references(Societies, #id, onDelete: KeyAction.setNull)();
  TextColumn get proofImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
