import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

/// Available UI scaling modes
enum UiScaleMode {
  auto,
  scale75,
  scale80,
  scale85,
  scale90,
  scale100,
  scale110,
  scale125,
}

extension UiScaleModeExtension on UiScaleMode {
  String get label {
    switch (this) {
      case UiScaleMode.auto:
        return 'Auto (Fit Screen)';
      case UiScaleMode.scale75:
        return '75% (Ultra Compact)';
      case UiScaleMode.scale80:
        return '80% (Compact)';
      case UiScaleMode.scale85:
        return '85% (Laptop Standard)';
      case UiScaleMode.scale90:
        return '90% (Balanced)';
      case UiScaleMode.scale100:
        return '100% (Original)';
      case UiScaleMode.scale110:
        return '110% (Large)';
      case UiScaleMode.scale125:
        return '125% (Extra Large)';
    }
  }

  String get shortLabel {
    switch (this) {
      case UiScaleMode.auto:
        return 'Auto';
      case UiScaleMode.scale75:
        return '75%';
      case UiScaleMode.scale80:
        return '80%';
      case UiScaleMode.scale85:
        return '85%';
      case UiScaleMode.scale90:
        return '90%';
      case UiScaleMode.scale100:
        return '100%';
      case UiScaleMode.scale110:
        return '110%';
      case UiScaleMode.scale125:
        return '125%';
    }
  }

  double? get fixedValue {
    switch (this) {
      case UiScaleMode.auto:
        return null;
      case UiScaleMode.scale75:
        return 0.75;
      case UiScaleMode.scale80:
        return 0.80;
      case UiScaleMode.scale85:
        return 0.85;
      case UiScaleMode.scale90:
        return 0.90;
      case UiScaleMode.scale100:
        return 1.00;
      case UiScaleMode.scale110:
        return 1.10;
      case UiScaleMode.scale125:
        return 1.25;
    }
  }
}

/// Global state managing UI zoom and DPI auto-fitting across diverse Windows screen resolutions
class UiScaleState extends ChangeNotifier {
  static final UiScaleState instance = UiScaleState._();
  factory UiScaleState() => instance;

  UiScaleState._() {
    _loadPreference();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  static const String _prefKey = 'ydc_erp_ui_scale_mode';
  static const String _customScaleKey = 'ydc_erp_ui_scale_custom';

  UiScaleMode _mode = UiScaleMode.auto;
  double _customScale = 0.85;
  double _lastComputedAuto = 0.85;

  UiScaleMode get mode => _mode;
  double get customScale => _customScale;
  double get lastComputedAuto => _lastComputedAuto;

  double get effectiveScale {
    if (_mode == UiScaleMode.auto) {
      return _lastComputedAuto;
    }
    return _mode.fixedValue ?? _customScale;
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeName = prefs.getString(_prefKey);
      final savedScale = prefs.getDouble(_customScaleKey);
      if (savedScale != null) {
        _customScale = savedScale;
      }
      if (modeName != null) {
        _mode = UiScaleMode.values.firstWhere(
          (m) => m.name == modeName,
          orElse: () => UiScaleMode.auto,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[UiScaleState] Load preference notice: $e');
    }
  }

  Future<void> _savePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _mode.name);
      await prefs.setDouble(_customScaleKey, _customScale);
    } catch (e) {
      debugPrint('[UiScaleState] Save preference notice: $e');
    }
  }

  /// Calculates the optimal scaling factor for the given screen/window bounds
  double computeEffectiveScale(double windowWidth, double windowHeight) {
    if (_mode != UiScaleMode.auto) {
      return _mode.fixedValue ?? _customScale;
    }

    // Baseline reference: designed for ~1340px width and ~830px height
    final scaleH = windowHeight / 830.0;
    final scaleW = windowWidth / 1340.0;

    double scale = scaleH < scaleW ? scaleH : scaleW;

    if (scale >= 0.98) {
      scale = 1.0;
    } else if (scale < 0.75) {
      scale = 0.75;
    } else {
      scale = (scale * 50).round() / 50.0;
    }

    _lastComputedAuto = scale;
    return scale;
  }

  void setMode(UiScaleMode mode) {
    _mode = mode;
    _savePreference();
    notifyListeners();
  }

  void zoomIn() {
    final current = effectiveScale;
    final next = (current + 0.05).clamp(0.70, 1.30);
    _customScale = (next * 20).round() / 20.0;
    _matchCustomToPreset();
    _savePreference();
    notifyListeners();
  }

  void zoomOut() {
    final current = effectiveScale;
    final next = (current - 0.05).clamp(0.70, 1.30);
    _customScale = (next * 20).round() / 20.0;
    _matchCustomToPreset();
    _savePreference();
    notifyListeners();
  }

  void resetZoom() {
    _mode = UiScaleMode.auto;
    _savePreference();
    notifyListeners();
  }

  void _matchCustomToPreset() {
    if ((_customScale - 0.75).abs() < 0.02) {
      _mode = UiScaleMode.scale75;
    } else if ((_customScale - 0.80).abs() < 0.02) {
      _mode = UiScaleMode.scale80;
    } else if ((_customScale - 0.85).abs() < 0.02) {
      _mode = UiScaleMode.scale85;
    } else if ((_customScale - 0.90).abs() < 0.02) {
      _mode = UiScaleMode.scale90;
    } else if ((_customScale - 1.00).abs() < 0.02) {
      _mode = UiScaleMode.scale100;
    } else if ((_customScale - 1.10).abs() < 0.02) {
      _mode = UiScaleMode.scale110;
    } else if ((_customScale - 1.25).abs() < 0.02) {
      _mode = UiScaleMode.scale125;
    } else {
      _mode = UiScaleMode.scale85;
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrl = HardwareKeyboard.instance.isControlPressed;
      if (isCtrl) {
        if (event.logicalKey == LogicalKeyboardKey.equal ||
            event.logicalKey == LogicalKeyboardKey.add) {
          zoomIn();
          return true;
        } else if (event.logicalKey == LogicalKeyboardKey.minus ||
            event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
          zoomOut();
          return true;
        } else if (event.logicalKey == LogicalKeyboardKey.digit0 ||
            event.logicalKey == LogicalKeyboardKey.numpad0) {
          resetZoom();
          return true;
        }
      }
    }
    return false;
  }
}

final uiScaleState = UiScaleState();

/// Scaled viewport wrapper that fits the entire application cleanly onto any screen
class UiScaleWrapper extends StatelessWidget {
  final Widget child;

  const UiScaleWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: uiScaleState,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedSize =
                constraints.hasBoundedWidth && constraints.hasBoundedHeight;
            if (!hasBoundedSize) {
              return SizedBox.expand(
                child: ColoredBox(
                  color: AppColors.surfaceBg,
                  child: child,
                ),
              );
            }

            final double scale = uiScaleState.computeEffectiveScale(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            if ((scale - 1.0).abs() < 0.005) {
              return SizedBox.expand(
                child: ColoredBox(
                  color: AppColors.surfaceBg,
                  child: child,
                ),
              );
            }

            final scaledWidth = constraints.maxWidth / scale;
            final scaledHeight = constraints.maxHeight / scale;

            final currentMq = MediaQuery.of(context);
            final adjustedMq = currentMq.copyWith(
              size: Size(scaledWidth, scaledHeight),
            );

            return SizedBox.expand(
              child: ColoredBox(
                color: AppColors.surfaceBg,
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: scaledWidth,
                    height: scaledHeight,
                    child: MediaQuery(
                      data: adjustedMq,
                      child: ColoredBox(
                        color: AppColors.surfaceBg,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
