import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footer.dart';
import 'package:table_entry/pages/reusedWidgets/responsive_scaffold.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsMain.dart';
import 'package:table_entry/pages/settings/export/settingExportMain.dart';
import 'package:table_entry/pages/settings/settingsHeader.dart';
import 'package:table_entry/pages/settings/settingsPopup/settingsPopupMain.dart';
import 'package:table_entry/pages/settings/integrationSettingsPage.dart';

class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});

  @override
  _SettingsMainState createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  bool popupVisible = false;
  int popupSelected = 1;

  @override
  Widget build(BuildContext context) {
    final settingsContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SettingsHeader(),
            const SizedBox(height: 35),
            // Data I/O section: Export + Integrations
            SettingExportMain(exportPopup: popup),
            const SizedBox(height: 12),
            // Integrations button (next to export — both are data I/O)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const IntegrationSettingsPage()),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B3D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.extension, color: Color(0xFF9333EA)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        translate('integrations'),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ColumnSettingsMain(popup: popup),
            const SizedBox(height: 100), // Space for footer
          ],
        ),
      ),
    );

    final popupOverlay = Visibility(
        visible: popupVisible,
        child: SettingsPopupMain(
            isShowing: popupVisible,
            closePopup: closePopup,
            selectedPopup: popupSelected));

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= kDesktopBreakpoint) {
        return ResponsiveScaffold(
          selectedIndex: 2,
          body: settingsContent,
          overlays: [popupOverlay],
        );
      }
      return Scaffold(
        body: Stack(
          children: [
            const Background(),
            settingsContent,
            const Footer(),
            popupOverlay,
          ],
        ),
      );
    });
  }

  void closePopup() {
    setState(() {
      popupVisible = false;
    });
  }

  void popup(int select) {
    setState(() {
      popupSelected = select;
      popupVisible = !popupVisible;
    });
  }
}
