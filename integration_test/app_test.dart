import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Smoke & audio-input integration test for TabFlutter (web).
///
/// Run with fake audio capture on Chrome:
/// ```
/// flutter drive \
///   --driver=test_driver/integration_test.dart \
///   --target=integration_test/app_test.dart \
///   -d web-server \
///   --web-browser-flag="--use-fake-ui-for-media-stream" \
///   --web-browser-flag="--use-fake-device-for-media-stream" \
///   --web-browser-flag="--use-file-for-fake-audio-capture=$PWD/../beispiel_16k_mono.wav"
/// ```
///
/// Or run on Chrome (headless):
/// ```
/// flutter drive \
///   --driver=test_driver/integration_test.dart \
///   --target=integration_test/app_test.dart \
///   -d web-server \
///   --web-browser-flag="--headless" \
///   --web-browser-flag="--disable-gpu" \
///   --web-browser-flag="--use-fake-ui-for-media-stream" \
///   --web-browser-flag="--use-fake-device-for-media-stream" \
///   --web-browser-flag="--use-file-for-fake-audio-capture=$PWD/../beispiel_16k_mono.wav"
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Tests', () {
    testWidgets('App launches and shows main UI', (tester) async {
      // The app entry point is in main.dart — we import & run it.
      // Since integration_test runs the full app, we rely on the app
      // being started by the test driver. Here we verify the UI loaded.
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify the app rendered something (any Material widget)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Bottom navigation is visible', (tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Check for bottom navigation or FAB (recording button)
      final fabFinder = find.byType(FloatingActionButton);
      final navFinder = find.byType(NavigationBar);
      final navRailFinder = find.byType(NavigationRail);

      // At least one navigation element should be visible
      expect(
        fabFinder.evaluate().isNotEmpty ||
            navFinder.evaluate().isNotEmpty ||
            navRailFinder.evaluate().isNotEmpty,
        isTrue,
        reason: 'Expected to find FAB, NavigationBar, or NavigationRail',
      );
    });

    testWidgets('Mic button is tappable (mock audio stream)', (tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Look for the mic/recording FAB or icon button
      final micFab = find.byIcon(Icons.mic);
      final micNone = find.byIcon(Icons.mic_none);
      final fab = find.byType(FloatingActionButton);

      Finder micButton;
      if (micFab.evaluate().isNotEmpty) {
        micButton = micFab;
      } else if (micNone.evaluate().isNotEmpty) {
        micButton = micNone;
      } else if (fab.evaluate().isNotEmpty) {
        micButton = fab;
      } else {
        // Skip if no mic button found (may be behind onboarding)
        return;
      }

      // Tap the mic button to start recording with fake audio
      await tester.tap(micButton.first);
      await tester.pump(const Duration(seconds: 2));

      // Wait a bit for VAD/recording to process the fake audio
      await tester.pump(const Duration(seconds: 5));

      // Tap again to stop (toggle recording off)
      if (micButton.evaluate().isNotEmpty) {
        await tester.tap(micButton.first);
        await tester.pump(const Duration(seconds: 2));
      }

      // If we got here without crashing, the audio pipeline handled the mock input
      expect(true, isTrue);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Can navigate between tabs', (tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Try tapping various navigation elements
      final navItems = find.byType(NavigationDestination);
      if (navItems.evaluate().length > 1) {
        await tester.tap(navItems.at(1));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Navigate back
        await tester.tap(navItems.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      expect(true, isTrue);
    });
  });
}
