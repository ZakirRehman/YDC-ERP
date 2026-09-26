import 'package:uuid/uuid.dart';

/// Clean domain entity representing a single parsed student record from an ingested sheet
class ParsedStudentRecord {
  final String id;
  String name;
  String rollNo;
  String cnic;
  String phone;
  String department;
  int semester;
  String role;
  bool isCnicValid;
  bool isRollValid;
  bool isPhoneValid;

  ParsedStudentRecord({
    String? id,
    required this.name,
    required this.rollNo,
    required this.cnic,
    this.phone = '',
    required this.department,
    this.semester = 1,
    this.role = '',
    this.isCnicValid = true,
    this.isRollValid = true,
    this.isPhoneValid = true,
  }) : id = id ?? const Uuid().v4();

  bool get requiresReview => !isCnicValid || !isRollValid;

  bool get isExecutive => isExecutiveTitle(role);

  static bool isExecutiveTitle(String? title) {
    if (title == null || title.trim().isEmpty) return false;
    final t = title.toLowerCase().trim();
    if (t == 'member' || t == 'student' || t == 'general member' || t == 'attendee' || t == 'enrolled') {
      return false;
    }
    return t.contains('president') ||
        t.contains('vp') ||
        t.contains('vice president') ||
        t.contains('secretary') ||
        t.contains('general secretary') ||
        t.contains('joint secretary') ||
        t.contains('finance') ||
        t.contains('treasurer') ||
        t.contains('coordinator') ||
        t.contains('officer') ||
        t.contains('director') ||
        t.contains('head') ||
        t.contains('lead') ||
        t.contains('cabinet') ||
        t.contains('chair');
  }

  ParsedStudentRecord copyWith({
    String? name,
    String? rollNo,
    String? cnic,
    String? phone,
    String? department,
    int? semester,
    String? role,
    bool? isCnicValid,
    bool? isRollValid,
    bool? isPhoneValid,
  }) {
    return ParsedStudentRecord(
      id: id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      role: role ?? this.role,
      isCnicValid: isCnicValid ?? this.isCnicValid,
      isRollValid: isRollValid ?? this.isRollValid,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
    );
  }
}

/// Robust regex tokenizer and column boundary extractor tailored for Pakistani institutional formats
class SheetParser {
  SheetParser._();

  // CNIC: 13 digits total, e.g. 13101-1234567-1 or 1310112345671
  static final RegExp _cnicDashedRegex = RegExp(r'\b\d{5}-\d{7}-\d{1}\b');
  static final RegExp _cnicRawRegex = RegExp(r'\b\d{13}\b');

  // AUST Roll Number: FA21-BCS-042, SP22-SE-001, FA20-BEE-109, etc.
  static final RegExp _rollNoRegex = RegExp(r'\b(FA|SP)\d{2}-[A-Z]{2,4}-\d{2,4}\b', caseSensitive: false);

  // Pakistani Phone: 0300-1234567, 03001234567, +923001234567
  static final RegExp _phoneRegex = RegExp(r'\b(03\d{2}[-]?\d{7}|\+923\d{2}[-]?\d{7})\b');

  /// Parse raw multiline OCR string output into a list of structured student rows
  static List<ParsedStudentRecord> parseRawOcrStream(String rawOcrText) {
    final List<ParsedStudentRecord> records = [];
    if (rawOcrText.trim().isEmpty) return records;

    final lines = rawOcrText.split(RegExp(r'\r?\n'));

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Skip common header keywords in physical rosters
      final lower = trimmed.toLowerCase();
      if (lower.contains('attendance') ||
          lower.contains('registration') ||
          lower.contains('student name') ||
          lower.contains('roll no') ||
          lower.contains('cnic') ||
          lower.contains('signature') ||
          lower.contains('youth development center') ||
          lower.contains('abbottabad university')) {
        continue;
      }

      // Extract CNIC
      String cnic = '';
      bool isCnicValid = false;
      final cnicMatch = _cnicDashedRegex.firstMatch(trimmed);
      if (cnicMatch != null) {
        cnic = cnicMatch.group(0)!;
        isCnicValid = true;
      } else {
        final rawCnicMatch = _cnicRawRegex.firstMatch(trimmed);
        if (rawCnicMatch != null) {
          final digits = rawCnicMatch.group(0)!;
          cnic = '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12, 13)}';
          isCnicValid = true;
        } else {
          cnic = 'Needs Review';
          isCnicValid = false;
        }
      }

      // Extract Roll Number
      String rollNo = '';
      bool isRollValid = false;
      final rollMatch = _rollNoRegex.firstMatch(trimmed);
      if (rollMatch != null) {
        rollNo = rollMatch.group(0)!.toUpperCase();
        isRollValid = true;
      } else {
        rollNo = 'Needs Review';
        isRollValid = false;
      }

      // Extract Phone Number
      String phone = '';
      bool isPhoneValid = true;
      final phoneMatch = _phoneRegex.firstMatch(trimmed);
      if (phoneMatch != null) {
        phone = phoneMatch.group(0)!;
      }

      // Extract Executive Designation/Role if present
      String detectedRole = '';
      for (final candidate in [
        'Vice President',
        'General Secretary',
        'Joint Secretary',
        'Finance Secretary',
        'Media Officer',
        'Cabinet Member',
        'President',
        'Coordinator',
        'Treasurer',
        'Director',
        'VP',
        'Secretary',
        'Lead',
        'Head',
      ]) {
        if (RegExp(r'\b' + RegExp.escape(candidate) + r'\b', caseSensitive: false).hasMatch(trimmed)) {
          detectedRole = candidate;
          break;
        }
      }

      // Extract Name (heuristically tokens before roll or CNIC)
      String cleanedLine = trimmed;
      if (cnic != 'Needs Review') cleanedLine = cleanedLine.replaceAll(cnic, '');
      if (rollNo != 'Needs Review') cleanedLine = cleanedLine.replaceAll(rollNo, '');
      if (phone.isNotEmpty) cleanedLine = cleanedLine.replaceAll(phone, '');
      if (detectedRole.isNotEmpty) cleanedLine = cleanedLine.replaceAll(RegExp(r'\b' + RegExp.escape(detectedRole) + r'\b', caseSensitive: false), '');

      // Remove unwanted punctuation
      cleanedLine = cleanedLine.replaceAll(RegExp(r'[|;:,_\-\[\]\(\)]'), ' ');
      final words = cleanedLine.split(RegExp(r'\s+')).where((w) => w.length > 1 && !RegExp(r'^\d+$').hasMatch(w)).toList();

      String studentName = words.take(3).join(' ');
      if (studentName.isEmpty) {
        studentName = 'Unknown Student';
      }

      // Infer Department from Roll Number (e.g. FA21-BCS-042 -> Computer Science)
      String department = inferDepartmentFromRollNo(rollNo);

      records.add(
        ParsedStudentRecord(
          name: studentName,
          rollNo: rollNo,
          cnic: cnic,
          phone: phone,
          department: department,
          semester: 1,
          role: detectedRole,
          isCnicValid: isCnicValid,
          isRollValid: isRollValid,
          isPhoneValid: isPhoneValid,
        ),
      );
    }

    return records;
  }

  /// Automatically map discipline acronyms to full AUST department names
  static String inferDepartmentFromRollNo(String rollNo) {
    final upper = rollNo.toUpperCase();
    if (upper.contains('-BCS-') || upper.contains('-CS-')) return 'Computer Science';
    if (upper.contains('-BSE-') || upper.contains('-SE-')) return 'Software Engineering';
    if (upper.contains('-BIT-') || upper.contains('-IT-')) return 'Information Technology';
    if (upper.contains('-BBA-')) return 'Management Sciences';
    if (upper.contains('-BEE-') || upper.contains('-EE-')) return 'Electrical Engineering';
    if (upper.contains('-BME-') || upper.contains('-ME-')) return 'Mechanical Engineering';
    if (upper.contains('-CIV-') || upper.contains('-CE-')) return 'Civil Engineering';
    if (upper.contains('-ENV-')) return 'Earth & Environmental Sciences';
    if (upper.contains('-PHARM-')) return 'Pharmacy';
    if (upper.contains('-ENG-')) return 'English';
    if (upper.contains('-MATH-')) return 'Mathematics';
    return 'General Studies';
  }
}
