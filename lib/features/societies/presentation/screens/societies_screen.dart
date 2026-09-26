import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/reporting/pdf_dossier_service.dart';
import '../../../../core/widgets/ui_state_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../events/presentation/widgets/register_event_dialog.dart';
import '../../../vault/presentation/state/vault_provider.dart';

class SocietiesScreen extends ConsumerStatefulWidget {
  final AppDatabase database;
  final VoidCallback onTriggerIngestion;
  final VoidCallback? onEventPosted;

  const SocietiesScreen({
    super.key,
    required this.database,
    required this.onTriggerIngestion,
    this.onEventPosted,
  });

  @override
  ConsumerState<SocietiesScreen> createState() => _SocietiesScreenState();
}

class _SocietiesScreenState extends ConsumerState<SocietiesScreen> {
  String _selectedPillarFilter = 'All';
  String _searchQuery = '';
  Society? _selectedSociety;
  List<Society> _societies = [];
  List<CabinetMember> _cabinet = [];
  List<SocietyMember> _members = [];
  List<Event> _societyEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSocieties();
  }

  Future<void> _loadSocieties() async {
    setState(() => _isLoading = true);
    try {
      final all = await widget.database.select(widget.database.societies).get();
      if (mounted) {
        setState(() {
          _societies = all;
          if (_selectedSociety == null && all.isNotEmpty) {
            _selectedSociety = all.first;
          } else if (_selectedSociety != null) {
            final matched = all.where((s) => s.id == _selectedSociety!.id).firstOrNull;
            _selectedSociety = matched ?? (all.isNotEmpty ? all.first : null);
          }
          _isLoading = false;
        });
        if (_selectedSociety != null) {
          _loadSocietyDetails(_selectedSociety!.id);
        } else {
          setState(() {
            _cabinet = [];
            _members = [];
            _societyEvents = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiNotification.error(context, 'Failed to load societies: $e');
      }
    }
  }

  Future<void> _loadSocietyDetails(String societyId) async {
    try {
      final cab = await (widget.database.select(widget.database.cabinetMembers)
            ..where((tbl) => tbl.societyId.equals(societyId)))
          .get();
      final mems = await (widget.database.select(widget.database.societyMembers)
            ..where((tbl) => tbl.societyId.equals(societyId)))
          .get();
      final evts = await (widget.database.select(widget.database.events)
            ..where((tbl) => tbl.societyId.equals(societyId))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.eventDate)]))
          .get();

      if (mounted) {
        setState(() {
          _cabinet = cab;
          _members = mems;
          _societyEvents = evts;
        });
      }
    } catch (e) {
      if (mounted) {
        UiNotification.error(context, 'Failed to load chapter roster: $e');
      }
    }
  }

  void _showAddSocietyDialog() {
    final nameCtrl = TextEditingController();
    final acronymCtrl = TextEditingController();
    final advisorCtrl = TextEditingController();
    String selectedPillar = 'Education';
    String? selectedLogoPath;
    String? nameError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(LucideIcons.building2, size: 20, color: AppColors.pillarEnvironment),
              SizedBox(width: 8),
              Text('Register New AUST Society', style: AppTypography.cardHeading),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Society Full Name *',
                      hintText: 'e.g. Computer Science Tech Innovation Guild',
                      errorText: nameError,
                    ),
                    onChanged: (val) {
                      if (nameError != null && val.trim().isNotEmpty) {
                        setDialogState(() => nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: acronymCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Acronym',
                            hintText: 'e.g. CSTIG',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedPillar,
                          decoration: const InputDecoration(labelText: 'YDC Strategic Pillar'),
                          items: ['Education', 'Employment', 'Engagement', 'Environment']
                              .map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) => setDialogState(() => selectedPillar = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: advisorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Faculty Advisor / Patron',
                      hintText: 'e.g. Dr. Muhammad Asif',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Society Logo Upload Option
                  const Text('Society Crest / Official Logo:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: selectedLogoPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.file(
                                    File(selectedLogoPath!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(LucideIcons.image, size: 20, color: AppColors.textMuted),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(LucideIcons.image, size: 22, color: AppColors.textMuted),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLogoPath != null ? 'Logo Selected' : 'Upload Society Logo',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedLogoPath != null
                                    ? selectedLogoPath!.split(Platform.pathSeparator).last
                                    : 'Pick PNG, JPG, or WEBP image',
                                style: AppTypography.bodyMuted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
                                    dialogTitle: 'Select Society Logo Image',
                                  );
                                  if (result != null && result.files.single.path != null) {
                                    setDialogState(() {
                                      selectedLogoPath = result.files.single.path;
                                    });
                                  }
                                },
                          icon: const Icon(LucideIcons.uploadCloud, size: 14),
                          label: Text(selectedLogoPath != null ? 'Change' : 'Upload'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (selectedLogoPath != null) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 16, color: AppColors.statusDanger),
                            tooltip: 'Remove Logo',
                            onPressed: () => setDialogState(() => selectedLogoPath = null),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        setDialogState(() {
                          nameError = 'Please enter society full name';
                        });
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      final newId = const Uuid().v4();
                      await widget.database.into(widget.database.societies).insert(
                        SocietiesCompanion.insert(
                          id: newId,
                          name: name,
                          acronym: Value(acronymCtrl.text.trim().isEmpty ? null : acronymCtrl.text.trim()),
                          pillar: selectedPillar,
                          facultyAdvisor: advisorCtrl.text.trim().isEmpty ? 'Faculty Advisor Pending' : advisorCtrl.text.trim(),
                          logoPath: Value(selectedLogoPath),
                        ),
                      );

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      _loadSocieties();
                      if (mounted) {
                        UiNotification.success(context, 'Society "$name" registered successfully!');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Society'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCabinetDialog() {
    if (_selectedSociety == null) return;
    final nameCtrl = TextEditingController();
    final cnicCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Computer Science');
    final semCtrl = TextEditingController(text: '5');
    final customRoleCtrl = TextEditingController();
    String selectedRole = 'President';
    String? nameError;
    String? roleError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Cabinet Member — ${_selectedSociety!.name}', style: AppTypography.cardHeading),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Mandatory Cabinet Role',
                      errorText: roleError,
                    ),
                    items: const [
                      'President',
                      'Vice President',
                      'General Secretary',
                      'Coordinator',
                      'Media Officer',
                      'Other (Specify Custom Role)',
                    ]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          selectedRole = v;
                          if (v != 'Other (Specify Custom Role)') {
                            roleError = null;
                          }
                        });
                      }
                    },
                  ),
                  if (selectedRole == 'Other (Specify Custom Role)') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: customRoleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Custom Role Title',
                        hintText: 'e.g. Director of Operations, Logistics Head',
                        errorText: roleError,
                      ),
                      onChanged: (v) {
                        if (roleError != null && v.trim().isNotEmpty) {
                          setDialogState(() => roleError = null);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
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
                      Expanded(child: TextField(controller: cnicCtrl, decoration: const InputDecoration(labelText: 'CNIC (XXXXX-XXXXXXX-X)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone (03XX-XXXXXXX)'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Institutional Email')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(flex: 3, child: TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department'))),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: TextField(controller: semCtrl, decoration: const InputDecoration(labelText: 'Semester'))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final customRoleText = customRoleCtrl.text.trim();
                      if (selectedRole == 'Other (Specify Custom Role)' && customRoleText.isEmpty) {
                        setDialogState(() => roleError = 'Please specify the custom role title');
                        return;
                      }

                      if (nameCtrl.text.trim().isEmpty) {
                        setDialogState(() => nameError = 'Please enter member full name');
                        return;
                      }

                      final effectiveRole = selectedRole == 'Other (Specify Custom Role)'
                          ? customRoleText
                          : selectedRole;

                      setDialogState(() => isSubmitting = true);

                      await widget.database.into(widget.database.cabinetMembers).insert(
                        CabinetMembersCompanion.insert(
                          id: const Uuid().v4(),
                          societyId: _selectedSociety!.id,
                          tenureSession: '2025-2026',
                          role: effectiveRole,
                          fullName: nameCtrl.text.trim(),
                          cnic: cnicCtrl.text.trim().isEmpty ? '13101-0000000-0' : cnicCtrl.text.trim(),
                          email: emailCtrl.text.trim().isEmpty ? 'student@aust.edu.pk' : emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim().isEmpty ? '0300-0000000' : phoneCtrl.text.trim(),
                          department: deptCtrl.text.trim(),
                          semester: int.tryParse(semCtrl.text.trim()) ?? 1,
                        ),
                      );

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      _loadSocietyDetails(_selectedSociety!.id);
                      if (mounted) {
                        UiNotification.success(context, 'Cabinet member "${nameCtrl.text.trim()}" added successfully!');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Member'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    if (_selectedSociety == null) return;
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final cnicCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Computer Science');
    final semCtrl = TextEditingController(text: '3');
    final phoneCtrl = TextEditingController();
    String? nameError;
    String? rollError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Register Student Member — ${_selectedSociety!.name}', style: AppTypography.cardHeading),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                            labelText: 'Roll No (FA22-BCS-010) *',
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
                      Expanded(child: TextField(controller: cnicCtrl, decoration: const InputDecoration(labelText: 'CNIC (XXXXX-XXXXXXX-X)'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(flex: 3, child: TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department'))),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: TextField(controller: semCtrl, decoration: const InputDecoration(labelText: 'Semester'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number (Optional)')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final roll = rollCtrl.text.trim();
                      if (name.isEmpty || roll.isEmpty) {
                        setDialogState(() {
                          if (name.isEmpty) nameError = 'Name required';
                          if (roll.isEmpty) rollError = 'Roll No required';
                        });
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      await widget.database.into(widget.database.societyMembers).insert(
                        SocietyMembersCompanion.insert(
                          id: const Uuid().v4(),
                          societyId: _selectedSociety!.id,
                          fullName: name,
                          rollNo: roll.toUpperCase(),
                          cnic: cnicCtrl.text.trim().isEmpty ? '13101-0000000-0' : cnicCtrl.text.trim(),
                          department: deptCtrl.text.trim(),
                          semester: int.tryParse(semCtrl.text.trim()) ?? 1,
                          phone: Value(phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()),
                        ),
                      );

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      _loadSocietyDetails(_selectedSociety!.id);
                      if (mounted) {
                        UiNotification.success(context, 'Student "$name" enrolled successfully!');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Register Member'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSociety(Society soc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.statusDanger, size: 22),
            SizedBox(width: 10),
            Text('Confirm Deletion', style: AppTypography.cardHeading),
          ],
        ),
        content: Text('Are you sure you want to delete "${soc.name}"? All associated cabinet records and student rosters will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: const Text('Delete Society'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await (widget.database.delete(widget.database.societies)..where((t) => t.id.equals(soc.id))).go();
      setState(() {
        if (_selectedSociety?.id == soc.id) {
          _selectedSociety = null;
        }
      });
      _loadSocieties();
      if (mounted) {
        UiNotification.info(context, 'Society "${soc.name}" deleted.');
      }
    }
  }

  Future<void> _updateSocietyLogo(Society soc) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
      dialogTitle: 'Select Logo for "${soc.name}"',
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await (widget.database.update(widget.database.societies)..where((t) => t.id.equals(soc.id))).write(
        SocietiesCompanion(logoPath: Value(path)),
      );
      _loadSocieties();
      if (mounted) {
        UiNotification.success(context, 'Logo updated for "${soc.name}"!');
      }
    }
  }

  Widget _buildSocietyAvatar(Society soc, {double size = 38, double radius = 10, VoidCallback? onEditLogo}) {
    final pillarColor = AppColors.getPillarColor(soc.pillar);

    Widget inner;
    if (soc.logoPath != null && soc.logoPath!.isNotEmpty) {
      if (soc.logoPath!.startsWith('assets/')) {
        inner = Image.asset(
          soc.logoPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarFallback(soc, pillarColor, size),
        );
      } else {
        final file = File(soc.logoPath!);
        if (file.existsSync()) {
          inner = Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _avatarFallback(soc, pillarColor, size),
          );
        } else {
          inner = _avatarFallback(soc, pillarColor, size);
        }
      }
    } else {
      inner = _avatarFallback(soc, pillarColor, size);
    }

    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: pillarColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: inner,
      ),
    );

    if (onEditLogo != null) {
      return Tooltip(
        message: 'Click to upload / change society logo',
        child: InkWell(
          onTap: onEditLogo,
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x22000000), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(LucideIcons.camera, size: 11, color: AppColors.pillarEnvironment),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return avatar;
  }

  Widget _avatarFallback(Society soc, Color pillarColor, double size) {
    final text = soc.acronym != null && soc.acronym!.isNotEmpty
        ? soc.acronym!
        : (soc.name.length >= 2 ? soc.name.substring(0, 2).toUpperCase() : 'SC');
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: size * 0.32,
          color: pillarColor,
        ),
      ),
    );
  }

  Future<void> _deleteCabinetMember(CabinetMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Cabinet Member'),
        content: Text('Remove ${member.fullName} (${member.role}) from the executive cabinet?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedSociety != null) {
      await (widget.database.delete(widget.database.cabinetMembers)..where((t) => t.id.equals(member.id))).go();
      _loadSocietyDetails(_selectedSociety!.id);
      if (mounted) {
        UiNotification.info(context, 'Cabinet member "${member.fullName}" removed.');
      }
    }
  }

  Future<void> _deleteSocietyMember(SocietyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student Member'),
        content: Text('Remove ${member.fullName} (${member.rollNo}) from enrolled members?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedSociety != null) {
      await (widget.database.delete(widget.database.societyMembers)..where((t) => t.id.equals(member.id))).go();
      _loadSocietyDetails(_selectedSociety!.id);
      if (mounted) {
        UiNotification.info(context, 'Student member "${member.fullName}" removed.');
      }
    }
  }

  void _showEditMemberDialog(SocietyMember member) {
    if (_selectedSociety == null) return;
    final nameCtrl = TextEditingController(text: member.fullName);
    final rollCtrl = TextEditingController(text: member.rollNo);
    final cnicCtrl = TextEditingController(text: member.cnic);
    final deptCtrl = TextEditingController(text: member.department);
    final semCtrl = TextEditingController(text: member.semester.toString());
    final phoneCtrl = TextEditingController(text: member.phone ?? '');
    String? nameError;
    String? rollError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(LucideIcons.pencil, size: 18, color: AppColors.brandPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Edit Enrolled Student — ${member.fullName}',
                  style: AppTypography.cardHeading,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                            labelText: 'Roll No (FA22-BCS-010) *',
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
                          decoration: const InputDecoration(labelText: 'CNIC (XXXXX-XXXXXXX-X)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: deptCtrl,
                          decoration: const InputDecoration(labelText: 'Department'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: semCtrl,
                          decoration: const InputDecoration(labelText: 'Semester'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final roll = rollCtrl.text.trim();
                      if (name.isEmpty || roll.isEmpty) {
                        setDialogState(() {
                          if (name.isEmpty) nameError = 'Name required';
                          if (roll.isEmpty) rollError = 'Roll No required';
                        });
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      await (widget.database.update(widget.database.societyMembers)..where((t) => t.id.equals(member.id))).write(
                        SocietyMembersCompanion(
                          fullName: Value(name),
                          rollNo: Value(roll.toUpperCase()),
                          cnic: Value(cnicCtrl.text.trim().isEmpty ? '13101-0000000-0' : cnicCtrl.text.trim()),
                          department: Value(deptCtrl.text.trim()),
                          semester: Value(int.tryParse(semCtrl.text.trim()) ?? member.semester),
                          phone: Value(phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim()),
                        ),
                      );

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      _loadSocietyDetails(_selectedSociety!.id);
                      if (mounted) {
                        UiNotification.success(context, 'Student "$name" updated successfully!');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCabinetDialog(CabinetMember member) {
    if (_selectedSociety == null) return;
    const standardEditRoles = [
      'President',
      'Vice President',
      'General Secretary',
      'Joint Secretary',
      'Finance Secretary',
      'Coordinator',
      'Media Officer',
      'Executive Member',
    ];
    final isCustomInitial = !standardEditRoles.contains(member.role);
    String selectedRole = isCustomInitial ? 'Other (Specify Custom Role)' : member.role;
    final customRoleCtrl = TextEditingController(text: isCustomInitial ? member.role : '');
    final nameCtrl = TextEditingController(text: member.fullName);
    final cnicCtrl = TextEditingController(text: member.cnic);
    final phoneCtrl = TextEditingController(text: member.phone);
    final emailCtrl = TextEditingController(text: member.email);
    final deptCtrl = TextEditingController(text: member.department);
    final semCtrl = TextEditingController(text: member.semester.toString());
    String? nameError;
    String? roleError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(LucideIcons.pencil, size: 18, color: AppColors.brandPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Edit Cabinet Office — ${member.fullName}',
                  style: AppTypography.cardHeading,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Executive Office / Role *',
                      errorText: roleError,
                    ),
                    items: [
                      ...standardEditRoles,
                      'Other (Specify Custom Role)',
                    ]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          selectedRole = v;
                          if (v != 'Other (Specify Custom Role)') {
                            roleError = null;
                          }
                        });
                      }
                    },
                  ),
                  if (selectedRole == 'Other (Specify Custom Role)') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: customRoleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Custom Role Title',
                        hintText: 'e.g. Director of Operations, Logistics Head',
                        errorText: roleError,
                      ),
                      onChanged: (v) {
                        if (roleError != null && v.trim().isNotEmpty) {
                          setDialogState(() => roleError = null);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
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
                      Expanded(child: TextField(controller: cnicCtrl, decoration: const InputDecoration(labelText: 'CNIC (XXXXX-XXXXXXX-X)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone (03XX-XXXXXXX)'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Institutional Email')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(flex: 3, child: TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department'))),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: TextField(controller: semCtrl, decoration: const InputDecoration(labelText: 'Semester'))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final customRoleText = customRoleCtrl.text.trim();
                      if (selectedRole == 'Other (Specify Custom Role)' && customRoleText.isEmpty) {
                        setDialogState(() => roleError = 'Please specify the custom role title');
                        return;
                      }

                      if (nameCtrl.text.trim().isEmpty) {
                        setDialogState(() => nameError = 'Please enter member full name');
                        return;
                      }

                      final effectiveRole = selectedRole == 'Other (Specify Custom Role)'
                          ? customRoleText
                          : selectedRole;

                      setDialogState(() => isSubmitting = true);

                      await (widget.database.update(widget.database.cabinetMembers)..where((t) => t.id.equals(member.id))).write(
                        CabinetMembersCompanion(
                          role: Value(effectiveRole),
                          fullName: Value(nameCtrl.text.trim()),
                          cnic: Value(cnicCtrl.text.trim().isEmpty ? '13101-0000000-0' : cnicCtrl.text.trim()),
                          email: Value(emailCtrl.text.trim().isEmpty ? member.email : emailCtrl.text.trim()),
                          phone: Value(phoneCtrl.text.trim().isEmpty ? member.phone : phoneCtrl.text.trim()),
                          department: Value(deptCtrl.text.trim()),
                          semester: Value(int.tryParse(semCtrl.text.trim()) ?? member.semester),
                        ),
                      );

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      _loadSocietyDetails(_selectedSociety!.id);
                      if (mounted) {
                        UiNotification.success(context, 'Cabinet member "${nameCtrl.text.trim()}" updated successfully!');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostEventDialog(Society soc) {
    showDialog(
      context: context,
      builder: (ctx) => RegisterEventDialog(
        database: widget.database,
        lockedSociety: soc,
        onEventSaved: () {
          _loadSocietyDetails(soc.id);
          widget.onEventPosted?.call();
        },
      ),
    );
  }

  Future<void> _deleteSocietyEvent(Event evt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.statusDanger, size: 22),
            SizedBox(width: 10),
            Text('Delete Hosted Event', style: AppTypography.cardHeading),
          ],
        ),
        content: Text('Are you sure you want to delete "${evt.title}"? Associated guest speakers will also be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: const Text('Delete Event'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await (widget.database.delete(widget.database.eventSpeakers)..where((tbl) => tbl.eventId.equals(evt.id))).go();
      await (widget.database.delete(widget.database.events)..where((tbl) => tbl.id.equals(evt.id))).go();
      if (_selectedSociety != null) {
        _loadSocietyDetails(_selectedSociety!.id);
      }
      widget.onEventPosted?.call();
      if (mounted) {
        UiNotification.info(context, 'Event "${evt.title}" deleted.');
      }
    }
  }

  Future<void> _generateAndPreviewSocietyDossier() async {
    if (_selectedSociety == null) return;
    final soc = _selectedSociety!;

    int eventCount = 0;
    try {
      final evts = await (widget.database.select(widget.database.events)
            ..where((tbl) => tbl.societyId.equals(soc.id)))
          .get();
      eventCount = evts.length;
    } catch (_) {}

    final dossierData = PdfSocietyDossierData(
      societyName: soc.name,
      acronym: soc.acronym,
      pillar: soc.pillar,
      facultyAdvisor: soc.facultyAdvisor,
      logoPath: soc.logoPath,
      monthYear: DateFormat('MMMM yyyy').format(DateTime.now()),
      cabinet: _cabinet.map((c) => PdfCabinetMemberItem(
        role: c.role,
        fullName: c.fullName,
        cnic: c.cnic,
        department: c.department,
        semester: c.semester,
        phone: c.phone,
      )).toList(),
      members: _members.map((m) => PdfSocietyMemberItem(
        fullName: m.fullName,
        rollNo: m.rollNo,
        cnic: m.cnic,
        department: m.department,
        semester: m.semester,
      )).toList(),
      totalEvents: eventCount,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 900,
          height: 750,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.fileText, color: AppColors.pillarEnvironment, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Official Chapter Performance Dossier — ${soc.name} (A4 Preview)',
                      style: AppTypography.cardHeading,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _finalizeAndArchiveSocietyRoster(soc);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(LucideIcons.shieldCheck, size: 14),
                    label: const Text('Seal to Vault', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PdfPreview(
                  build: (format) => PdfDossierService.generateSocietyDossier(dossierData),
                  allowPrinting: true,
                  allowSharing: true,
                  canChangePageFormat: false,
                  initialPageFormat: PdfPageFormat.a4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finalizeAndArchiveSocietyRoster(Society soc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.shieldCheck, color: AppColors.brandPurple, size: 20),
            SizedBox(width: 8),
            Text('Finalize & Archive Roster', style: AppTypography.cardHeading),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to finalize the session roster for "${soc.name}"?',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Text(
                'This will compile the executive cabinet hierarchy (${_cabinet.length} officers) and student roster (${_members.length} members) into an official chapter dossier, encrypt it with AES-256-GCM, and seal it into the Confidential Institutional Vault as an immutable permanent record.',
                style: AppTypography.bodyMuted,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPurple,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(LucideIcons.shieldCheck, size: 16),
            label: const Text('Finalize & Seal in Vault'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        UiNotification.info(context, 'Compiling and encrypting finalized roster in Vault...');
        final totalEvents = _societyEvents.length;
        await ref.read(vaultProvider(widget.database).notifier).archiveFinalizedRoster(
              society: soc,
              cabinet: _cabinet,
              members: _members,
              totalEvents: totalEvents,
            );
        if (mounted) {
          UiNotification.success(
            context,
            'Finalized session roster for "${soc.name}" encrypted & sealed in Vault!',
          );
        }
      } catch (e) {
        if (mounted) {
          UiNotification.error(context, 'Failed to archive roster to vault: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSocieties = _societies.where((s) {
      final matchesPillar = _selectedPillarFilter == 'All' || s.pillar.toLowerCase() == _selectedPillarFilter.toLowerCase();
      if (!matchesPillar) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          (s.acronym?.toLowerCase().contains(q) ?? false) ||
          s.facultyAdvisor.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: _isLoading
          ? const UiLoadingState(message: 'Loading Institutional Societies & Rosters...')
          : Row(
              children: [
                // Left Panel: Societies List (35% width)
                Expanded(
                  flex: 4,
                  child: _buildSocietiesListPanel(filteredSocieties),
                ),

                // 1px Border Separator
                Container(width: 1, color: AppColors.borderSubtle),

                // Right Panel: Society Detail, Cabinet Hierarchy & Member Ingestion (65% width)
                Expanded(
                  flex: 7,
                  child: _buildSocietyDetailPanel(),
                ),
              ],
            ),
    );
  }

  Widget _buildSocietiesListPanel(List<Society> list) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Top Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 280;

              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Societies & Chapters', style: AppTypography.heading1),
                  const SizedBox(height: 2),
                  Text('${_societies.length} institutional entities', style: AppTypography.bodyMuted),
                ],
              );

              final addBtn = ElevatedButton.icon(
                onPressed: _showAddSocietyDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Society'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 10),
                    addBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleWidget),
                  addBtn,
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Search Box
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search societies, acronyms...',
              prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 15),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),

          const SizedBox(height: 12),

          // Pillar Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Education', 'Employment', 'Engagement', 'Environment'].map((pillar) {
                final isSelected = _selectedPillarFilter == pillar;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(pillar),
                    selected: isSelected,
                    selectedColor: AppColors.pillarEnvironment.withOpacity(0.15),
                    backgroundColor: AppColors.surfaceBg,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.pillarEnvironment : AppColors.textDark,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.pillarEnvironment : AppColors.borderSubtle,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedPillarFilter = pillar);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Societies Card List
          Expanded(
            child: list.isEmpty
                ? UiEmptyState(
                    icon: LucideIcons.building2,
                    iconSize: 28,
                    title: _searchQuery.isNotEmpty ? 'No Matching Societies' : 'No Societies Found',
                    message: _searchQuery.isNotEmpty
                        ? 'No societies match "$_searchQuery". Try clearing your search.'
                        : 'No chapters registered under the $_selectedPillarFilter pillar.',
                    actionLabel: _searchQuery.isNotEmpty ? 'Clear Search' : 'Add Society',
                    actionIcon: _searchQuery.isNotEmpty ? LucideIcons.x : LucideIcons.plus,
                    onAction: _searchQuery.isNotEmpty
                        ? () => setState(() => _searchQuery = '')
                        : _showAddSocietyDialog,
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final soc = list[i];
                      final isSelected = _selectedSociety?.id == soc.id;
                      final pillarColor = AppColors.getPillarColor(soc.pillar);

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedSociety = soc);
                          _loadSocietyDetails(soc.id);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? pillarColor.withOpacity(0.06) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? pillarColor : AppColors.borderSubtle,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildSocietyAvatar(soc, size: 38, radius: 10),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      soc.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${soc.pillar} • ${soc.facultyAdvisor}',
                                      style: AppTypography.bodyMuted,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.statusDanger),
                                tooltip: 'Delete Society',
                                onPressed: () => _deleteSociety(soc),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocietyDetailPanel() {
    if (_selectedSociety == null) {
      return Container(
        color: AppColors.surfaceBg,
        child: UiEmptyState(
          icon: LucideIcons.building,
          title: 'No Society Selected',
          message: 'Select a society from the left panel to inspect its executive cabinet, student roster, or register a new one.',
          actionLabel: 'Register First Society',
          onAction: _showAddSocietyDialog,
        ),
      );
    }

    final soc = _selectedSociety!;
    final pillarColor = AppColors.getPillarColor(soc.pillar);

    return Container(
      color: AppColors.surfaceBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Society Header Card (Never overflows on narrow viewports)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 1000;

                final leftSection = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSocietyAvatar(soc, size: 56, radius: 14, onEditLogo: () => _updateSocietyLogo(soc)),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  soc.name,
                                  style: AppTypography.heading1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: pillarColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  soc.pillar,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pillarColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Patron / Faculty Advisor: ${soc.facultyAdvisor}',
                            style: AppTypography.bodyMuted,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final actionButtons = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _finalizeAndArchiveSocietyRoster(soc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(LucideIcons.shieldCheck, size: 15),
                      label: const Text('Finalize Cabinet & Members'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _generateAndPreviewSocietyDossier,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pillarEnvironment,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(LucideIcons.fileText, size: 15),
                      label: const Text('Generate Society Dossier'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showPostEventDialog(soc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pillarEngagement,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(LucideIcons.calendarPlus, size: 15),
                      label: const Text('Post Event'),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onTriggerIngestion,
                      icon: const Icon(LucideIcons.scanLine, size: 15, color: AppColors.brandPurple),
                      label: const Text('Ingest Roster'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _deleteSociety(soc),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusDanger,
                        side: const BorderSide(color: AppColors.statusDanger),
                      ),
                      icon: const Icon(LucideIcons.trash2, size: 15),
                      label: const Text('Delete'),
                    ),
                  ],
                );

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leftSection,
                            const SizedBox(height: 14),
                            actionButtons,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: leftSection),
                            const SizedBox(width: 12),
                            actionButtons,
                          ],
                        ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Cabinet Hierarchy Section (Tenure 2025-2026)
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cabinet Hierarchy (Tenure 2025–2026)', style: AppTypography.cardHeading),
                      SizedBox(height: 2),
                      Text('Executive office bearers leading the society.', style: AppTypography.bodyMuted),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddCabinetDialog,
                  icon: const Icon(LucideIcons.userPlus, size: 14),
                  label: const Text('Add Cabinet Office'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_cabinet.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: UiEmptyState(
                  icon: LucideIcons.users,
                  iconSize: 30,
                  title: 'No Cabinet Assigned',
                  message: 'Assign executive office bearers (President, General Secretary, etc.) to lead "${soc.name}".',
                  actionLabel: 'Assign Cabinet Office',
                  actionIcon: LucideIcons.userPlus,
                  onAction: _showAddCabinetDialog,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Office / Designation')),
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('CNIC / B-Form')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Semester')),
                        DataColumn(label: Text('Contact Phone')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(_cabinet.length, (i) {
                        final c = _cabinet[i];
                        return DataRow(
                          cells: [
                            DataCell(Text('${i + 1}', style: AppTypography.bodyMuted)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: pillarColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c.role,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pillarColor),
                                ),
                              ),
                            ),
                            DataCell(Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataCell(Text(c.cnic, style: AppTypography.mono)),
                            DataCell(Text(c.department)),
                            DataCell(Text('Sem ${c.semester}')),
                            DataCell(Text(c.phone.isEmpty ? (c.email.isEmpty ? 'N/A' : c.email) : c.phone, style: AppTypography.bodyMuted)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(LucideIcons.pencil, size: 15, color: AppColors.brandPurple),
                                    tooltip: 'Edit Office Bearer',
                                    onPressed: () => _showEditCabinetDialog(c),
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.statusDanger),
                                    tooltip: 'Remove Office Bearer',
                                    onPressed: () => _deleteCabinetMember(c),
                                  ),
                                ],
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

            // General Members Roster Section
            Row(
              children: [
                Expanded(
                  child: Text('Enrolled Student Members (${_members.length})', style: AppTypography.cardHeading),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAddMemberDialog,
                      icon: const Icon(LucideIcons.userPlus, size: 14),
                      label: const Text('Register Member'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onTriggerIngestion,
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('Batch Ingest'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
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
                child: _members.isEmpty
                    ? UiEmptyState(
                        icon: LucideIcons.graduationCap,
                        iconSize: 32,
                        title: 'No Members Enrolled Yet',
                        message: 'No student members have been added to "${soc.name}". Use individual registration or batch OCR / Excel import.',
                        actionLabel: 'Register Member',
                        actionIcon: LucideIcons.userPlus,
                        onAction: _showAddMemberDialog,
                        secondaryActionLabel: 'Batch Ingest',
                        onSecondaryAction: widget.onTriggerIngestion,
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                          columns: const [
                            DataColumn(label: Text('#')),
                            DataColumn(label: Text('Full Name')),
                            DataColumn(label: Text('Roll Number')),
                            DataColumn(label: Text('CNIC / B-Form')),
                            DataColumn(label: Text('Department')),
                            DataColumn(label: Text('Semester')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: List.generate(_members.length, (i) {
                            final m = _members[i];
                            return DataRow(
                              cells: [
                                DataCell(Text('${i + 1}', style: AppTypography.bodyMuted)),
                                DataCell(Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(m.rollNo, style: AppTypography.mono)),
                                DataCell(Text(m.cnic, style: AppTypography.mono)),
                                DataCell(Text(m.department)),
                                DataCell(Text('Sem ${m.semester}')),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.pillarEnvironment, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      const Text('Active', style: TextStyle(color: AppColors.pillarEnvironment, fontWeight: FontWeight.w600, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(LucideIcons.pencil, size: 15, color: AppColors.brandPurple),
                                        tooltip: 'Edit Student',
                                        onPressed: () => _showEditMemberDialog(m),
                                      ),
                                      IconButton(
                                        icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.statusDanger),
                                        tooltip: 'Remove Student',
                                        onPressed: () => _deleteSocietyMember(m),
                                      ),
                                    ],
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

            // Hosted Society Events Section (Upcoming & Past Activities)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hosted Events & Activities (${_societyEvents.length})', style: AppTypography.cardHeading),
                      const SizedBox(height: 2),
                      const Text('Upcoming schedules and past event milestones hosted by this chapter.', style: AppTypography.bodyMuted),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showPostEventDialog(soc),
                  icon: const Icon(LucideIcons.calendarPlus, size: 14),
                  label: const Text('Post Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pillarEngagement,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_societyEvents.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: UiEmptyState(
                  icon: LucideIcons.calendar,
                  iconSize: 30,
                  title: 'No Events Hosted Yet',
                  message: 'No institutional events or activities posted for "${soc.name}". Click "Post Event" to schedule an activity.',
                  actionLabel: 'Post Event',
                  actionIcon: LucideIcons.calendarPlus,
                  onAction: () => _showPostEventDialog(soc),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 720),
                      child: DataTable(
                        headingRowHeight: 40,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 56,
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceBg),
                        columns: const [
                          DataColumn(label: Text('Timeline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                          DataColumn(label: Text('Event Title', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                          DataColumn(label: Text('Venue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                          DataColumn(label: Text('Attendees', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                          DataColumn(label: Text('Budget', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        ],
                        rows: _societyEvents.map((evt) {
                          final isUpcoming = evt.eventDate.isAfter(DateTime.now());
                          final dateStr = DateFormat('MMM dd, yyyy').format(evt.eventDate);
                          final budgetStr = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0).format(evt.allocatedBudget);

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isUpcoming
                                        ? AppColors.pillarEngagement.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isUpcoming ? 'UPCOMING' : 'PAST',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isUpcoming ? AppColors.pillarEngagement : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(evt.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    if (evt.isCollaboration && evt.collaboratorNames != null)
                                      Text('Collab: ${evt.collaboratorNames}', style: const TextStyle(fontSize: 11, color: AppColors.pillarEducation))
                                    else if (evt.description.isNotEmpty)
                                      Text(evt.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyMuted),
                                  ],
                                ),
                              ),
                              DataCell(Text(dateStr, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(evt.venue ?? 'Auditorium', style: const TextStyle(fontSize: 12))),
                              DataCell(Text('${evt.attendeesCount} pax', style: const TextStyle(fontSize: 12))),
                              DataCell(Text(budgetStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                              DataCell(
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 15, color: AppColors.statusDanger),
                                  tooltip: 'Delete Event',
                                  onPressed: () => _deleteSocietyEvent(evt),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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
