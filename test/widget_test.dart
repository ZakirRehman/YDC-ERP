import 'package:flutter_test/flutter_test.dart';
import 'package:ydc_aust/core/services/ocr/sheet_parser.dart';

void main() {
  group('SheetParser Unit Tests', () {
    test('Tokenizes Pakistani CNIC formats correctly', () {
      const rawText = '''
Muhammad Hamza   FA21-BCS-042   13101-4567891-3   0300-1234567
Fatima Zahra     SP22-SE-019    1310178945612     0312-9876543
''';

      final records = SheetParser.parseRawOcrStream(rawText);

      expect(records.length, 2);

      // Record 1 (dashed CNIC)
      expect(records[0].rollNo, 'FA21-BCS-042');
      expect(records[0].cnic, '13101-4567891-3');
      expect(records[0].department, 'Computer Science');
      expect(records[0].isCnicValid, isTrue);
      expect(records[0].isRollValid, isTrue);

      // Record 2 (raw 13-digit CNIC formatted into standard dashed syntax)
      expect(records[1].rollNo, 'SP22-SE-019');
      expect(records[1].cnic, '13101-7894561-2');
      expect(records[1].department, 'Software Engineering');
      expect(records[1].isCnicValid, isTrue);
      expect(records[1].isRollValid, isTrue);
    });

    test('Infers department from AUST roll number conventions', () {
      expect(SheetParser.inferDepartmentFromRollNo('FA21-BCS-042'), 'Computer Science');
      expect(SheetParser.inferDepartmentFromRollNo('SP22-SE-019'), 'Software Engineering');
      expect(SheetParser.inferDepartmentFromRollNo('FA20-BEE-105'), 'Electrical Engineering');
      expect(SheetParser.inferDepartmentFromRollNo('SP23-BBA-033'), 'Management Sciences');
      expect(SheetParser.inferDepartmentFromRollNo('FA21-ENV-012'), 'Earth & Environmental Sciences');
    });
  });
}
