import 'package:drift/drift.dart';

class Societies extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()();
  TextColumn get acronym => text().nullable()();
  TextColumn get pillar => text()(); // Education, Employment, Engagement, Environment
  TextColumn get facultyAdvisor => text()();
  TextColumn get logoPath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
