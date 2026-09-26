import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/ui_state_widgets.dart';
import '../../../events/presentation/widgets/event_detail_dialog.dart';
import '../../../events/presentation/widgets/register_event_dialog.dart';
import '../state/unified_roster_provider.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  final AppDatabase database;

  const RecordsScreen({super.key, required this.database});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  String _searchQuery = '';
  String _selectedPillarFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Preload records via Riverpod notifier
    Future.microtask(() {
      if (mounted) {
        ref.read(recordsDashboardProvider(widget.database).notifier).loadAllRecords();
      }
    });
  }

  Future<void> _deleteRecord(UnifiedInstitutionalRecord record) async {
    final isExec = record.isExecutive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isExec ? 'Remove Cabinet Officer' : 'Delete Student Record'),
        content: Text(
          isExec
              ? 'Permanently remove "${record.fullName}" (${record.role}) from the society cabinet?'
              : 'Permanently remove "${record.fullName}" (${record.identifier}) from the institutional archive?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: Text(isExec ? 'Remove Officer' : 'Delete Record'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(recordsDashboardProvider(widget.database).notifier).deleteRecord(record);
      if (mounted) {
        UiNotification.info(context, '${isExec ? 'Cabinet officer' : 'Student'} "${record.fullName}" removed from archive.');
      }
    }
  }

  Future<void> _deleteFinancialRecord(FinancialRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Financial Record'),
        content: Text('Delete ledger voucher "${record.title}" (Rs. ${record.amount.toStringAsFixed(0)})?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: const Text('Delete Voucher'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(recordsDashboardProvider(widget.database).notifier).deleteFinancialRecord(record);
      if (mounted) {
        UiNotification.info(context, 'Ledger voucher "${record.title}" removed.');
      }
    }
  }

  void _showAddStudentRecordDialog() {
    final recordsState = ref.read(recordsDashboardProvider(widget.database));
    final socList = recordsState.societiesMap.values.toList();
    if (socList.isEmpty) {
      UiNotification.error(context, 'Please register at least one society first in the Societies section.');
      return;
    }
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final cnicCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Computer Science');
    final semCtrl = TextEditingController(text: '4');
    final phoneCtrl = TextEditingController();
    String selectedSocId = socList.first.id;
    String? nameError;
    String? rollError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(LucideIcons.userPlus, size: 20, color: AppColors.pillarEnvironment),
              SizedBox(width: 8),
              Text('Register Student Roster Record', style: AppTypography.cardHeading),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (context) {
                      final uniqueSocList = <String, Society>{for (var s in socList) s.id: s}.values.toList();
                      final validIds = uniqueSocList.map((s) => s.id).toSet();
                      final effectiveSocId = validIds.contains(selectedSocId)
                          ? selectedSocId
                          : (validIds.isNotEmpty ? validIds.first : null);

                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: effectiveSocId,
                        decoration: const InputDecoration(labelText: 'Affiliated Chapter / Society'),
                        items: uniqueSocList
                            .map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.pillar})', overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedSocId = v);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Student Full Name *',
                      errorText: nameError,
                    ),
                    onChanged: (v) {
                      if (nameError != null && v.trim().isNotEmpty) {
                        setDialogState(() => nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: rollCtrl,
                          decoration: InputDecoration(
                            labelText: 'Roll Number *',
                            hintText: 'e.g. FA22-BCS-001',
                            errorText: rollError,
                          ),
                          onChanged: (v) {
                            if (rollError != null && v.trim().isNotEmpty) {
                              setDialogState(() => rollError = null);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: cnicCtrl,
                          decoration: const InputDecoration(
                            labelText: 'CNIC / B-Form',
                            hintText: '13101-xxxxxxx-x',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: deptCtrl,
                          decoration: const InputDecoration(labelText: 'Department'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: semCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Semester'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Contact Phone / WhatsApp', hintText: '03xx-xxxxxxx'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final roll = rollCtrl.text.trim();

                      if (name.isEmpty) {
                        setDialogState(() => nameError = 'Full name is required');
                        return;
                      }
                      if (roll.isEmpty) {
                        setDialogState(() => rollError = 'Roll number is required');
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      final sem = int.tryParse(semCtrl.text.trim()) ?? 1;

                      await ref.read(recordsDashboardProvider(widget.database).notifier).registerStudentRecord(
                            societyId: selectedSocId,
                            fullName: name,
                            rollNo: roll,
                            cnic: cnicCtrl.text.trim().isEmpty ? '13101-0000000-0' : cnicCtrl.text.trim(),
                            department: deptCtrl.text.trim().isEmpty ? 'General' : deptCtrl.text.trim(),
                            semester: sem,
                            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                          );

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (mounted) {
                        UiNotification.success(context, 'Student "$name" registered into society roster.');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Register Student'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFinancialDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final sponsorCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedType = 'Expense';
    String? titleError;
    String? amountError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(LucideIcons.receipt, size: 20, color: AppColors.pillarEmployment),
              SizedBox(width: 8),
              Text('Record Financial Transaction Voucher', style: AppTypography.cardHeading),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Transaction / Voucher Title *',
                      hintText: 'e.g. Main Stage Audio Setup & Logistics',
                      errorText: titleError,
                    ),
                    onChanged: (v) {
                      if (titleError != null && v.trim().isNotEmpty) {
                        setDialogState(() => titleError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(labelText: 'Classification *'),
                          items: const [
                            DropdownMenuItem(value: 'Expense', child: Text('Expense (Disbursement)')),
                            DropdownMenuItem(value: 'Sponsorship', child: Text('Sponsorship Inflow')),
                            DropdownMenuItem(value: 'Grant', child: Text('HEC / External Grant')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => selectedType = v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount (PKR) *',
                            hintText: 'e.g. 45000',
                            errorText: amountError,
                          ),
                          onChanged: (v) {
                            if (amountError != null && v.trim().isNotEmpty) {
                              setDialogState(() => amountError = null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sponsorCtrl,
                    decoration: InputDecoration(
                      labelText: selectedType == 'Expense' ? 'Payee / Vendor / Purpose' : 'Sponsor / Grant Agency *',
                      hintText: selectedType == 'Expense' ? 'e.g. Abbottabad Sound & Lightings' : 'e.g. Bank of Khyber / HEC',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Audit Notes / Approver Reference',
                      hintText: 'Approved by Director YDC AUST',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final title = titleCtrl.text.trim();
                      final amtStr = amountCtrl.text.trim();
                      final amount = double.tryParse(amtStr);

                      if (title.isEmpty) {
                        setDialogState(() => titleError = 'Title is required');
                        return;
                      }
                      if (amount == null || amount <= 0) {
                        setDialogState(() => amountError = 'Enter a valid amount');
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      await ref.read(recordsDashboardProvider(widget.database).notifier).recordFinancialTransaction(
                            title: title,
                            amount: amount,
                            type: selectedType,
                            sponsorName: sponsorCtrl.text.trim().isEmpty ? null : sponsorCtrl.text.trim(),
                            notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                          );

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (mounted) {
                        UiNotification.success(context, 'Transaction voucher "$title" recorded!');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Voucher'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegisterEventDialog() {
    showDialog(
      context: context,
      builder: (ctx) => RegisterEventDialog(
        database: widget.database,
        onEventSaved: () {
          ref.read(recordsDashboardProvider(widget.database).notifier).loadAllRecords();
        },
      ),
    );
  }

  void _generateAndPreviewDossier() {
    Uint8List? cachedBytes;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 950,
            height: 780,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.fileText, color: AppColors.pillarEnvironment, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Master Institutional Monthly Audit Dossier — A4 Preview', style: AppTypography.cardHeading),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.pillarEnvironment.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.pillarEnvironment.withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.shieldCheck, size: 12, color: AppColors.pillarEnvironment),
                                    SizedBox(width: 4),
                                    Text(
                                      'AES-256-GCM Vault Auto-Archiving Active',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.pillarEnvironment,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.brandPurple.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Master Category: Monthly Audits',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PdfPreview(
                    build: (format) async {
                      if (cachedBytes != null) return cachedBytes!;
                      final bytes = await ref
                          .read(recordsDashboardProvider(widget.database).notifier)
                          .generateMonthlyAuditDossier();
                      cachedBytes = bytes;
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            UiNotification.success(
                              context,
                              'Master Monthly Audit Dossier compiled, encrypted via AES-256-GCM, and sealed into Confidential Vault!',
                            );
                          }
                        });
                      }
                      return bytes;
                    },
                    allowPrinting: true,
                    allowSharing: true,
                    canChangePageFormat: false,
                    initialPageFormat: PdfPageFormat.a4,
                    pdfFileName: 'YDC_Master_Monthly_Audit_${DateFormat('MM_yyyy').format(DateTime.now())}.pdf',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final recordsState = ref.watch(recordsDashboardProvider(widget.database));

    final filteredRecords = recordsState.records.where((r) {
      final soc = recordsState.societiesMap[r.societyId];
      final matchesPillar = _selectedPillarFilter == 'All' ||
          (soc != null && soc.pillar.toLowerCase() == _selectedPillarFilter.toLowerCase());
      if (!matchesPillar) return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.fullName.toLowerCase().contains(q) ||
          r.identifier.toLowerCase().contains(q) ||
          r.cnic.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q) ||
          r.role.toLowerCase().contains(q) ||
          (soc?.name.toLowerCase().contains(q) ?? false);
    }).toList();

    final studentCount = recordsState.records.where((r) => !r.isExecutive).length;
    final cabinetCount = recordsState.records.where((r) => r.isExecutive).length;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: recordsState.isLoading
          ? const UiLoadingState(message: 'Loading Institutional Archives & Financial Ledger...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header (Responsive LayoutBuilder)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 680;

                      final titleSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('All Records & Institutional Intelligence', style: AppTypography.heading1),
                          const SizedBox(height: 2),
                          Text('${recordsState.records.length} institutional members ($studentCount enrolled students, $cabinetCount cabinet officers) across ${recordsState.societiesMap.length} societies.', style: AppTypography.bodyMuted),
                        ],
                      );

                      final actionButtons = Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _showAddStudentRecordDialog,
                            icon: const Icon(LucideIcons.userPlus, size: 16),
                            label: const Text('Register Student'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _generateAndPreviewDossier,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pillarEnvironment,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            icon: const Icon(LucideIcons.fileText, size: 16),
                            label: const Text('Generate Dossier (PDF)'),
                          ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleSection,
                            const SizedBox(height: 12),
                            actionButtons,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: titleSection),
                          const SizedBox(width: 12),
                          actionButtons,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Search & Pillar Filter Toolbar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 750;

                        final searchField = TextField(
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          decoration: InputDecoration(
                            hintText: 'Search by Name, Roll No / Office ID, Role (President/General Secretary), CNIC, or Dept...',
                            prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(LucideIcons.x, size: 16),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        );

                        final filterPills = SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Education', 'Employment', 'Engagement', 'Environment'].map((pillar) {
                              final isSelected = _selectedPillarFilter == pillar;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(pillar),
                                  selected: isSelected,
                                  selectedColor: AppColors.pillarEmployment.withOpacity(0.15),
                                  backgroundColor: AppColors.surfaceBg,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.pillarEmployment : AppColors.textDark,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.pillarEmployment : AppColors.borderSubtle,
                                  ),
                                  onSelected: (_) => setState(() => _selectedPillarFilter = pillar),
                                ),
                              );
                            }).toList(),
                          ),
                        );

                        final badge = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            '${filteredRecords.length} Institutional Records',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textDark),
                          ),
                        );

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              searchField,
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: filterPills),
                                  const SizedBox(width: 8),
                                  badge,
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(flex: 5, child: searchField),
                            const SizedBox(width: 12),
                            Expanded(flex: 5, child: filterPills),
                            const SizedBox(width: 12),
                            badge,
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 1. Master Enrollment Table or Empty State
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: filteredRecords.isEmpty
                          ? UiEmptyState(
                              icon: LucideIcons.users,
                              title: _searchQuery.isNotEmpty ? 'No Matching Records' : 'No Institutional Records',
                              message: _searchQuery.isNotEmpty
                                  ? 'No records match "$_searchQuery". Check your spelling or clear filters.'
                                  : 'No students or cabinet members registered under the $_selectedPillarFilter pillar yet.',
                              actionLabel: _searchQuery.isNotEmpty ? 'Clear Search' : 'Register Student',
                              actionIcon: _searchQuery.isNotEmpty ? LucideIcons.x : LucideIcons.userPlus,
                              onAction: _searchQuery.isNotEmpty
                                  ? () => setState(() => _searchQuery = '')
                                  : _showAddStudentRecordDialog,
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                columns: const [
                                  DataColumn(label: Text('#')),
                                  DataColumn(label: Text('Full Name')),
                                  DataColumn(label: Text('Role / Designation')),
                                  DataColumn(label: Text('Roll No / Identifier')),
                                  DataColumn(label: Text('CNIC / B-Form')),
                                  DataColumn(label: Text('Associated Society')),
                                  DataColumn(label: Text('Pillar')),
                                  DataColumn(label: Text('Department')),
                                  DataColumn(label: Text('Semester')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: List.generate(filteredRecords.length, (i) {
                                  final r = filteredRecords[i];
                                  final soc = recordsState.societiesMap[r.societyId];
                                  final pillar = soc?.pillar ?? 'Education';
                                  final pillarColor = AppColors.getPillarColor(pillar);

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${i + 1}', style: AppTypography.bodyMuted)),
                                      DataCell(Text(r.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                      DataCell(
                                        r.isExecutive
                                            ? Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(LucideIcons.shieldCheck, size: 12, color: Color(0xFF334155)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      r.role,
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF8FAFC),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(LucideIcons.user, size: 12, color: Color(0xFF64748B)),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Student',
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                      DataCell(Text(r.identifier, style: AppTypography.mono)),
                                      DataCell(Text(r.cnic, style: AppTypography.mono)),
                                      DataCell(Text(soc?.name ?? 'General YDC')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: pillarColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            pillar,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: pillarColor),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(r.department)),
                                      DataCell(Text('Sem ${r.semester}')),
                                      DataCell(
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: r.isExecutive ? const Color(0xFF0D6EFD) : AppColors.pillarEnvironment,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              r.isExecutive ? 'Cabinet' : 'Enrolled',
                                              style: TextStyle(
                                                color: r.isExecutive ? const Color(0xFF0D6EFD) : AppColors.pillarEnvironment,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.statusDanger),
                                          tooltip: r.isExecutive ? 'Remove Cabinet Officer' : 'Delete Student Record',
                                          onPressed: () => _deleteRecord(r),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Financial Ledgers Overview
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly Institutional Financial Audit Ledger', style: AppTypography.cardHeading),
                            SizedBox(height: 2),
                            Text('Audited vouchers, allocations, sponsorships and grants.', style: AppTypography.bodyMuted),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddFinancialDialog,
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: const Text('Record Transaction'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: recordsState.financialRecords.isEmpty
                          ? UiEmptyState(
                              icon: LucideIcons.receipt,
                              title: 'No Financial Vouchers Recorded',
                              message: 'No expenditure or sponsorship transactions logged for this fiscal period.',
                              actionLabel: 'Record Transaction',
                              actionIcon: LucideIcons.plus,
                              onAction: _showAddFinancialDialog,
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                columns: const [
                                  DataColumn(label: Text('Transaction Title')),
                                  DataColumn(label: Text('Classification')),
                                  DataColumn(label: Text('Amount (PKR)')),
                                  DataColumn(label: Text('Sponsor / Grant Agency')),
                                  DataColumn(label: Text('Notes')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: recordsState.financialRecords.map((f) {
                                  final isExpense = f.type == 'Expense';
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(f.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isExpense ? AppColors.statusDanger.withOpacity(0.1) : AppColors.statusSuccess.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            f.type,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isExpense ? AppColors.statusDanger : AppColors.statusSuccess,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          currencyFmt.format(f.amount),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: isExpense ? AppColors.statusDanger : AppColors.statusSuccess,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(f.sponsorName ?? 'Institutional Allocation')),
                                      DataCell(Text(f.notes ?? '-', style: AppTypography.bodyMuted)),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.statusDanger),
                                          tooltip: 'Delete Voucher',
                                          onPressed: () => _deleteFinancialRecord(f),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Monthly Events & Activities Audit Section
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly Events & Activities Audit', style: AppTypography.cardHeading),
                            SizedBox(height: 2),
                            Text('Summary of institutional events, workshops, seminars, and student engagements conducted this month.', style: AppTypography.bodyMuted),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showRegisterEventDialog,
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: const Text('Register Event'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          '${recordsState.monthlyEvents.length} Events Logged',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textDark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: recordsState.monthlyEvents.isEmpty
                          ? UiEmptyState(
                              icon: LucideIcons.calendarCheck,
                              title: 'No Events Recorded This Month',
                              message: 'No institutional events, workshops, or activities occurred during the current month.',
                              actionLabel: 'Register Event',
                              actionIcon: LucideIcons.plus,
                              onAction: _showRegisterEventDialog,
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                columns: const [
                                  DataColumn(label: Text('#')),
                                  DataColumn(label: Text('Event Title')),
                                  DataColumn(label: Text('Host Society')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Total Attendees')),
                                  DataColumn(label: Text('Financial Summary (Budget vs. Expense)')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: List.generate(recordsState.monthlyEvents.length, (i) {
                                  final item = recordsState.monthlyEventsWithSocieties.length > i
                                      ? recordsState.monthlyEventsWithSocieties[i]
                                      : null;
                                  final evt = item?.event ?? recordsState.monthlyEvents[i];
                                  final soc = item?.society ?? recordsState.societiesMap[evt.societyId];
                                  final pillar = item?.pillar ?? soc?.pillar ?? 'Education';
                                  final pillarColor = AppColors.getPillarColor(pillar);
                                  final dateStr = DateFormat('dd MMM yyyy').format(evt.eventDate);
                                  final isOverBudget = evt.actualExpense > evt.allocatedBudget;

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${i + 1}', style: AppTypography.bodyMuted)),
                                      DataCell(
                                        Text(
                                          evt.title,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: pillarColor.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                pillar,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: pillarColor),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  soc?.name ?? (evt.collaboratorNames != null && evt.collaboratorNames!.trim().isNotEmpty
                                                      ? evt.collaboratorNames!
                                                      : 'Directorate of YDC'),
                                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                                if (soc?.acronym != null && soc!.acronym!.trim().isNotEmpty)
                                                  Text(
                                                    soc.acronym!.trim(),
                                                    style: AppTypography.bodyMuted,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.calendar, size: 13, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(dateStr, style: AppTypography.mono),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.users, size: 13, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${evt.attendeesCount} Attendees',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Budget: ${currencyFmt.format(evt.allocatedBudget)}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                            ),
                                            Text(
                                              'Expense: ${currencyFmt.format(evt.actualExpense)}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isOverBudget ? AppColors.statusDanger : AppColors.statusSuccess,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.statusSuccess.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.statusSuccess.withOpacity(0.3)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(LucideIcons.checkCircle2, size: 11, color: AppColors.statusSuccess),
                                              SizedBox(width: 4),
                                              Text(
                                                'Concluded',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.statusSuccess),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(LucideIcons.eye, size: 16, color: AppColors.pillarEmployment),
                                          tooltip: 'View Event Audit Record',
                                          onPressed: () {
                                            EventDetailDialog.show(
                                              context,
                                              event: evt,
                                              society: soc,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
