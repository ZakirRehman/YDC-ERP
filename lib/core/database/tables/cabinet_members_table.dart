import 'package:drift/drift.dart';
import 'societies_table.dart';

class CabinetMembers extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get societyId => text().references(Societies, #id, onDelete: KeyAction.cascade)();
  TextColumn get tenureSession => text()(); // e.g. "2025-2026"
  TextColumn get role => text()(); // Standard (President, Vice President, etc.) or custom cabinet role string
  TextColumn get fullName => text()();
  TextColumn get cnic => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  TextColumn get department => text()();
  IntColumn get semester => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
