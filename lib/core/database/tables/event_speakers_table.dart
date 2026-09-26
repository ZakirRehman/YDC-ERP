import 'package:drift/drift.dart';
import 'events_table.dart';

class EventSpeakers extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get eventId => text().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get designation => text().nullable()();
  TextColumn get organization => text()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get contactEmail => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
