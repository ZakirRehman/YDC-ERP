import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/ocr/image_preprocessor.dart';
import '../../../../core/services/ocr/ocr_engine.dart';
import '../../../../core/services/ocr/sheet_parser.dart';
import '../../../../core/services/excel/excel_importer.dart';
import '../../../../core/widgets/ui_state_widgets.dart';

class SheetScanScreen extends StatefulWidget {
  final List<Map<String, String>> societies;
  final Future<void> Function(String societyId, List<ParsedStudentRecord> records)? onCommitRoster;

  const SheetScanScreen({
    super.key,
    this.societies = const [],
    this.onCommitRoster,
  });

  @override
  State<SheetScanScreen> createState() => _SheetScanScreenState();
}

class _SheetScanScreenState extends State<SheetScanScreen> {
  File? _selectedImage;
  bool _isProcessing = false;
  String _processingStage = '';
  List<ParsedStudentRecord> _records = [];
  String? _selectedSocietyId;
  final TransformationController _transformController = TransformationController();
  String _filterMode = 'all'; // 'all', 'review', 'valid'

  @override
  void initState() {
    super.initState();
    if (widget.societies.isNotEmpty) {
      _selectedSocietyId = widget.societies.first['id'];
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp'],
      dialogTitle: 'Select Physical Roster / Sign-up Sheet Image',
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() {
        _selectedImage = File(path);
        _isProcessing = true;
        _processingStage = 'Preprocessing image (grayscale & contrast boost)...';
      });

      try {
        // 1. Offload heavy image pre-processing to worker isolate
        final prepPath = await ImagePreprocessor.preprocessSheet(path);
        if (mounted) {
          setState(() {
            _processingStage = 'Running offline OCR extraction engine...';
          });
        }

        // 2. Extract text via Tesseract wrapper
        final rawOcrText = await OcrEngine.extractText(prepPath);

        // 3. Regex tokenization for Pakistani academic formats
        if (mounted) {
          setState(() {
            _processingStage = 'Parsing tabular student columns & CNIC validation...';
          });
        }

        final parsed = SheetParser.parseRawOcrStream(rawOcrText);

        if (mounted) {
          setState(() {
            _records = parsed;
            _isProcessing = false;
          });
          UiNotification.success(context, 'OCR extracted ${parsed.length} student records from sheet.');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessing = false);
          UiNotification.error(context, 'Processing error: $e');
        }
      }
    }
  }

  Future<void> _pickAndProcessSpreadsheet() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      dialogTitle: 'Select Batch Student Spreadsheet (.xlsx or .csv)',
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() {
        _selectedImage = null;
        _isProcessing = true;
        _processingStage = 'Importing spreadsheet records & mapping columns...';
      });

      try {
        final imported = await ExcelImporter.importFile(path);
        if (mounted) {
          setState(() {
            _records = imported;
            _isProcessing = false;
          });
          UiNotification.success(context, 'Imported ${imported.length} students from spreadsheet.');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessing = false);
          UiNotification.error(context, 'Spreadsheet import error: $e');
        }
      }
    }
  }

  void _loadDemoOcrSample() async {
    setState(() {
      _isProcessing = true;
      _processingStage = 'Simulating high-res paper form scan...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    final rawText = await OcrEngine.extractText('');
    final parsed = SheetParser.parseRawOcrStream(rawText);

    if (mounted) {
      setState(() {
        _records = parsed;
        _isProcessing = false;
      });
      UiNotification.info(context, 'Demo attendance sheet loaded (${parsed.length} records).');
    }
  }

  void _addNewRow() {
    setState(() {
      _records.add(
        ParsedStudentRecord(
          name: 'New Student',
          rollNo: 'FA24-BCS-001',
          cnic: '13101-0000000-1',
          phone: '0300-0000000',
          department: 'Computer Science',
          semester: 1,
          role: 'Member',
          isCnicValid: false,
          isRollValid: true,
        ),
      );
    });
  }

  void _deleteRow(int index) {
    setState(() {
      _records.removeAt(index);
    });
  }

  void _autoFormatAll() {
    int updatedCount = 0;
    final rollRegex = RegExp(r'^(FA|SP)\d{2}-[A-Z]{2,4}-\d{2,4}$', caseSensitive: false);
    final cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');

    setState(() {
      for (final r in _records) {
        final cleanName = r.name.trim();
        final cleanRoll = r.rollNo.trim().toUpperCase();
        var cleanCnic = r.cnic.trim();

        // Standardize CNIC without dashes if exactly 13 digits
        final digitsOnly = cleanCnic.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length == 13 && !cleanCnic.contains('-')) {
          cleanCnic = '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, 12)}-${digitsOnly.substring(12, 13)}';
        }

        r.name = cleanName;
        r.rollNo = cleanRoll;
        r.cnic = cleanCnic;
        r.isRollValid = rollRegex.hasMatch(cleanRoll);
        r.isCnicValid = cnicRegex.hasMatch(cleanCnic);
        updatedCount++;
      }
    });

    UiNotification.success(context, 'Auto-formatted $updatedCount records.');
  }

  Future<void> _clearAllRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Ingestion Table'),
        content: const Text('Remove all uncommitted student records from this session?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _records.clear();
        _selectedImage = null;
      });
      if (mounted) {
        UiNotification.info(context, 'Table cleared.');
      }
    }
  }

  Future<void> _commitRoster() async {
    if (_records.isEmpty) {
      UiNotification.error(context, 'No records to commit.');
      return;
    }

    if (_selectedSocietyId == null) {
      UiNotification.error(context, 'Please select a destination society from the toolbar.');
      return;
    }

    if (widget.onCommitRoster != null) {
      setState(() => _isProcessing = true);
      try {
        final cabinetCount = _records.where((r) => r.isExecutive).length;
        final studentCount = _records.length - cabinetCount;
        await widget.onCommitRoster!(_selectedSocietyId!, _records);
        if (mounted) {
          setState(() {
            _records.clear();
            _selectedImage = null;
          });
          if (cabinetCount > 0 && studentCount > 0) {
            UiNotification.success(context, 'Smart Routing: Committed $cabinetCount to Cabinet Hierarchy and $studentCount to Enrolled Members!');
          } else if (cabinetCount > 0) {
            UiNotification.success(context, 'Smart Routing: Committed $cabinetCount executive records to Cabinet Hierarchy!');
          } else {
            UiNotification.success(context, 'Successfully committed $studentCount members to Enrolled Student Members!');
          }
        }
      } catch (e) {
        if (mounted) {
          UiNotification.error(context, 'Failed to commit roster: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsReviewCount = _records.where((r) => r.requiresReview).length;
    final validCount = _records.length - needsReviewCount;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: Column(
        children: [
          // Screen Action Bar
          _buildActionHeader(needsReviewCount),

          // Main Split-Pane Workspace
          Expanded(
            child: _isProcessing
                ? _buildProcessingIndicator()
                : Row(
                    children: [
                      // Left Half (45%): High-Resolution Interactive Document Viewer
                      Expanded(
                        flex: 5,
                        child: _buildDocumentViewport(),
                      ),

                      // 1px Vertical Divider
                      Container(width: 1, color: AppColors.borderSubtle),

                      // Right Half (55%): Interactive Verification Grid
                      Expanded(
                        flex: 6,
                        child: _buildVerificationTable(needsReviewCount, validCount),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHeader(int needsReviewCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1120;

          const titleWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.scanLine, size: 20, color: AppColors.brandPurple),
              SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Physical Sheet Ingestion — OCR & Batch Verification',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Human-in-the-Loop: Review, edit inline, and verify institutional student rosters.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );

          final actionsWidget = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Target Society Selector (Hardened to prevent duplicate value assertions)
              Builder(
                builder: (context) {
                  final uniqueMap = <String, Map<String, String>>{};
                  for (final s in widget.societies) {
                    final id = s['id'];
                    if (id != null && !uniqueMap.containsKey(id)) {
                      uniqueMap[id] = s;
                    }
                  }
                  final uniqueSocieties = uniqueMap.values.toList();
                  if (uniqueSocieties.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.statusDanger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.statusDanger.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.alertCircle, size: 14, color: AppColors.statusDanger),
                          SizedBox(width: 6),
                          Text('No Societies in System', style: TextStyle(fontSize: 11, color: AppColors.statusDanger, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }

                  final validIds = uniqueMap.keys.toSet();
                  final effectiveId = validIds.contains(_selectedSocietyId)
                      ? _selectedSocietyId
                      : uniqueSocieties.first['id'];

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 36,
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: effectiveId,
                        hint: const Text('Select Society', style: TextStyle(fontSize: 12)),
                        items: uniqueSocieties.map((s) {
                          return DropdownMenuItem<String>(
                            value: s['id'],
                            child: Text(
                              '${s['name']} (${s['pillar']})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedSocietyId = val);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),

              // Batch Spreadsheet Trigger
              OutlinedButton.icon(
                onPressed: _pickAndProcessSpreadsheet,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                icon: const Icon(LucideIcons.fileSpreadsheet, size: 15),
                label: const Text('Excel / CSV'),
              ),

              // Upload Image Trigger
              OutlinedButton.icon(
                onPressed: _pickAndProcessImage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                icon: const Icon(LucideIcons.camera, size: 15),
                label: const Text('Scan Sheet'),
              ),

              // Demo Roster Ingestion
              OutlinedButton.icon(
                onPressed: _loadDemoOcrSample,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                icon: const Icon(LucideIcons.sparkles, size: 15, color: AppColors.brandPurple),
                label: const Text('Demo Sample'),
              ),

              // Commit Roster CTA
              ElevatedButton.icon(
                onPressed: _records.isEmpty ? null : _commitRoster,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pillarEnvironment,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                icon: const Icon(LucideIcons.checkCircle2, size: 15),
                label: Text('Commit Roster (${_records.length})'),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                const Expanded(child: titleWidget),
                const SizedBox(width: 12),
                actionsWidget,
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                const SizedBox(height: 10),
                actionsWidget,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.pillarEnvironment),
            const SizedBox(height: 20),
            Text(
              _processingStage,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Running via background Dart worker thread (Zero UI Jank)',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentViewport() {
    return Container(
      color: const Color(0xFF0F172A), // Dark slate canvas for optical contrast
      child: Stack(
        children: [
          if (_selectedImage != null)
            InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(_selectedImage!, fit: BoxFit.contain),
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(LucideIcons.fileImage, size: 36, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Physical Sheet or Document Selected',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upload a photo of an attendance roster or load a demo sample above.',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickAndProcessImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textDark,
                      ),
                      icon: const Icon(LucideIcons.upload, size: 16),
                      label: const Text('Select Image File'),
                    ),
                  ],
                ),
              ),
            ),

          // Zoom Controls Overlay
          if (_selectedImage != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.zoomIn, size: 18, color: Colors.white),
                      onPressed: () {
                        _transformController.value = Matrix4.copy(_transformController.value)..scaleByDouble(1.2, 1.2, 1.0, 1.0);
                      },
                      tooltip: 'Zoom In',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.zoomOut, size: 18, color: Colors.white),
                      onPressed: () {
                        _transformController.value = Matrix4.copy(_transformController.value)..scaleByDouble(0.8, 0.8, 1.0, 1.0);
                      },
                      tooltip: 'Zoom Out',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.rotateCcw, size: 18, color: Colors.white),
                      onPressed: () {
                        _transformController.value = Matrix4.identity();
                      },
                      tooltip: 'Reset Zoom',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationTable(int needsReviewCount, int validCount) {
    final displayedRecords = _records.where((r) {
      if (_filterMode == 'review') return r.requiresReview;
      if (_filterMode == 'valid') return !r.requiresReview;
      return true;
    }).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Status Summary Row (Responsive LayoutBuilder)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extracted Roster Records (${_records.length})',
                    style: AppTypography.cardHeading,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Edit fields directly in table cells. Rows in amber require format review.',
                    style: AppTypography.bodyMuted,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );

              final actionSection = Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_records.isNotEmpty) ...[
                    // Filter Mode Segments
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(value: 'all', label: Text('All (${_records.length})', style: const TextStyle(fontSize: 11))),
                        ButtonSegment(
                          value: 'review',
                          label: Text(
                            'Review ($needsReviewCount)',
                            style: TextStyle(
                              fontSize: 11,
                              color: needsReviewCount > 0 ? AppColors.pillarEmployment : null,
                              fontWeight: needsReviewCount > 0 ? FontWeight.w700 : null,
                            ),
                          ),
                        ),
                        ButtonSegment(value: 'valid', label: Text('Valid ($validCount)', style: const TextStyle(fontSize: 11))),
                      ],
                      selected: {_filterMode},
                      onSelectionChanged: (val) => setState(() => _filterMode = val.first),
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: _autoFormatAll,
                      icon: const Icon(LucideIcons.sparkles, size: 13),
                      label: const Text('Auto-Format', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],

                  OutlinedButton.icon(
                    onPressed: _addNewRow,
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text('Add Row', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),

                  if (_records.isNotEmpty)
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusDanger),
                      tooltip: 'Clear All',
                      onPressed: _clearAllRecords,
                    ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 10),
                    actionSection,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleSection),
                  const SizedBox(width: 8),
                  actionSection,
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Scrollable Verification DataTable or Empty State
          Expanded(
            child: _records.isEmpty
                ? UiEmptyState(
                    icon: LucideIcons.table,
                    iconSize: 32,
                    title: 'No Records Loaded',
                    message: 'Select a physical attendance sheet photo, upload a student spreadsheet, or load demo sample data to start verification.',
                    actionLabel: 'Load Demo Sample',
                    actionIcon: LucideIcons.sparkles,
                    onAction: _loadDemoOcrSample,
                    secondaryActionLabel: 'Upload Excel',
                    onSecondaryAction: _pickAndProcessSpreadsheet,
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text('#')),
                              DataColumn(label: Text('Student Name')),
                              DataColumn(label: Text('Roll Number')),
                              DataColumn(label: Text('CNIC / B-Form')),
                              DataColumn(label: Text('Department')),
                              DataColumn(label: Text('Role / Designation')),
                              DataColumn(label: Text('Routing Target')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: List.generate(displayedRecords.length, (idx) {
                              final record = displayedRecords[idx];
                              final hasWarning = record.requiresReview;

                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (states) => hasWarning ? const Color(0xFFFFF7ED) : null,
                                ),
                                cells: [
                                  DataCell(Text('${idx + 1}', style: AppTypography.bodyMuted)),
                                  // Name Field
                                  DataCell(
                                    SizedBox(
                                      width: 140,
                                      child: TextFormField(
                                        initialValue: record.name,
                                        style: AppTypography.body,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        onChanged: (v) => record.name = v,
                                      ),
                                    ),
                                  ),
                                  // Roll Number Field
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: TextFormField(
                                        initialValue: record.rollNo,
                                        style: AppTypography.mono,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixIcon: record.isRollValid
                                              ? null
                                              : const Icon(LucideIcons.alertCircle, size: 14, color: AppColors.statusWarning),
                                        ),
                                        onChanged: (v) {
                                          record.rollNo = v;
                                          final regex = RegExp(r'^(FA|SP)\d{2}-[A-Z]{2,4}-\d{2,4}$', caseSensitive: false);
                                          setState(() => record.isRollValid = regex.hasMatch(v));
                                        },
                                      ),
                                    ),
                                  ),
                                  // CNIC Field
                                  DataCell(
                                    SizedBox(
                                      width: 140,
                                      child: TextFormField(
                                        initialValue: record.cnic,
                                        style: AppTypography.mono,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixIcon: record.isCnicValid
                                              ? null
                                              : const Icon(LucideIcons.alertCircle, size: 14, color: AppColors.statusWarning),
                                        ),
                                        onChanged: (v) {
                                          record.cnic = v;
                                          final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
                                          setState(() => record.isCnicValid = regex.hasMatch(v));
                                        },
                                      ),
                                    ),
                                  ),
                                  // Department Field
                                  DataCell(
                                    SizedBox(
                                      width: 130,
                                      child: TextFormField(
                                        initialValue: record.department,
                                        style: AppTypography.body,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        onChanged: (v) => record.department = v,
                                      ),
                                    ),
                                  ),
                                  // Role / Designation Field
                                  DataCell(
                                    SizedBox(
                                      width: 140,
                                      child: TextFormField(
                                        initialValue: record.role,
                                        style: AppTypography.body,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          hintText: 'Member / Role',
                                          suffixIcon: record.isExecutive
                                              ? const Tooltip(
                                                  message: 'Executive Title — Routes to Cabinet Hierarchy',
                                                  child: Icon(LucideIcons.crown, size: 14, color: AppColors.pillarEmployment),
                                                )
                                              : null,
                                        ),
                                        onChanged: (v) {
                                          setState(() => record.role = v);
                                        },
                                      ),
                                    ),
                                  ),
                                  // Routing Target Badge Cell
                                  DataCell(
                                    record.isExecutive
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.pillarEmployment.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.pillarEmployment.withOpacity(0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(LucideIcons.crown, size: 12, color: AppColors.pillarEmployment),
                                                SizedBox(width: 4),
                                                Text('Cabinet', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.pillarEmployment)),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.pillarEducation.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.pillarEducation.withOpacity(0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(LucideIcons.user, size: 12, color: AppColors.pillarEducation),
                                                SizedBox(width: 4),
                                                Text('Enrolled', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.pillarEducation)),
                                              ],
                                            ),
                                          ),
                                  ),
                                  // Status Cell
                                  DataCell(
                                    record.requiresReview
                                        ? const Tooltip(
                                            message: 'Invalid CNIC or Roll No format',
                                            child: Icon(LucideIcons.alertCircle, size: 18, color: AppColors.pillarEmployment),
                                          )
                                        : const Tooltip(
                                            message: 'Valid record',
                                            child: Icon(LucideIcons.checkCircle2, size: 18, color: AppColors.pillarEnvironment),
                                          ),
                                  ),
                                  // Actions Cell
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusDanger),
                                      onPressed: () => _deleteRow(_records.indexOf(record)),
                                      tooltip: 'Delete Row',
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
