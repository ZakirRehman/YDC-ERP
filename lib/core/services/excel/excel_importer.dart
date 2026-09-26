import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../ocr/sheet_parser.dart';

/// Service for high-speed parsing and schema-mapping of Excel (.xlsx) and CSV rosters
class ExcelImporter {
  ExcelImporter._();

  /// Parse either a .xlsx or .csv file into clean ParsedStudentRecord rows
  static Future<List<ParsedStudentRecord>> importFile(String filePath) async {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.csv')) {
      return _parseCsv(filePath);
    } else if (lower.endsWith('.xlsx') || lower.endsWith('.xls')) {
      return _parseExcel(filePath);
    } else {
      throw Exception('Unsupported file format. Please upload a .xlsx or .csv file.');
    }
  }

  static Future<List<ParsedStudentRecord>> _parseCsv(String filePath) async {
    final file = File(filePath);
    final rawCsv = await file.readAsString(encoding: utf8);
    final rows = const CsvToListConverter().convert(rawCsv);

    if (rows.isEmpty) return [];

    final headerRow = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
    final headerMap = _mapHeaders(headerRow);

    final List<ParsedStudentRecord> records = [];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      records.add(_extractRecordFromRow(row, headerMap));
    }

    return records;
  }

  static Future<List<ParsedStudentRecord>> _parseExcel(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) return [];

    // Use the first active sheet in the spreadsheet
    final sheet = excel.tables.values.first;
    if (sheet.rows.isEmpty) return [];

    final headerRow = sheet.rows.first
        .map((cell) => cell?.value?.toString().toLowerCase().trim() ?? '')
        .toList();

    final headerMap = _mapHeaders(headerRow);

    final List<ParsedStudentRecord> records = [];
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final rowValues = row.map((c) => c?.value?.toString().trim() ?? '').toList();
      if (rowValues.every((c) => c.isEmpty)) continue;

      records.add(_extractRecordFromRow(rowValues, headerMap));
    }

    return records;
  }

  static Map<String, int> _mapHeaders(List<String> headers) {
    final Map<String, int> map = {};

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i];
      if (h.contains('name') && !map.containsKey('name')) {
        map['name'] = i;
      } else if ((h.contains('roll') || h.contains('reg') || h.contains('student id')) && !map.containsKey('roll')) {
        map['roll'] = i;
      } else if ((h.contains('cnic') || h.contains('nic') || h.contains('b-form') || h.contains('bform')) && !map.containsKey('cnic')) {
        map['cnic'] = i;
      } else if ((h.contains('phone') || h.contains('mobile') || h.contains('contact') || h.contains('cell')) && !map.containsKey('phone')) {
        map['phone'] = i;
      } else if ((h.contains('department') || h.contains('dept') || h.contains('program')) && !map.containsKey('dept')) {
        map['dept'] = i;
      } else if ((h.contains('semester') || h.contains('sem')) && !map.containsKey('semester')) {
        map['semester'] = i;
      } else if ((h.contains('role') || h.contains('designation') || h.contains('position') || h.contains('title') || h.contains('office') || h.contains('post')) && !map.containsKey('role')) {
        map['role'] = i;
      }
    }

    return map;
  }

  static ParsedStudentRecord _extractRecordFromRow(List<dynamic> row, Map<String, int> map) {
    String getVal(String key, [int fallbackIdx = -1]) {
      if (map.containsKey(key) && map[key]! < row.length) {
        return row[map[key]!].toString().trim();
      }
      if (fallbackIdx >= 0 && fallbackIdx < row.length) {
        return row[fallbackIdx].toString().trim();
      }
      return '';
    }

    final name = getVal('name', 0);
    final roll = getVal('roll', 1);
    final cnic = getVal('cnic', 2);
    final phone = getVal('phone', 3);
    String dept = getVal('dept', 4);
    final semStr = getVal('semester', 5);
    final role = getVal('role', 6);

    if (dept.isEmpty && roll.isNotEmpty) {
      dept = SheetParser.inferDepartmentFromRollNo(roll);
    }

    final cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    final rollRegex = RegExp(r'^(FA|SP)\d{2}-[A-Z]{2,4}-\d{2,4}$', caseSensitive: false);

    final isCnicValid = cnicRegex.hasMatch(cnic);
    final isRollValid = rollRegex.hasMatch(roll);

    return ParsedStudentRecord(
      name: name.isEmpty ? 'Student' : name,
      rollNo: roll.isEmpty ? 'FA24-GEN-000' : roll,
      cnic: cnic.isEmpty ? '13101-0000000-0' : cnic,
      phone: phone,
      department: dept.isEmpty ? 'Computer Science' : dept,
      semester: int.tryParse(semStr) ?? 1,
      role: role,
      isCnicValid: isCnicValid,
      isRollValid: isRollValid,
      isPhoneValid: phone.isNotEmpty,
    );
  }
}
