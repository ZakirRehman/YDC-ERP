import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';

class EventDetailDialog extends StatefulWidget {
  final Event event;
  final Society? society;
  final List<EventSpeaker> speakers;
  final VoidCallback? onDelete;

  const EventDetailDialog({
    super.key,
    required this.event,
    this.society,
    this.speakers = const [],
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Event event,
    Society? society,
    List<EventSpeaker> speakers = const [],
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EventDetailDialog(
        event: event,
        society: society,
        speakers: speakers,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<EventDetailDialog> createState() => _EventDetailDialogState();
}

class _EventDetailDialogState extends State<EventDetailDialog> {
  late final PageController _pageController;
  int _activePageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _extractImages() {
    final images = widget.event.galleryImages;
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final dateFmt = DateFormat('EEEE, dd MMMM yyyy');
    final images = _extractImages();
    final soc = widget.society;
    final pillarColor = soc != null
        ? AppColors.getPillarColor(soc.pillar)
        : AppColors.pillarEngagement;

    final variance = widget.event.allocatedBudget - widget.event.actualExpense;
    final isUnderBudget = variance >= 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 820,
          maxHeight: 880,
        ),
        child: Column(
          children: [
            // Top Bar with Close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillarColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      soc != null ? '${soc.name} (${soc.pillar})' : 'YDC Directorate',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: pillarColor),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textMuted),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carousel / Gallery View at top
                    if (images.isNotEmpty)
                      _buildImageGallery(images)
                    else
                      _buildPlaceholderBanner(pillarColor),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Title and Collaboration
                          Text(widget.event.title, style: AppTypography.heading1),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(dateFmt.format(widget.event.eventDate), style: AppTypography.bodyMuted),
                              const SizedBox(width: 18),
                              const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.event.venue ?? 'Campus Auditorium',
                                  style: AppTypography.bodyMuted,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          if (widget.event.isCollaboration) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.pillarEducation.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.pillarEducation.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.users, size: 14, color: AppColors.pillarEducation),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Institutional Collaboration: ${widget.event.collaboratorNames ?? 'Allied Partners'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.pillarEducation,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Key Institutional Metrics Grid
                          const Text('Executive & Financial Audit Metrics', style: AppTypography.cardHeading),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  label: 'Allocated Budget',
                                  value: currencyFmt.format(widget.event.allocatedBudget),
                                  icon: LucideIcons.banknote,
                                  color: AppColors.pillarEmployment,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  label: 'Actual Expenditure',
                                  value: currencyFmt.format(widget.event.actualExpense),
                                  icon: LucideIcons.receipt,
                                  color: AppColors.pillarEnvironment,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  label: 'Fiscal Variance',
                                  value: '${isUnderBudget ? '+' : ''}${currencyFmt.format(variance)}',
                                  icon: isUnderBudget ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                                  color: isUnderBudget ? AppColors.statusSuccess : AppColors.statusDanger,
                                  sublabel: isUnderBudget ? 'Under Budget' : 'Over Budget',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  label: 'Attendees',
                                  value: '${widget.event.attendeesCount}',
                                  icon: LucideIcons.users,
                                  color: AppColors.pillarEngagement,
                                  sublabel: 'Registered',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Narrative / Description
                          const Text('Event Narrative & Scope', style: AppTypography.cardHeading),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              widget.event.description.isNotEmpty
                                  ? widget.event.description
                                  : 'No extended operational description provided for this campus event.',
                              style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.textDark),
                            ),
                          ),

                          // Positive Impact Summary
                          if (widget.event.positiveImpactSummary != null &&
                              widget.event.positiveImpactSummary!.trim().isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('Impact & Student Development Outcome', style: AppTypography.cardHeading),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(LucideIcons.sparkles, size: 18, color: Color(0xFF16A34A)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.event.positiveImpactSummary!,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF14532D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Guest Speakers Directory
                          if (widget.speakers.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Keynote Speakers & Guest Roster (${widget.speakers.length})',
                              style: AppTypography.cardHeading,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: widget.speakers.map((spk) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppColors.pillarEngagement.withOpacity(0.15),
                                        child: const Icon(LucideIcons.user, size: 14, color: AppColors.pillarEngagement),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(spk.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                          Text(
                                            spk.designation != null && spk.designation!.isNotEmpty
                                                ? '${spk.designation} • ${spk.organization}'
                                                : spk.organization,
                                            style: AppTypography.bodyMuted,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                color: Color(0xFFF8FAFC),
              ),
              child: Row(
                children: [
                  if (widget.onDelete != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDelete?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusDanger,
                        side: const BorderSide(color: AppColors.statusDanger),
                      ),
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      label: const Text('Delete Event'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return Container(
      height: 280,
      width: double.infinity,
      color: Colors.black87,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (idx) => setState(() => _activePageIndex = idx),
            itemBuilder: (context, index) {
              final path = images[index];
              return Center(
                child: path.startsWith('assets/')
                    ? Image.asset(
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => _buildImageError(),
                      )
                    : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => _buildImageError(),
                      ),
              );
            },
          ),

          // Previous Image Button
          if (images.length > 1 && _activePageIndex > 0)
            Positioned(
              left: 14,
              child: InkWell(
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.chevronLeft, size: 20, color: Colors.white),
                ),
              ),
            ),

          // Next Image Button
          if (images.length > 1 && _activePageIndex < images.length - 1)
            Positioned(
              right: 14,
              child: InkWell(
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.chevronRight, size: 20, color: Colors.white),
                ),
              ),
            ),

          // Image Counter Badge
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.70),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.camera, size: 13, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    '${_activePageIndex + 1} / ${images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Dots Indicator
          if (images.length > 1)
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(images.length, (i) {
                  final isActive = i == _activePageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBanner(Color pillarColor) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: pillarColor.withOpacity(0.08),
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendar, size: 36, color: pillarColor.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(
            'Institutional Event Gallery',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: pillarColor),
          ),
          const SizedBox(height: 2),
          const Text(
            'No promotional graphics attached to this event record',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.imageOff, size: 32, color: Colors.white60),
          SizedBox(height: 6),
          Text('Image Preview Unavailable', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? sublabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 2),
            Text(sublabel, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}
