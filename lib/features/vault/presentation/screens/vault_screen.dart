import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/encryption_service.dart';
import '../../../../core/services/reporting/monthly_audit_vault_metadata.dart';
import '../../../../core/widgets/ui_state_widgets.dart';
import '../state/vault_provider.dart';

class VaultScreen extends ConsumerStatefulWidget {
  final AppDatabase database;

  const VaultScreen({super.key, required this.database});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;

  // Default Master PIN for demonstration
  static const String _masterPin = '1234';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vaultProvider(widget.database).notifier).loadSocieties();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _unlockVault() {
    final notifier = ref.read(vaultProvider(widget.database).notifier);
    final success = notifier.unlock(_pinController.text);
    if (success) {
      UiNotification.success(context, 'Institutional Vault unlocked successfully.');
    }
  }

  void _lockVault() {
    ref.read(vaultProvider(widget.database).notifier).lock();
    _pinController.clear();
    UiNotification.info(context, 'Institutional Vault locked and memory cleared.');
  }

  Future<void> _deleteDoc(ConfidentialVaultData doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Confidential Asset'),
        content: Text('Permanently remove "${doc.title}" and purge the encrypted file from storage?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDanger, foregroundColor: Colors.white),
            child: const Text('Delete Asset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(vaultProvider(widget.database).notifier).deleteDoc(doc);
      if (mounted) {
        UiNotification.info(context, 'Encrypted asset "${doc.title}" purged.');
      }
    }
  }

  Future<void> _ingestNewDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'xlsx', 'txt'],
      dialogTitle: 'Select Confidential Institutional Document to Encrypt',
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final rawBytes = await file.readAsBytes();
      final originalName = result.files.single.name;

      final titleCtrl = TextEditingController(text: originalName.replaceAll(RegExp(r'\.[^.]+$'), ''));
      final refCtrl = TextEditingController(text: 'AUST/YDC/SEC/2026/${DateTime.now().millisecond}');
      final vaultState = ref.read(vaultProvider(widget.database));
      final dynamicCats = vaultState.dynamicCategories.where((c) => c != 'All').toList();
      String category = dynamicCats.contains('MOU') ? 'MOU' : (dynamicCats.isNotEmpty ? dynamicCats.first : 'MOU');
      String? titleError;
      bool isSubmitting = false;

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(LucideIcons.shieldCheck, color: AppColors.pillarEnvironment, size: 20),
                SizedBox(width: 8),
                Text('Encrypt & Ingest Confidential Asset', style: AppTypography.cardHeading),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Document Title *',
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
                            isExpanded: true,
                            value: category,
                            decoration: const InputDecoration(labelText: 'Asset Category / Workspace'),
                            items: dynamicCats
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (v) => setDialogState(() => category = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Reference Number'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        'File: $originalName (${(rawBytes.length / 1024).toStringAsFixed(1)} KB)\nAlgorithm: AES-256-GCM Envelope Encryption with SHA-256 integrity hash.',
                        style: AppTypography.bodyMuted,
                      ),
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
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) {
                          setDialogState(() => titleError = 'Document title is required');
                          return;
                        }

                        setDialogState(() => isSubmitting = true);
                        Navigator.of(ctx).pop();
                        setState(() => _isLoading = true);

                        final encPath = await EncryptionService.encryptAndStoreFile(
                          rawBytes: rawBytes,
                          originalFileName: originalName,
                          masterPassword: _masterPin,
                        );

                        final checksum = await EncryptionService.calculateChecksum(rawBytes);

                        final matchedSoc = vaultState.societies.cast<Society?>().firstWhere(
                          (s) =>
                              s != null &&
                              (s.name.toLowerCase() == category.toLowerCase() ||
                                  (s.acronym != null && s.acronym!.toLowerCase() == category.toLowerCase())),
                          orElse: () => null,
                        );

                        await widget.database.into(widget.database.confidentialVault).insert(
                          ConfidentialVaultCompanion.insert(
                            id: const Uuid().v4(),
                            societyId: drift.Value(matchedSoc?.id),
                            category: category,
                            title: title,
                            referenceNumber: drift.Value(refCtrl.text.trim()),
                            effectiveDate: drift.Value(DateTime.now()),
                            expiryDate: drift.Value(DateTime.now().add(const Duration(days: 730))),
                            encryptedFilePath: encPath,
                            fileChecksum: checksum,
                            fileSizeBytes: drift.Value(rawBytes.length),
                            originalFileName: drift.Value(originalName),
                          ),
                        );

                        await ref.read(vaultProvider(widget.database).notifier).loadVaultRecords();
                        if (mounted) {
                          setState(() => _isLoading = false);
                          UiNotification.success(context, 'Document "$title" encrypted and sealed in vault!');
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Encrypt & Save to Vault'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _createEncryptedMemoDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final refCtrl = TextEditingController(text: 'AUST/YDC/MEMO/2026/${DateTime.now().millisecond}');
    final vaultState = ref.read(vaultProvider(widget.database));
    final dynamicCats = vaultState.dynamicCategories.where((c) => c != 'All').toList();
    String category = dynamicCats.contains('MOU') ? 'MOU' : (dynamicCats.isNotEmpty ? dynamicCats.first : 'MOU');
    String? titleError;
    String? contentError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(LucideIcons.filePlus, color: AppColors.pillarEnvironment, size: 20),
              SizedBox(width: 8),
              Text('Create Encrypted Vault Memo', style: AppTypography.cardHeading),
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
                      labelText: 'Memo / Agreement Title *',
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
                          isExpanded: true,
                          value: category,
                          decoration: const InputDecoration(labelText: 'Category / Workspace'),
                          items: dynamicCats
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) => setDialogState(() => category = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Reference Number'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Confidential Content / Memo Body *',
                      hintText: 'Enter confidential agreement clauses, terms, or institutional details...',
                      errorText: contentError,
                    ),
                    onChanged: (v) {
                      if (contentError != null && v.trim().isNotEmpty) {
                        setDialogState(() => contentError = null);
                      }
                    },
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
                      final title = titleCtrl.text.trim();
                      final content = contentCtrl.text.trim();
                      if (title.isEmpty || content.isEmpty) {
                        setDialogState(() {
                          if (title.isEmpty) titleError = 'Title required';
                          if (content.isEmpty) contentError = 'Body content required';
                        });
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      Navigator.of(ctx).pop();
                      setState(() => _isLoading = true);

                      final memoBytes = Uint8List.fromList(content.codeUnits);
                      final fileName = '${title.replaceAll(' ', '_')}.txt';

                      final encPath = await EncryptionService.encryptAndStoreFile(
                        rawBytes: memoBytes,
                        originalFileName: fileName,
                        masterPassword: _masterPin,
                      );
                      final checksum = await EncryptionService.calculateChecksum(memoBytes);

                      final matchedSoc = vaultState.societies.cast<Society?>().firstWhere(
                        (s) =>
                            s != null &&
                            (s.name.toLowerCase() == category.toLowerCase() ||
                                (s.acronym != null && s.acronym!.toLowerCase() == category.toLowerCase())),
                        orElse: () => null,
                      );

                      await widget.database.into(widget.database.confidentialVault).insert(
                        ConfidentialVaultCompanion.insert(
                          id: const Uuid().v4(),
                          societyId: drift.Value(matchedSoc?.id),
                          category: category,
                          title: title,
                          referenceNumber: drift.Value(refCtrl.text.trim()),
                          effectiveDate: drift.Value(DateTime.now()),
                          expiryDate: drift.Value(DateTime.now().add(const Duration(days: 730))),
                          encryptedFilePath: encPath,
                          fileChecksum: checksum,
                          fileSizeBytes: drift.Value(memoBytes.length),
                          originalFileName: drift.Value(fileName),
                        ),
                      );

                      await ref.read(vaultProvider(widget.database).notifier).loadVaultRecords();
                      if (mounted) {
                        setState(() => _isLoading = false);
                        UiNotification.success(context, 'Encrypted memo "$title" sealed in vault!');
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Encrypt & Seal Memo'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDecryptedFile(ConfidentialVaultData doc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _DecryptedDocumentViewerDialog(
        doc: doc,
        masterPin: _masterPin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultProvider(widget.database));
    final vaultNotifier = ref.read(vaultProvider(widget.database).notifier);

    if (!vaultState.isUnlocked) {
      return _buildLockScreen(vaultState, vaultNotifier);
    }

    final filtered = vaultState.filteredDocs;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: (vaultState.isLoading || _isLoading)
          ? const UiLoadingState(message: 'Encrypting / Decrypting Vault Storage...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vault Header with Responsive Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 680;

                      const titleSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Confidential Institutional Vault', style: AppTypography.heading1),
                              SizedBox(width: 8),
                              Icon(LucideIcons.lock, size: 18, color: AppColors.pillarEnvironment),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('AES-256-GCM encrypted local store for MoUs, PMYP contracts & fiscal audits.', style: AppTypography.bodyMuted),
                        ],
                      );

                      final actionButtons = Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _createEncryptedMemoDialog,
                            icon: const Icon(LucideIcons.filePlus, size: 14),
                            label: const Text('Add Memo'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _ingestNewDocument,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pillarEnvironment),
                            icon: const Icon(LucideIcons.shieldCheck, size: 16),
                            label: const Text('Encrypt File'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _lockVault,
                            icon: const Icon(LucideIcons.lock, size: 14),
                            label: const Text('Lock Vault'),
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
                          const Expanded(child: titleSection),
                          actionButtons,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Search & Category Filter Toolbar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 700;

                        final searchField = TextField(
                          onChanged: (val) => vaultNotifier.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: 'Search encrypted documents, memos, reference numbers...',
                            prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
                            suffixIcon: vaultState.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(LucideIcons.x, size: 15),
                                    onPressed: () => vaultNotifier.setSearchQuery(''),
                                  )
                                : null,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        );

                        final categoryChips = SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: vaultState.dynamicCategories.map((cat) {
                              final isSelected = vaultState.selectedCategory.toLowerCase() == cat.toLowerCase();
                              final isSociety = !VaultFilterState.defaultStaticCategories.contains(cat);
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  avatar: isSociety
                                      ? const Icon(LucideIcons.users, size: 12, color: AppColors.brandPurple)
                                      : null,
                                  label: Text(cat),
                                  selected: isSelected,
                                  selectedColor: isSociety
                                      ? AppColors.brandPurple.withOpacity(0.18)
                                      : AppColors.pillarEnvironment.withOpacity(0.15),
                                  onSelected: (_) => vaultNotifier.selectCategory(cat),
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
                              const SizedBox(height: 10),
                              categoryChips,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(flex: 5, child: searchField),
                            const SizedBox(width: 14),
                            Expanded(flex: 6, child: categoryChips),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Document Cards Grid or Empty State
                  if (filtered.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: UiEmptyState(
                        icon: LucideIcons.shieldAlert,
                        title: vaultState.searchQuery.isNotEmpty ? 'No Matching Documents' : 'No Confidential Documents',
                        message: vaultState.searchQuery.isNotEmpty
                            ? 'No vault documents match "${vaultState.searchQuery}".'
                            : 'No encrypted assets stored under the ${vaultState.selectedCategory} category.',
                        actionLabel: vaultState.searchQuery.isNotEmpty ? 'Clear Search' : 'Encrypt Document',
                        actionIcon: vaultState.searchQuery.isNotEmpty ? LucideIcons.x : LucideIcons.shieldCheck,
                        onAction: vaultState.searchQuery.isNotEmpty
                            ? () => vaultNotifier.setSearchQuery('')
                            : _ingestNewDocument,
                        secondaryActionLabel: vaultState.searchQuery.isEmpty ? 'Add Memo' : null,
                        onSecondaryAction: vaultState.searchQuery.isEmpty ? _createEncryptedMemoDialog : null,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: filtered.map((doc) => _buildDocCard(doc)).toList(),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildLockScreen(VaultFilterState vaultState, VaultNotifier vaultNotifier) {
    return Center(
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 30, offset: Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.pillarEnvironment.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(LucideIcons.shieldAlert, size: 32, color: AppColors.pillarEnvironment),
            ),
            const SizedBox(height: 20),
            const Text('CONFIDENTIAL INSTITUTIONAL VAULT', style: AppTypography.heading1),
            const SizedBox(height: 6),
            const Text(
              'Enter the Master Vault PIN to decrypt administrative MoUs, PMYP records, and financial vouchers.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '••••',
                hintStyle: const TextStyle(letterSpacing: 8),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                  tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
              onSubmitted: (_) => _unlockVault(),
            ),
            if (vaultState.pinError != null && vaultState.pinError!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(vaultState.pinError!, style: const TextStyle(fontSize: 11, color: AppColors.statusDanger, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                _pinController.text = _masterPin;
                _unlockVault();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.key, size: 12, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text('Auto-Fill Demo PIN (1234)', style: TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _unlockVault,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pillarEnvironment,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(LucideIcons.unlock, size: 16),
                label: const Text('Unlock Institutional Vault'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(ConfidentialVaultData doc) {
    final dateFmt = DateFormat('d MMM yyyy');

    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  final vaultState = ref.watch(vaultProvider(widget.database));
                  final isMonthlyAudit = doc.category.toLowerCase() == 'monthly audits';
                  final isSocietyDoc = !isMonthlyAudit && (doc.societyId != null ||
                      vaultState.societies.any((s) =>
                          s.id == doc.societyId ||
                          s.name.toLowerCase() == doc.category.toLowerCase() ||
                          (s.acronym != null && s.acronym!.toLowerCase() == doc.category.toLowerCase())));

                  final Color badgeBg = isMonthlyAudit
                      ? AppColors.brandPurple.withOpacity(0.14)
                      : (isSocietyDoc
                          ? AppColors.pillarEducation.withOpacity(0.12)
                          : AppColors.pillarEnvironment.withOpacity(0.12));

                  final Color badgeText = isMonthlyAudit
                      ? AppColors.brandPurple
                      : (isSocietyDoc ? AppColors.pillarEducation : AppColors.pillarEnvironment);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isMonthlyAudit) ...[
                          const Icon(LucideIcons.fileSpreadsheet, size: 11, color: AppColors.brandPurple),
                          const SizedBox(width: 4),
                        ] else if (isSocietyDoc) ...[
                          const Icon(LucideIcons.users, size: 11, color: AppColors.pillarEducation),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          doc.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: badgeText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Spacer(),
              const Icon(LucideIcons.fileLock2, size: 16, color: AppColors.pillarEnvironment),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusDanger),
                tooltip: 'Delete Encrypted Asset',
                onPressed: () => _deleteDoc(doc),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(doc.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          if (doc.referenceNumber != null) ...[
            const SizedBox(height: 4),
            Text('Ref: ${doc.referenceNumber!}', style: AppTypography.mono),
          ],
          if (doc.metadataNotes != null && doc.metadataNotes!.trim().isNotEmpty) ...[
            Builder(
              builder: (context) {
                final auditMeta = MonthlyAuditVaultMetadata.parseFromNotes(doc.metadataNotes);
                if (auditMeta != null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.calendarCheck2, size: 12, color: AppColors.brandPurple),
                            const SizedBox(width: 5),
                            Text(
                              'Audit Period: ${auditMeta.monthYear}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildAuditMiniChip('${auditMeta.coveredSocieties.length} Societies', LucideIcons.users, AppColors.brandPurple),
                            _buildAuditMiniChip('${auditMeta.coveredEvents.length} Events', LucideIcons.calendar, AppColors.pillarEnvironment),
                            _buildAuditMiniChip('${auditMeta.totalMembers} Members', LucideIcons.userCheck, AppColors.pillarEducation),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle.withOpacity(0.5)),
                  ),
                  child: Text(
                    doc.metadataNotes!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                doc.effectiveDate != null ? 'Effective: ${dateFmt.format(doc.effectiveDate!)}' : 'Recorded Recently',
                style: AppTypography.bodyMuted,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.hash, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'SHA-256: ${doc.fileChecksum.length >= 16 ? doc.fileChecksum.substring(0, 16) : doc.fileChecksum}...',
                  style: const TextStyle(fontFamily: 'Consolas', fontSize: 10, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _viewDecryptedFile(doc),
              icon: const Icon(LucideIcons.eye, size: 14),
              label: const Text('In-Memory Decrypt & View'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditMiniChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// Supported document representations in the in-memory decrypted viewer
enum VaultDocumentType {
  pdf,
  image,
  text,
  unsupported,
}

/// Robust MIME & magic-byte detector for decrypted volatile byte streams
class DecryptedContentDetector {
  static VaultDocumentType detect({
    required Uint8List bytes,
    String? fileName,
  }) {
    if (bytes.isEmpty) return VaultDocumentType.unsupported;

    // 1. Magic byte inspection: PDF (%PDF = 0x25 0x50 0x44 0x46)
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return VaultDocumentType.pdf;
    }
    // Check first 1024 bytes for embedded %PDF- signature (e.g. leading whitespace or BOM)
    if (bytes.length > 4) {
      final headerCheckLength = bytes.length < 1024 ? bytes.length : 1024;
      final headerStr = String.fromCharCodes(bytes.sublist(0, headerCheckLength));
      if (headerStr.contains('%PDF-')) {
        return VaultDocumentType.pdf;
      }
    }

    // 2. Magic byte inspection: Images
    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return VaultDocumentType.image;
    }

    // JPEG: FF D8 FF
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return VaultDocumentType.image;
    }

    // GIF: "GIF8" (0x47 0x49 0x46 0x38)
    if (bytes.length >= 4 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return VaultDocumentType.image;
    }

    // WebP: RIFF....WEBP (0x52 0x49 0x46 0x46 .... 0x57 0x45 0x42 0x50)
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return VaultDocumentType.image;
    }

    // BMP: "BM" (0x42 0x4D)
    if (bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return VaultDocumentType.image;
    }

    // 3. Fallback to extension hints
    final ext = (fileName != null && fileName.contains('.'))
        ? fileName.split('.').last.toLowerCase().trim()
        : '';

    if (ext == 'pdf') {
      return VaultDocumentType.pdf;
    }
    if (const {'png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'}.contains(ext)) {
      return VaultDocumentType.image;
    }
    if (const {'txt', 'csv', 'tsv', 'json', 'md', 'log', 'xml', 'html', 'yaml', 'yml', 'env', 'ini', 'cfg'}.contains(ext)) {
      return VaultDocumentType.text;
    }

    // 4. Check if bytes can be decoded as readable UTF-8 text without binary control characters
    try {
      final decoded = utf8.decode(bytes, allowMalformed: false);
      int nonPrintable = 0;
      final checkLimit = decoded.length < 500 ? decoded.length : 500;
      for (int i = 0; i < checkLimit; i++) {
        final code = decoded.codeUnitAt(i);
        if (code < 32 && code != 9 && code != 10 && code != 13) {
          nonPrintable++;
        }
      }
      if (nonPrintable == 0) {
        return VaultDocumentType.text;
      }
    } catch (_) {}

    return VaultDocumentType.unsupported;
  }
}

/// Robust, asynchronous in-memory viewer for AES-256-GCM encrypted vault assets
class _DecryptedDocumentViewerDialog extends StatefulWidget {
  final ConfidentialVaultData doc;
  final String masterPin;

  const _DecryptedDocumentViewerDialog({
    required this.doc,
    required this.masterPin,
  });

  @override
  State<_DecryptedDocumentViewerDialog> createState() => _DecryptedDocumentViewerDialogState();
}

class _DecryptedDocumentViewerDialogState extends State<_DecryptedDocumentViewerDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _decryptedBytes;
  VaultDocumentType _detectedType = VaultDocumentType.unsupported;
  String _textContent = '';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadAndDecrypt();
  }

  Future<void> _loadAndDecrypt() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _decryptedBytes = null;
    });

    try {
      final file = File(widget.doc.encryptedFilePath);
      if (!file.existsSync()) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'The encrypted asset was not found on local storage:\n\n${widget.doc.encryptedFilePath}\n\nPlease verify that the file has not been deleted or moved.';
        });
        return;
      }

      final bytes = await EncryptionService.decryptFileInMemory(
        encryptedFilePath: widget.doc.encryptedFilePath,
        masterPassword: widget.masterPin,
      );

      if (bytes.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Decryption produced an empty byte stream (0 bytes). The ciphertext payload may be truncated.';
        });
        return;
      }

      final type = DecryptedContentDetector.detect(
        bytes: bytes,
        fileName: widget.doc.originalFileName,
      );

      String text = '';
      if (type == VaultDocumentType.text) {
        text = utf8.decode(bytes, allowMalformed: true);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _decryptedBytes = bytes;
        _detectedType = type;
        _textContent = text;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Decryption Authentication Failed:\n$e\n\nPlease confirm your Master Vault PIN and ensure the AES-256-GCM cipher envelope has not been modified.';
      });
    }
  }

  Future<void> _exportDecryptedCopy() async {
    if (_decryptedBytes == null) return;
    setState(() => _isExporting = true);
    try {
      final defaultName = widget.doc.originalFileName ?? 'decrypted_${widget.doc.id.substring(0, 8)}.bin';
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Decrypted Plaintext Copy',
        fileName: defaultName,
      );
      if (savePath != null && mounted) {
        await File(savePath).writeAsBytes(_decryptedBytes!);
        UiNotification.success(context, 'Decrypted copy saved to $savePath');
      }
    } catch (e) {
      if (mounted) {
        UiNotification.error(context, 'Failed to export decrypted copy: $e');
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 880,
        height: 720,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with Security Indicators
            Row(
              children: [
                const Icon(LucideIcons.shieldCheck, color: AppColors.pillarEnvironment, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doc.title,
                        style: AppTypography.cardHeading,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          UiStatusBadge.info(label: widget.doc.category),
                          const SizedBox(width: 8),
                          if (widget.doc.originalFileName != null)
                            Expanded(
                              child: Text(
                                widget.doc.originalFileName!,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.pillarEnvironment.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.pillarEnvironment.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.cpu, size: 12, color: AppColors.pillarEnvironment),
                      SizedBox(width: 5),
                      Text(
                        'AES-256-GCM Volatile RAM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pillarEnvironment,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Content Viewport
            Expanded(child: _buildBody()),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_decryptedBytes != null)
                  OutlinedButton.icon(
                    onPressed: _isExporting ? null : _exportDecryptedCopy,
                    icon: _isExporting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(LucideIcons.download, size: 15),
                    label: const Text('Export Decrypted Copy', style: TextStyle(fontSize: 12)),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close Viewer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: UiLoadingState(
          message: 'Decrypting volatile memory payload...',
          subMessage: 'Deriving PBKDF2 key and verifying AES-256-GCM ciphertext tag',
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: UiErrorState(
            errorMessage: _errorMessage!,
            onRetry: _loadAndDecrypt,
          ),
        ),
      );
    }

    if (_decryptedBytes == null) {
      return const Center(
        child: UiEmptyState(
          icon: LucideIcons.fileX,
          title: 'No Content Available',
          message: 'Decryption yielded no readable data buffer.',
        ),
      );
    }

    switch (_detectedType) {
      case VaultDocumentType.pdf:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: PdfPreview(
            build: (format) => _decryptedBytes!,
            allowPrinting: true,
            allowSharing: false,
            canChangePageFormat: false,
            initialPageFormat: PdfPageFormat.a4,
          ),
        );

      case VaultDocumentType.image:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.memory(
                _decryptedBytes!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: UiErrorState(
                        errorMessage: 'Failed to display image data ($error). The image payload may be corrupt or formatted improperly.',
                        onRetry: null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

      case VaultDocumentType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.fileText, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Plaintext Document (${(_decryptedBytes!.length / 1024).toStringAsFixed(1)} KB)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _textContent));
                      UiNotification.success(context, 'Decrypted text copied to clipboard!');
                    },
                    icon: const Icon(LucideIcons.copy, size: 13),
                    label: const Text('Copy Text', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _textContent,
                    style: const TextStyle(
                      fontFamily: 'Consolas',
                      fontSize: 12.5,
                      height: 1.5,
                      color: Color(0xFFCDD6F4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case VaultDocumentType.unsupported:
        return Center(
          child: Container(
            width: 540,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.fileCode, size: 44, color: AppColors.brandPurple),
                const SizedBox(height: 12),
                const Text('Binary Asset Decrypted in RAM', style: AppTypography.cardHeading),
                const SizedBox(height: 8),
                Text(
                  'The decrypted asset (${(_decryptedBytes!.length / 1024).toStringAsFixed(1)} KB) is in a binary format that cannot be directly visualized in the volatile RAM viewer.\n\nYou can export a decrypted copy to open it in its native desktop application.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      _metaRow('File Name', widget.doc.originalFileName ?? 'vault_asset.bin'),
                      const Divider(height: 12),
                      _metaRow('Reference No', widget.doc.referenceNumber ?? 'N/A'),
                      const Divider(height: 12),
                      _metaRow('File Size', '${(_decryptedBytes!.length / 1024).toStringAsFixed(1)} KB (${_decryptedBytes!.length} bytes)'),
                      const Divider(height: 12),
                      _metaRow('SHA-256 Checksum', widget.doc.fileChecksum),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _metaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontFamily: 'Consolas', color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}
