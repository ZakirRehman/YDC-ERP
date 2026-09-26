import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class EventImageAttachmentState {
  final List<String> imagePaths;
  final bool isPicking;
  final String? errorMessage;

  const EventImageAttachmentState({
    this.imagePaths = const [],
    this.isPicking = false,
    this.errorMessage,
  });

  /// Primary banner or first selected image for card display and previews
  String? get primaryImagePath => imagePaths.isNotEmpty ? imagePaths.first : null;

  /// Backward-compatible alias for primaryImagePath
  String? get imagePath => primaryImagePath;

  /// Whether the user can attach additional images (maximum 3)
  bool get canAddMore => imagePaths.length < 3;

  /// Remaining slots available for selection (0..3)
  int get remainingSlots => (3 - imagePaths.length).clamp(0, 3);

  EventImageAttachmentState copyWith({
    List<String>? imagePaths,
    bool? isPicking,
    String? errorMessage,
    bool clearAll = false,
  }) {
    return EventImageAttachmentState(
      imagePaths: clearAll ? const [] : (imagePaths ?? this.imagePaths),
      isPicking: isPicking ?? this.isPicking,
      errorMessage: errorMessage,
    );
  }
}

class EventImageAttachmentNotifier
    extends StateNotifier<EventImageAttachmentState> {
  EventImageAttachmentNotifier() : super(const EventImageAttachmentState());

  /// Asynchronously picks promotional images from local desktop storage,
  /// capping total attachments at 3.
  Future<void> pickImages() async {
    if (!state.canAddMore) {
      state = state.copyWith(errorMessage: 'Maximum of 3 images reached.');
      return;
    }

    state = state.copyWith(isPicking: true, errorMessage: null);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        dialogTitle: 'Select Event Promotional Images (Max 3)',
      );

      if (result != null && result.files.isNotEmpty) {
        final slotsLeft = state.remainingSlots;
        final picked = result.files
            .map((f) => f.path)
            .whereType<String>()
            .where((p) => p.trim().isNotEmpty && !state.imagePaths.contains(p.trim()))
            .take(slotsLeft)
            .toList();

        if (picked.isNotEmpty) {
          final updated = [...state.imagePaths, ...picked].take(3).toList();
          state = state.copyWith(
            imagePaths: updated,
            isPicking: false,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(isPicking: false);
        }
      } else {
        state = state.copyWith(isPicking: false);
      }
    } catch (e) {
      state = state.copyWith(
        isPicking: false,
        errorMessage: 'Unable to pick images: $e',
      );
    }
  }

  /// Removes an attached image at the specified index
  void removeImageAt(int index) {
    if (index >= 0 && index < state.imagePaths.length) {
      final updated = List<String>.from(state.imagePaths)..removeAt(index);
      state = state.copyWith(imagePaths: updated, errorMessage: null);
    }
  }

  /// Removes a specific file path from the attached list
  void removeImage(String path) {
    final updated = state.imagePaths.where((p) => p != path).toList();
    state = state.copyWith(imagePaths: updated, errorMessage: null);
  }

  /// Clears all attached images
  void clearImages() {
    state = state.copyWith(clearAll: true, errorMessage: null);
  }

  /// Sets images directly (capping at 3)
  void setImages(List<String> paths) {
    final capped = paths.where((p) => p.trim().isNotEmpty).take(3).toList();
    state = state.copyWith(imagePaths: capped, isPicking: false, errorMessage: null);
  }

  // --- Backward Compatibility Aliases ---
  Future<void> pickImage() => pickImages();
  void clearImage() => clearImages();
  void setImagePath(String path) => setImages([path]);
}

final eventImageAttachmentProvider = StateNotifierProvider.autoDispose<
    EventImageAttachmentNotifier, EventImageAttachmentState>(
  (ref) => EventImageAttachmentNotifier(),
);
