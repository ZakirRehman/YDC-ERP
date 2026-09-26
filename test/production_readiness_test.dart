import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydc_aust/core/database/app_database.dart';
import 'package:ydc_aust/core/database/database_seeder.dart';
import 'package:ydc_aust/core/security/encryption_service.dart';
import 'package:ydc_aust/core/services/ocr/sheet_parser.dart';
import 'package:ydc_aust/core/services/reporting/pdf_dossier_service.dart';
import 'package:ydc_aust/features/vault/presentation/screens/vault_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Production Readiness & Core Integrity Tests', () {
    test('EncryptionService AES-256-GCM encrypts, stores, and decrypts accurately', () async {
      const plainText = 'CONFIDENTIAL INSTITUTIONAL RECORD 2026';
      final plainBytes = Uint8List.fromList(utf8.encode(plainText));
      const password = '1234';

      final encPath = await EncryptionService.encryptAndStoreFile(
        rawBytes: plainBytes,
        originalFileName: 'test_doc.txt',
        masterPassword: password,
      );

      expect(File(encPath).existsSync(), isTrue);

      final decryptedBytes = await EncryptionService.decryptFileInMemory(
        encryptedFilePath: encPath,
        masterPassword: password,
      );

      final decryptedText = utf8.decode(decryptedBytes);
      expect(decryptedText, equals(plainText));

      // Checksum matches original
      final originalChecksum = await EncryptionService.calculateChecksum(plainBytes);
      final decryptedChecksum = await EncryptionService.calculateChecksum(decryptedBytes);
      expect(decryptedChecksum, equals(originalChecksum));

      // Cleanup
      try {
        await File(encPath).delete();
      } catch (_) {}
    });

    test('EncryptionService fails authentication with incorrect password', () async {
      const plainText = 'SECRET DATA';
      final plainBytes = Uint8List.fromList(utf8.encode(plainText));
      const password = 'correct_pin';

      final encPath = await EncryptionService.encryptAndStoreFile(
        rawBytes: plainBytes,
        originalFileName: 'auth_test.txt',
        masterPassword: password,
      );

      expect(
        () async => await EncryptionService.decryptFileInMemory(
          encryptedFilePath: encPath,
          masterPassword: 'wrong_pin',
        ),
        throwsA(anything),
      );

      // Cleanup
      try {
        await File(encPath).delete();
      } catch (_) {}
    });

    test('SheetParser correctly parses and validates Pakistani CNIC and roll numbers', () {
      const sampleText = '''
Muhammad Hamza      FA21-BCS-042    13101-4567891-3    0300-1234567
Fatima Zahra        SP22-SE-019     1310178945612      0312-9876543
      ''';

      final records = SheetParser.parseRawOcrStream(sampleText);
      expect(records.length, equals(2));

      final first = records.first;
      expect(first.rollNo, equals('FA21-BCS-042'));
      expect(first.cnic, equals('13101-4567891-3'));
      expect(first.isCnicValid, isTrue);
      expect(first.isRollValid, isTrue);
      expect(first.department, equals('Computer Science'));

      final second = records[1];
      expect(second.rollNo, equals('SP22-SE-019'));
      expect(second.cnic, equals('13101-7894561-2'));
      expect(second.department, equals('Software Engineering'));
    });

    test('PdfDossierService compiles valid multi-page PDF bytes with metrics', () async {
      final data = PdfDossierData(
        monthYear: 'September 2026',
        totalSocieties: 6,
        totalMembers: 42,
        totalEvents: 2,
        totalAttendees: 800,
        totalBudgetSpent: 113000,
        totalSponsorships: 500000,
        pillarDistribution: {
          'Education': 2,
          'Employment': 1,
          'Engagement': 2,
          'Environment': 1,
        },
        achievements: [
          {'title': 'Green Campus Drive', 'description': '500 trees planted.'},
        ],
        financialItems: [
          {'title': 'HEC Grant', 'amount': 350000.0, 'type': 'Grant'},
        ],
      );

      final pdfBytes = await PdfDossierService.generateMonthlyDossier(data);
      expect(pdfBytes, isNotEmpty);
      // PDF documents begin with '%PDF'
      final header = String.fromCharCodes(pdfBytes.take(4));
      expect(header, equals('%PDF'));
    });

    test('DatabaseSeeder seeds in-memory SQLite database properly', () async {
      final inMemoryDb = AppDatabase(NativeDatabase.memory());

      await DatabaseSeeder.seedIfEmpty(inMemoryDb);

      final societies = await inMemoryDb.select(inMemoryDb.societies).get();
      final cabinets = await inMemoryDb.select(inMemoryDb.cabinetMembers).get();
      final events = await inMemoryDb.select(inMemoryDb.events).get();
      final vault = await inMemoryDb.select(inMemoryDb.confidentialVault).get();

      expect(societies.length, equals(6));
      expect(cabinets.length, greaterThanOrEqualTo(4));
      expect(events.length, equals(2));
      expect(events.every((e) => e.actualExpense == 0.0), isTrue);
      expect(vault.length, equals(1));

      final finances = await inMemoryDb.select(inMemoryDb.financialRecords).get();
      final seededExpenses = finances.where((f) => f.type.toLowerCase() == 'expense').toList();
      expect(seededExpenses, isEmpty, reason: 'Seeded database must not include mock or phantom expense vouchers');

      await inMemoryDb.close();
    });

    test('DecryptedContentDetector accurately identifies PDF, Image, Text and Binary signatures', () {
      // 1. PDF with magic bytes %PDF
      final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34]);
      expect(
        DecryptedContentDetector.detect(bytes: pdfBytes, fileName: 'document.enc'),
        equals(VaultDocumentType.pdf),
      );

      // 2. PNG with magic bytes
      final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00]);
      expect(
        DecryptedContentDetector.detect(bytes: pngBytes, fileName: null),
        equals(VaultDocumentType.image),
      );

      // 3. JPEG with magic bytes
      final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
      expect(
        DecryptedContentDetector.detect(bytes: jpegBytes, fileName: 'photo.bin'),
        equals(VaultDocumentType.image),
      );

      // 4. Plaintext MoU string
      final textBytes = Uint8List.fromList(utf8.encode('MEMORANDUM OF UNDERSTANDING\nPARTIES: YDC AUST & PMYP'));
      expect(
        DecryptedContentDetector.detect(bytes: textBytes, fileName: 'MOU_AUST.txt'),
        equals(VaultDocumentType.text),
      );
      // Plaintext without .txt extension
      expect(
        DecryptedContentDetector.detect(bytes: textBytes, fileName: 'MOU_AUST.enc'),
        equals(VaultDocumentType.text),
      );

      // 5. Unsupported binary
      final binaryBytes = Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0x11, 0x00, 0x07]);
      expect(
        DecryptedContentDetector.detect(bytes: binaryBytes, fileName: 'data.dat'),
        equals(VaultDocumentType.unsupported),
      );
    });
  });
}
