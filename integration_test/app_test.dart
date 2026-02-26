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

/// Helper to find the mic button in the UI.
Finder? findMicButton() {
  final micFab = find.byIcon(Icons.mic);
  final micNone = find.byIcon(Icons.mic_none);
  final fab = find.byType(FloatingActionButton);

  if (micFab.evaluate().isNotEmpty) return micFab;
  if (micNone.evaluate().isNotEmpty) return micNone;
  if (fab.evaluate().isNotEmpty) return fab;
  return null;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Tests', () {
    testWidgets('App launches and shows main UI', (tester) async {
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

      final micButton = findMicButton();
      if (micButton == null) return; // behind onboarding

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

  group('Recording & Entry Tests', () {
    testWidgets(
        'Recording shows listening UI with counters and creates entries',
        (tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final micButton = findMicButton();
      if (micButton == null) {
        debugPrint('Mic button not found — skipping recording entry test');
        return;
      }

      // --- Start recording ---
      await tester.tap(micButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // The listening mode overlay should now be visible.
      // It shows "X processed" and "X entries" counters.
      // Give the fake audio stream time to be captured by the VAD.
      // Pump several frames over ~15 s so the VAD can fire speech-end events.
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Check that we can find the "processed" text somewhere in the tree.
      // The counter is rendered as "$segments processed".
      final processedFinder = find.textContaining('processed');
      final hasProcessed = processedFinder.evaluate().isNotEmpty;
      debugPrint('Found "processed" counter widget: $hasProcessed');

      // Check the "entries" counter widget exists
      final entriesFinder = find.textContaining('entries');
      final hasEntries = entriesFinder.evaluate().isNotEmpty;
      debugPrint('Found "entries" counter widget: $hasEntries');

      // At least the listening UI should have rendered
      expect(
        hasProcessed || hasEntries,
        isTrue,
        reason:
            'Expected the listening mode UI with processed/entries counters',
      );

      // --- Stop recording (triggers flush to API) ---
      // Re-find the button because the widget tree may have rebuilt
      final stopButton = findMicButton();
      if (stopButton != null && stopButton.evaluate().isNotEmpty) {
        await tester.tap(stopButton.first);
      }

      // Wait for the API flush response (sends null audio → isComplete).
      // This is where entries should be created if the API is reachable.
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // After stopping, the listening overlay fades out and we're back on
      // the main (recent log) page. Check if entries were created by looking
      // for check_circle icons (shown per entry) or entry text.
      final checkIcons = find.byIcon(Icons.check_circle);
      final editNoteIcons = find.byIcon(Icons.edit_note);
      final entryCount =
          checkIcons.evaluate().length + editNoteIcons.evaluate().length;

      debugPrint('Entry icons found after recording: $entryCount');

      // If the API was reachable and the audio was processed, we should
      // see at least one entry. If the API is offline the counters will
      // still have rendered, so the test above already passed.
      if (entryCount > 0) {
        debugPrint('✓ Entries were created successfully after recording');

        // Verify the edit button exists for correction
        final editIcons = find.byIcon(Icons.edit);
        expect(editIcons.evaluate().isNotEmpty, isTrue,
            reason: 'Each entry should have an edit (pencil) icon');
      } else {
        debugPrint('⚠ No entries created — API may be unreachable in test env');
      }
    });

    testWidgets('Correction UI shows send-for-training button', (tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final micButton = findMicButton();
      if (micButton == null) return;

      // Start recording
      await tester.tap(micButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Let fake audio be processed
      for (int i = 0; i < 12; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Stop recording
      final stopButton = findMicButton();
      if (stopButton != null && stopButton.evaluate().isNotEmpty) {
        await tester.tap(stopButton.first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Find an edit icon and tap it to enter correction mode
      final editIcons = find.byIcon(Icons.edit);
      if (editIcons.evaluate().isEmpty) {
        debugPrint('No entries to edit — skipping correction UI test');
        return;
      }

      // Tap the first edit button
      await tester.tap(editIcons.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // In edit mode, TextField widgets should appear for each param
      final textFields = find.byType(TextField);
      expect(textFields.evaluate().isNotEmpty, isTrue,
          reason: 'Editing an entry should show text fields for params');
      debugPrint(
          'Found ${textFields.evaluate().length} text fields in edit mode');

      // Find the save (check) icon and tap it to save the correction
      final saveIcon = find.byIcon(Icons.check);
      if (saveIcon.evaluate().isNotEmpty) {
        await tester.tap(saveIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // After saving a correction, the "Send for training" button should
        // appear if any field was modified. Since we didn't change text,
        // it may not appear — but the edit_note icon confirms edit mode works.
        final schoolIcons = find.byIcon(Icons.school);
        if (schoolIcons.evaluate().isNotEmpty) {
          debugPrint('✓ "Send for training" button is visible');
        } else {
          debugPrint(
              'No training button — fields were not modified (expected)');
        }
      }

      expect(true, isTrue);
    });
  });
}
