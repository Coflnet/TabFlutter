# E2E / Integration Testing

## Overview

TabFlutter has two levels of e2e testing:

1. **Flutter Integration Tests** — Dart-based tests that run the full app inside a real browser with fake audio input.
2. **Playwright Python Tests** — External browser automation tests using Python and Playwright (`test_web_recording.py` in the repo root).

---

## Flutter Integration Tests

### Prerequisites

- Flutter SDK installed (`flutter doctor` passes)
- Chrome installed
- A 16 kHz mono WAV file for fake audio (the repo includes `beispiel_16k_mono.wav` at the project root)

### Running on Chrome (web)

```bash
cd TabFlutter

# Run with mock audio input (headless)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d web-server \
  --web-browser-flag="--headless" \
  --web-browser-flag="--disable-gpu" \
  --web-browser-flag="--use-fake-ui-for-media-stream" \
  --web-browser-flag="--use-fake-device-for-media-stream" \
  --web-browser-flag="--use-file-for-fake-audio-capture=$PWD/../beispiel_16k_mono.wav"
```

### Running with a visible browser (debugging)

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d web-server \
  --web-browser-flag="--use-fake-ui-for-media-stream" \
  --web-browser-flag="--use-fake-device-for-media-stream" \
  --web-browser-flag="--use-file-for-fake-audio-capture=$PWD/../beispiel_16k_mono.wav"
```

### Chrome Flags Explained

| Flag | Purpose |
|---|---|
| `--use-fake-ui-for-media-stream` | Auto-grant microphone permissions without user prompt |
| `--use-fake-device-for-media-stream` | Use a fake audio device instead of real hardware |
| `--use-file-for-fake-audio-capture=<path>` | Feed the specified WAV file as the fake microphone input |
| `--headless` | Run without visible browser window |
| `--disable-gpu` | Required for headless mode on some systems |

### What the tests cover

- **App Smoke**: Verifies the app launches, renders `MaterialApp`, and shows navigation elements.
- **Mic Button**: Taps the recording button to trigger audio capture from the fake WAV file, verifies the audio pipeline doesn't crash.
- **Navigation**: Tests switching between tabs in the bottom/side navigation.

---

## Playwright Python Tests

The Python-based `test_web_recording.py` in the repo root uses Playwright to launch a headless Chromium browser, navigate to the app, and verify that the VAD engine detects speech from the fake audio file.

### Prerequisites

```bash
cd ..
python -m venv test_venv
source test_venv/bin/activate
pip install playwright
playwright install chromium
```

### Running

```bash
# Start the Flutter web app first
cd TabFlutter && flutter run -d web-server --web-port=8765 &

# Then run the test
cd ..
python test_web_recording.py
```

---

## Generating a mock audio file

If you need a new mock WAV file:

```bash
ffmpeg -i your_audio.mp3 -ar 16000 -ac 1 mock_audio.wav
```

The file must be 16 kHz mono PCM WAV for Chrome's fake audio capture to work correctly.
