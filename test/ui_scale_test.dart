import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydc_aust/core/ui/ui_scale_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UI Scaling & Screen Fit Unit Tests', () {
    test('Calculates adaptive scale for standard 768p and 720p laptop resolutions', () {
      final scaleState = UiScaleState.instance;

      // Reset to auto
      scaleState.setMode(UiScaleMode.auto);

      // Standard 1366x768 monitor (usable height ~700px)
      final scale768p = scaleState.computeEffectiveScale(1366, 700);
      expect(scale768p, lessThanOrEqualTo(0.86));
      expect(scale768p, greaterThanOrEqualTo(0.75));

      // 1080p with 150% scaling (1280x720, usable height ~650px)
      final scale720p = scaleState.computeEffectiveScale(1280, 650);
      expect(scale720p, lessThanOrEqualTo(0.82));
      expect(scale720p, greaterThanOrEqualTo(0.75));

      // Large 1080p/1440p desktop (1920x1080, height ~950px)
      final scale1080p = scaleState.computeEffectiveScale(1920, 950);
      expect(scale1080p, equals(1.0));
    });

    test('Fixed scale modes return exact preset values', () {
      final scaleState = UiScaleState.instance;

      scaleState.setMode(UiScaleMode.scale75);
      expect(scaleState.effectiveScale, equals(0.75));

      scaleState.setMode(UiScaleMode.scale85);
      expect(scaleState.effectiveScale, equals(0.85));

      scaleState.setMode(UiScaleMode.scale100);
      expect(scaleState.effectiveScale, equals(1.00));

      scaleState.setMode(UiScaleMode.scale110);
      expect(scaleState.effectiveScale, equals(1.10));
    });

    test('Zoom in and zoom out increment and decrement scale factor', () {
      final scaleState = UiScaleState.instance;

      scaleState.setMode(UiScaleMode.scale85);
      expect(scaleState.effectiveScale, equals(0.85));

      scaleState.zoomIn();
      expect(scaleState.effectiveScale, equals(0.90));

      scaleState.zoomOut();
      expect(scaleState.effectiveScale, equals(0.85));

      scaleState.resetZoom();
      expect(scaleState.mode, equals(UiScaleMode.auto));
    });

    testWidgets('UiScaleWrapper renders child successfully at scaled dimensions', (tester) async {
      final scaleState = UiScaleState.instance;
      scaleState.setMode(UiScaleMode.scale85);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => UiScaleWrapper(child: child!),
          home: const Scaffold(
            body: Text('YDC ERP Scaling Test'),
          ),
        ),
      );

      expect(find.text('YDC ERP Scaling Test'), findsOneWidget);
    });

    testWidgets('UiScaleWrapper expands child to full vertical height when scaled', (tester) async {
      final scaleState = UiScaleState.instance;
      scaleState.setMode(UiScaleMode.scale75);

      // Fixed test viewport of 800 x 600
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Size? receivedConstraints;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => UiScaleWrapper(child: child!),
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                receivedConstraints = Size(constraints.maxWidth, constraints.maxHeight);
                return const Column(
                  children: [
                    Text('Top Header'),
                    Spacer(),
                    Text('Bottom Footer'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Top Header'), findsOneWidget);
      expect(find.text('Bottom Footer'), findsOneWidget);

      // At scale 0.75, child should receive scaled constraints (800 / 0.75 = 1066.67, 600 / 0.75 = 800)
      expect(receivedConstraints, isNotNull);
      expect(receivedConstraints!.height, closeTo(600 / 0.75, 1.0));
      expect(receivedConstraints!.width, closeTo(800 / 0.75, 1.0));

      // The Bottom Footer should be positioned at the bottom of the window (near y = 600)
      final footerBottom = tester.getBottomLeft(find.text('Bottom Footer')).dy;
      expect(footerBottom, greaterThan(500.0));
    });
  });
}
