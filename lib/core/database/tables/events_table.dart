import 'package:drift/drift.dart';
import 'societies_table.dart';

class Events extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get societyId => text().nullable().references(Societies, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isCollaboration => boolean().withDefault(const Constant(false))();
  TextColumn get collaboratorNames => text().nullable()();
  TextColumn get venue => text().nullable()();
  RealColumn get allocatedBudget => real().withDefault(const Constant(0.0))();
  RealColumn get actualExpense => real().withDefault(const Constant(0.0))();
  TextColumn get positiveImpactSummary => text().nullable()();
  IntColumn get attendeesCount => integer().withDefault(const Constant(0))();
  TextColumn get bannerImagePath => text().nullable()();
  TextColumn get imagePaths => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
