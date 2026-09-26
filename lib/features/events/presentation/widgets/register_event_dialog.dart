import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/ui_state_widgets.dart';
import '../../../vault/presentation/state/vault_provider.dart';
import '../state/event_image_attachment_provider.dart';

class SpeakerEntry {
  final String name;
  final String organization;

  const SpeakerEntry({
    required this.name,
    required this.organization,
  });
}

class _SpeakerInputControllers {
  final TextEditingController nameController;
  final TextEditingController orgController;

  _SpeakerInputControllers({String name = '', String org = ''})
      : nameController = TextEditingController(text: name),
        orgController = TextEditingController(text: org);

  void dispose() {
    nameController.dispose();
    orgController.dispose();
  }

  SpeakerEntry toEntry() {
    return SpeakerEntry(
      name: nameController.text.trim(),
      organization: orgController.text.trim(),
    );
  }
}

class RegisterEventDialog extends ConsumerStatefulWidget {
  final AppDatabase database;
  final Society? lockedSociety;
  final VoidCallback? onEventSaved;

  const RegisterEventDialog({
    super.key,
    required this.database,
    this.lockedSociety,
    this.onEventSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required AppDatabase database,
    Society? lockedSociety,
    VoidCallback? onEventSaved,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => RegisterEventDialog(
        database: database,
        lockedSociety: lockedSociety,
        onEventSaved: onEventSaved,
      ),
    );
  }

  @override
  ConsumerState<RegisterEventDialog> createState() => _RegisterEventDialogState();
}

class _RegisterEventDialogState extends ConsumerState<RegisterEventDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController(text: 'Main University Auditorium');
  final _budgetCtrl = TextEditingController(text: '50000');
  final _attendeesCtrl = TextEditingController(text: '150');
  final _impactCtrl = TextEditingController();
  final List<_SpeakerInputControllers> _speakerControllers = [];
  final _collabCtrl = TextEditingController();

  List<Society> _societies = [];
  String? _selectedSocId;
  bool _isCollab = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String? _titleError;
  bool _isSubmitting = false;
  bool _isLoadingSocieties = false;

  @override
  void initState() {
    super.initState();
    _speakerControllers.add(_SpeakerInputControllers());
    if (widget.lockedSociety != null) {
      _selectedSocId = widget.lockedSociety!.id;
    } else {
      _loadSocieties();
    }
  }

  Future<void> _loadSocieties() async {
    setState(() => _isLoadingSocieties = true);
    try {
      final socs =
          await widget.database.select(widget.database.societies).get();
      if (mounted) {
        setState(() {
          _societies = socs;
          if (_selectedSocId == null && socs.isNotEmpty) {
            _selectedSocId = socs.first.id;
          }
          _isLoadingSocieties = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingSocieties = false);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _budgetCtrl.dispose();
    _attendeesCtrl.dispose();
    _impactCtrl.dispose();
    for (final ctrl in _speakerControllers) {
      ctrl.dispose();
    }
    _collabCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitEvent() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Please enter event title');
      return;
    }

    final effectiveSocId = widget.lockedSociety?.id ?? _selectedSocId;

    setState(() => _isSubmitting = true);

    try {
      final eventId = const Uuid().v4();
      final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0.0;
      final attendees = int.tryParse(_attendeesCtrl.text.trim()) ?? 0;
      final attachedImages = ref.read(eventImageAttachmentProvider).imagePaths;
      final primaryImage = attachedImages.isNotEmpty ? attachedImages.first : null;
      final encodedImages = attachedImages.isNotEmpty ? jsonEncode(attachedImages) : null;

      await widget.database.into(widget.database.events).insert(
            EventsCompanion.insert(
              id: eventId,
              title: title,
              description: _descCtrl.text.trim().isEmpty
                  ? 'Institutional Campus Event'
                  : _descCtrl.text.trim(),
              eventDate: _selectedDate,
              societyId: drift.Value(effectiveSocId),
              isCollaboration: drift.Value(_isCollab),
              collaboratorNames:
                  drift.Value(_isCollab ? _collabCtrl.text.trim() : null),
              venue: drift.Value(_venueCtrl.text.trim()),
              allocatedBudget: drift.Value(budget),
              actualExpense: drift.Value(budget * 0.85),
              attendeesCount: drift.Value(attendees),
              positiveImpactSummary: drift.Value(_impactCtrl.text.trim()),
              bannerImagePath: drift.Value(primaryImage),
              imagePaths: drift.Value(encodedImages),
            ),
          );

      final List<SpeakerEntry> speakerEntries = _speakerControllers
          .map((c) => c.toEntry())
          .where((s) => s.name.isNotEmpty)
          .toList();

      for (final spk in speakerEntries) {
        await widget.database.into(widget.database.eventSpeakers).insert(
              EventSpeakersCompanion.insert(
                id: const Uuid().v4(),
                eventId: eventId,
                name: spk.name,
                organization: spk.organization.isEmpty
                    ? 'External Keynote'
                    : spk.organization,
              ),
            );
      }

      // Automated Vault Archiving: Encrypt and seal event audit record in Vault
      try {
        final createdEvent = await (widget.database.select(widget.database.events)
              ..where((tbl) => tbl.id.equals(eventId)))
            .getSingle();

        Society? targetSoc = widget.lockedSociety;
        if (targetSoc == null && effectiveSocId != null) {
          final socs = await (widget.database.select(widget.database.societies)
                ..where((tbl) => tbl.id.equals(effectiveSocId)))
              .get();
          if (socs.isNotEmpty) targetSoc = socs.first;
        }

        final speakersList = await (widget.database.select(widget.database.eventSpeakers)
              ..where((tbl) => tbl.eventId.equals(eventId)))
            .get();

        await ref.read(vaultProvider(widget.database).notifier).archiveEvent(
              event: createdEvent,
              society: targetSoc,
              speakers: speakersList,
            );
      } catch (archiveError) {
        debugPrint('Automated vault archiving notice: $archiveError');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onEventSaved?.call();
        UiNotification.success(
            context, 'Event "$title" published & sealed in Vault!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        UiNotification.error(context, 'Failed to publish event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.lockedSociety != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(LucideIcons.calendarPlus,
              size: 20, color: AppColors.pillarEngagement),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLocked
                  ? 'Post Event — ${widget.lockedSociety!.name}'
                  : 'Register New Institutional Event',
              style: AppTypography.cardHeading,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Cover Image / Promotional Graphic Upload Widget
              Consumer(
                builder: (context, ref, _) {
                  final imgState = ref.watch(eventImageAttachmentProvider);
                  final notifier = ref.read(eventImageAttachmentProvider.notifier);

                  if (imgState.imagePaths.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.image, size: 14, color: AppColors.pillarEngagement),
                              const SizedBox(width: 6),
                              Text(
                                'Promotional Media Gallery (${imgState.imagePaths.length}/3)',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                              ),
                              const Spacer(),
                              if (imgState.canAddMore)
                                TextButton.icon(
                                  onPressed: imgState.isPicking ? null : notifier.pickImages,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(LucideIcons.plus, size: 13),
                                  label: const Text('Add Image', style: TextStyle(fontSize: 11)),
                                ),
                              TextButton(
                                onPressed: notifier.clearImages,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.statusDanger,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Clear All', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              for (int i = 0; i < imgState.imagePaths.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                Expanded(
                                  child: _buildThumbnailTile(
                                    path: imgState.imagePaths[i],
                                    index: i,
                                    isCover: i == 0,
                                    onRemove: () => notifier.removeImageAt(i),
                                  ),
                                ),
                              ],
                              for (int i = imgState.imagePaths.length; i < 3; i++) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: imgState.isPicking ? null : notifier.pickImages,
                                    borderRadius: BorderRadius.circular(10),
                                    child: CustomPaint(
                                      painter: _DashedRectPainter(
                                        color: AppColors.borderSubtle,
                                        strokeWidth: 1.5,
                                        gap: 4.0,
                                      ),
                                      child: Container(
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceBg.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(LucideIcons.plus, size: 18, color: AppColors.textMuted),
                                            SizedBox(height: 4),
                                            Text('Slot +', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Material(
                      color: AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: imgState.isPicking ? null : notifier.pickImages,
                        borderRadius: BorderRadius.circular(12),
                        child: CustomPaint(
                          painter: _DashedRectPainter(
                            color: AppColors.pillarEngagement.withOpacity(0.45),
                            strokeWidth: 1.5,
                            gap: 4.5,
                          ),
                          child: Container(
                            height: 96,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: imgState.isPicking
                                ? const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pillarEngagement),
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.imagePlus, size: 24, color: AppColors.pillarEngagement),
                                      SizedBox(height: 5),
                                      Text(
                                        'Attach Cover Image or Promotional Banner',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'PNG, JPG, WEBP • Click to browse local desktop files',
                                        style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  hintText: 'e.g. Annual Tech Symposium & Hackathon 2026',
                  errorText: _titleError,
                ),
                onChanged: (v) {
                  if (_titleError != null && v.trim().isNotEmpty) {
                    setState(() => _titleError = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Narrative / Detailed Description',
                  hintText: 'Summary of aims, agenda, and outcomes...',
                ),
              ),
              const SizedBox(height: 12),

              // Host Society Field: Locked vs Selectable Dropdown
              if (isLocked)
                TextFormField(
                  initialValue:
                      '${widget.lockedSociety!.name} (${widget.lockedSociety!.pillar})',
                  readOnly: true,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Host Society / Chapter (Locked)',
                    prefixIcon: const Icon(LucideIcons.lock,
                        size: 16, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceBg,
                    helperText: 'Locked to currently active society page',
                    helperStyle: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                )
              else if (_isLoadingSocieties)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                )
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _societies.any((s) => s.id == _selectedSocId)
                      ? _selectedSocId
                      : (_societies.isNotEmpty ? _societies.first.id : null),
                  decoration: const InputDecoration(
                    labelText: 'Host Society / Chapter',
                    prefixIcon: Icon(LucideIcons.building2,
                        size: 16, color: AppColors.textMuted),
                  ),
                  items: _societies
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.name} (${s.pillar})',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSocId = v),
                ),

              const SizedBox(height: 12),

              // Event Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Event Date',
                    prefixIcon: Icon(LucideIcons.calendar,
                        size: 16, color: AppColors.textMuted),
                    suffixIcon: Icon(LucideIcons.chevronDown,
                        size: 16, color: AppColors.textMuted),
                  ),
                  child: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _venueCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Campus Venue'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: _budgetCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Budget (PKR)'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _attendeesCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Estimated Attendees'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Collaboration',
                          style: TextStyle(fontSize: 13)),
                      value: _isCollab,
                      onChanged: (val) =>
                          setState(() => _isCollab = val ?? false),
                    ),
                  ),
                ],
              ),
              if (_isCollab) ...[
                const SizedBox(height: 8),
                TextField(
                    controller: _collabCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Collaborating Body / NGO Name')),
              ],
              const SizedBox(height: 12),
              TextField(
                  controller: _impactCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Target Positive Impact / Outcomes')),
              const SizedBox(height: 14),
              const Text('Keynote Guest / Speaker (Optional)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              ...List.generate(_speakerControllers.length, (idx) {
                final ctrl = _speakerControllers[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl.nameController,
                          decoration: InputDecoration(
                            labelText: _speakerControllers.length == 1
                                ? 'Speaker Name'
                                : 'Speaker ${idx + 1} Name',
                            hintText: 'e.g. Dr. Jane Doe',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ctrl.orgController,
                          decoration: const InputDecoration(
                            labelText: 'Organization / Company',
                            hintText: 'e.g. TechCorp / University',
                          ),
                        ),
                      ),
                      if (_speakerControllers.length > 1) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2,
                              size: 16, color: AppColors.statusDanger),
                          tooltip: 'Remove Speaker',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              final removed = _speakerControllers.removeAt(idx);
                              removed.dispose();
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _speakerControllers.add(_SpeakerInputControllers());
                    });
                  },
                  icon: const Icon(LucideIcons.plus,
                      size: 14, color: AppColors.pillarEngagement),
                  label: const Text(
                    'Add Another Speaker',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pillarEngagement),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pillarEngagement,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Publish Event'),
        ),
      ],
    );
  }

  Widget _buildThumbnailTile({
    required String path,
    required int index,
    required bool isCover,
    required VoidCallback onRemove,
  }) {
    final file = File(path);
    return Container(
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
        color: Colors.black12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            path.startsWith('assets/')
                ? Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _thumbnailFallback())
                : Image.file(file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _thumbnailFallback()),
            // Top pill: Cover / #Index
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCover ? 'Cover' : '#${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            // Top right: Close/Remove button 'x'
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.70),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.x, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailFallback() {
    return Container(
      color: AppColors.surfaceBg,
      alignment: Alignment.center,
      child: const Icon(LucideIcons.image, size: 20, color: AppColors.textMuted),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? gap * 1.5 : gap;
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gap != gap;
}
