import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/ui_state_widgets.dart';
import '../widgets/event_detail_dialog.dart';
import '../widgets/register_event_dialog.dart';

class EventsScreen extends StatefulWidget {
  final AppDatabase database;

  const EventsScreen({super.key, required this.database});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  Map<String, List<EventSpeaker>> _speakersMap = {};
  Map<String, Society> _societiesMap = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedPillarFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final evts = await widget.database.select(widget.database.events).get();
      final socs = await widget.database.select(widget.database.societies).get();
      final Map<String, Society> sMap = {for (var s in socs) s.id: s};

      final Map<String, List<EventSpeaker>> spkMap = {};
      for (var e in evts) {
        final spks = await (widget.database.select(widget.database.eventSpeakers)
              ..where((tbl) => tbl.eventId.equals(e.id)))
            .get();
        spkMap[e.id] = spks;
      }

      if (mounted) {
        setState(() {
          _events = evts;
          _societiesMap = sMap;
          _speakersMap = spkMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiNotification.error(context, 'Failed to load events: $e');
      }
    }
  }

  Future<void> _deleteEvent(Event evt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.statusDanger, size: 22),
            SizedBox(width: 10),
            Text('Delete Event', style: AppTypography.cardHeading),
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
      _loadEvents();
      if (mounted) {
        UiNotification.info(context, 'Event "${evt.title}" deleted.');
      }
    }
  }

  Future<void> _deleteSpeaker(String speakerId, String speakerName) async {
    await (widget.database.delete(widget.database.eventSpeakers)..where((tbl) => tbl.id.equals(speakerId))).go();
    _loadEvents();
    if (mounted) {
      UiNotification.info(context, 'Speaker "$speakerName" removed.');
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (ctx) => RegisterEventDialog(
        database: widget.database,
        onEventSaved: _loadEvents,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final dateFmt = DateFormat('EEE, d MMM yyyy');

    final filteredEvents = _events.where((evt) {
      final soc = _societiesMap[evt.societyId];
      final matchesPillar = _selectedPillarFilter == 'All' || (soc != null && soc.pillar.toLowerCase() == _selectedPillarFilter.toLowerCase());
      if (!matchesPillar) return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final speakers = _speakersMap[evt.id] ?? [];
      final speakerMatches = speakers.any((s) => s.name.toLowerCase().contains(q) || s.organization.toLowerCase().contains(q));

      return evt.title.toLowerCase().contains(q) ||
          evt.description.toLowerCase().contains(q) ||
          (evt.venue?.toLowerCase().contains(q) ?? false) ||
          (soc?.name.toLowerCase().contains(q) ?? false) ||
          speakerMatches;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: _isLoading
          ? const UiLoadingState(message: 'Loading Institutional Events & Speaker Directory...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Events Management & Speaker Directory', style: AppTypography.heading1),
                            SizedBox(height: 2),
                            Text('Lifecycle governance, fiscal utilization and guest rosters.', style: AppTypography.bodyMuted),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddEventDialog,
                        icon: const Icon(LucideIcons.calendarPlus, size: 16),
                        label: const Text('Register New Event'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
                        final isNarrow = constraints.maxWidth < 650;

                        final searchField = TextField(
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          decoration: InputDecoration(
                            hintText: 'Search events by title, host society, venue, or speaker...',
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
                        );

                        final filterChips = SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Education', 'Employment', 'Engagement', 'Environment'].map((pillar) {
                              final isSelected = _selectedPillarFilter == pillar;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(pillar),
                                  selected: isSelected,
                                  selectedColor: AppColors.pillarEngagement.withOpacity(0.15),
                                  backgroundColor: AppColors.surfaceBg,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.pillarEngagement : AppColors.textDark,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.pillarEngagement : AppColors.borderSubtle,
                                  ),
                                  onSelected: (_) => setState(() => _selectedPillarFilter = pillar),
                                ),
                              );
                            }).toList(),
                          ),
                        );

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              searchField,
                              const SizedBox(height: 12),
                              filterChips,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(flex: 5, child: searchField),
                            const SizedBox(width: 14),
                            Expanded(flex: 6, child: filterChips),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Events Cards Grid or Empty State
                  if (filteredEvents.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: UiEmptyState(
                        icon: LucideIcons.calendar,
                        title: _searchQuery.isNotEmpty ? 'No Matching Events' : 'No Events Recorded',
                        message: _searchQuery.isNotEmpty
                            ? 'No events match "$_searchQuery". Try clearing your search query.'
                            : 'No institutional events have been scheduled under the $_selectedPillarFilter pillar.',
                        actionLabel: _searchQuery.isNotEmpty ? 'Clear Search' : 'Register New Event',
                        actionIcon: _searchQuery.isNotEmpty ? LucideIcons.x : LucideIcons.calendarPlus,
                        onAction: _searchQuery.isNotEmpty
                            ? () => setState(() => _searchQuery = '')
                            : _showAddEventDialog,
                      ),
                    )
                  else
                    ...filteredEvents.map((evt) {
                      final soc = _societiesMap[evt.societyId];
                      final speakers = _speakersMap[evt.id] ?? [];
                      final pillarColor = soc != null ? AppColors.getPillarColor(soc.pillar) : AppColors.pillarEngagement;
                      final primaryImg = evt.primaryImage;
                      final allImgs = evt.galleryImages;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              EventDetailDialog.show(
                                context,
                                event: evt,
                                society: soc,
                                speakers: speakers,
                                onDelete: () => _deleteEvent(evt),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (primaryImg != null && primaryImg.trim().isNotEmpty) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 145,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceBg,
                                              border: Border.all(color: AppColors.borderSubtle),
                                            ),
                                            child: primaryImg.startsWith('assets/')
                                                ? Image.asset(
                                                    primaryImg,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                                  )
                                                : Image.file(
                                                    File(primaryImg),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                                  ),
                                          ),
                                          if (allImgs.length > 1)
                                            Positioned(
                                              bottom: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.70),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(LucideIcons.image, size: 12, color: Colors.white),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${allImgs.length} Photos',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],

                                  // Responsive Top Header (Prevents 128px RenderFlex overflow)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isNarrow = constraints.maxWidth < 620;

                                      final badgeRow = Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: pillarColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              soc != null ? '${soc.name} (${soc.pillar})' : 'YDC Directorate',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pillarColor),
                                            ),
                                          ),
                                          if (evt.isCollaboration)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.pillarEducation.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Collab: ${evt.collaboratorNames ?? 'External'}',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.pillarEducation),
                                              ),
                                            ),
                                        ],
                                      );

                                      final actionRow = Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.calendar, size: 14, color: AppColors.textMuted),
                                          const SizedBox(width: 6),
                                          Text(dateFmt.format(evt.eventDate), style: AppTypography.bodyMuted),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusDanger),
                                            tooltip: 'Delete Event',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _deleteEvent(evt),
                                          ),
                                        ],
                                      );

                                      if (isNarrow) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            badgeRow,
                                            const SizedBox(height: 8),
                                            actionRow,
                                          ],
                                        );
                                      }

                                      return Row(
                                        children: [
                                          Expanded(child: badgeRow),
                                          const SizedBox(width: 8),
                                          actionRow,
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  Text(evt.title, style: AppTypography.cardHeading),
                                  const SizedBox(height: 6),
                                  Text(evt.description, style: AppTypography.body),

                                  const SizedBox(height: 14),

                                  // Meta Pills (Venue, Attendees, Budget)
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      _metaChip(LucideIcons.mapPin, evt.venue ?? 'Campus Auditorium'),
                                      _metaChip(LucideIcons.users, '${evt.attendeesCount} Attendees Registered'),
                                      _metaChip(LucideIcons.banknote, 'Allocated: ${currencyFmt.format(evt.allocatedBudget)}'),
                                      _metaChip(LucideIcons.receipt, 'Expense: ${currencyFmt.format(evt.actualExpense)}'),
                                    ],
                                  ),

                                  if (evt.positiveImpactSummary != null && evt.positiveImpactSummary!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceBg,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.borderSubtle),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(LucideIcons.sparkles, size: 16, color: AppColors.pillarEngagement),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Positive Impact: ${evt.positiveImpactSummary!}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Speaker Directory if present
                                  if (speakers.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 10),
                                    const Text('Guest Speakers & Keynotes:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: speakers.map((spk) {
                                        return Chip(
                                          avatar: const CircleAvatar(child: Icon(LucideIcons.user, size: 12)),
                                          label: Text('${spk.name} (${spk.organization})', style: const TextStyle(fontSize: 11)),
                                          backgroundColor: AppColors.surfaceBg,
                                          deleteIcon: const Icon(LucideIcons.x, size: 13, color: AppColors.statusDanger),
                                          onDeleted: () => _deleteSpeaker(spk.id, spk.name),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
