import 'package:drift/drift.dart';

class FinancialRecords extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get monthYear => text()(); // "MM-YYYY"
  TextColumn get type => text()(); // 'Expense', 'Revenue', 'Sponsorship', 'Grant'
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get sponsorName => text().nullable()();
  TextColumn get voucherPath => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
