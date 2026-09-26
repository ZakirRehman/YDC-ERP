import 'package:drift/drift.dart';
import 'societies_table.dart';

class SocietyMembers extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get societyId => text().references(Societies, #id, onDelete: KeyAction.cascade)();
  TextColumn get fullName => text()();
  TextColumn get rollNo => text()(); // FA21-BCS-042
  TextColumn get cnic => text()(); // 13-digit or formatted
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get department => text()();
  IntColumn get semester => integer()();
  DateTimeColumn get joinedDate => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
