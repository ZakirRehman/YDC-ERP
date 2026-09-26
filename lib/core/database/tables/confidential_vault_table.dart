import 'package:drift/drift.dart';
import 'societies_table.dart';

class ConfidentialVault extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get societyId => text().nullable().references(Societies, #id, onDelete: KeyAction.setNull)();
  TextColumn get category => text()(); // 'Monthly Audits', 'MOU', 'Contract', 'PMYP', 'Internee_Record', 'Audit', or Society Acronym/Name
  TextColumn get title => text()();
  TextColumn get referenceNumber => text().nullable()();
  DateTimeColumn get effectiveDate => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get encryptedFilePath => text()(); // Path to AES-256-GCM file in AppData
  TextColumn get fileChecksum => text()(); // SHA-256 checksum
  IntColumn get fileSizeBytes => integer().nullable()();
  TextColumn get originalFileName => text().nullable()();
  TextColumn get metadataNotes => text().nullable()();
  DateTimeColumn get uploadedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
