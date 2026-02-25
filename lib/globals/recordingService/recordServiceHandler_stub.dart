// Web stub — foreground task recording is not supported on web
import 'package:flutter/widgets.dart';

@pragma('vm:entry-point')
void startRecordService() {
  // No-op on web: foreground recording service is mobile-only
  WidgetsFlutterBinding.ensureInitialized();
}
