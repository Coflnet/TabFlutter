import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:table_entry/main.dart';
import 'package:table_entry/pages/about/aboutMain.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footerGlobal.dart';
import 'package:table_entry/pages/settings/settingsMain.dart';

/// Breakpoint at which the layout switches from mobile (bottom nav)
/// to desktop (side navigation rail).
const double kDesktopBreakpoint = 768.0;

/// Maximum content width on large screens to keep text readable.
const double kMaxContentWidth = 900.0;

/// A responsive scaffold that shows a bottom navigation bar on narrow screens
/// and a NavigationRail sidebar on wide screens, with content centered and
/// constrained to [kMaxContentWidth].
class ResponsiveScaffold extends StatelessWidget {
  /// The main page content (should NOT include Background or Footer).
  final Widget body;

  /// Index of the currently selected navigation tab (0=Home, 1=About, 2=Settings).
  final int selectedIndex;

  /// Optional list of overlay widgets rendered above the body (popups, FABs, etc.).
  final List<Widget> overlays;

  /// Whether to apply the maxWidth constraint. Set to false if the page
  /// handles its own width (e.g. full-bleed layouts).
  final bool constrainWidth;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    this.overlays = const [],
    this.constrainWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= kDesktopBreakpoint;

      if (isWide) {
        return _buildWideLayout(context, constraints);
      } else {
        return _buildNarrowLayout(context);
      }
    });
  }

  /// Desktop / tablet layout: side NavigationRail + centered content.
  Widget _buildWideLayout(BuildContext context, BoxConstraints constraints) {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation rail
          _DesktopNavRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _navigateToPage(context, index),
          ),
          // Content area
          Expanded(
            child: Stack(
              children: [
                const Background(),
                Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: kMaxContentWidth),
                    child: body,
                  ),
                ),
                ...overlays,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile layout: full-width content + bottom navigation bar.
  Widget _buildNarrowLayout(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          body,
          ...overlays,
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    if (index == selectedIndex) return;
    FooterGlobal().setSelectedPage = index;
    Haptics.vibrate(HapticsType.medium);
    final Widget page;
    switch (index) {
      case 0:
        page = const Main();
        break;
      case 1:
        page = const AboutMain();
        break;
      case 2:
        page = const SettingsMain();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
        transitionDuration: const Duration(milliseconds: 0),
      ),
    );
  }
}

/// The sidebar NavigationRail shown on wide screens.
class _DesktopNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _DesktopNavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor("1D1E2B"),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        indicatorColor: HexColor("#8332AC").withValues(alpha: 0.2),
        selectedIconTheme: IconThemeData(color: HexColor("#8332AC")),
        unselectedIconTheme:
            const IconThemeData(color: Colors.white30, size: 24),
        selectedLabelTextStyle: TextStyle(
          color: HexColor("#8332AC"),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Colors.white30,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Text(
            '🐝',
            style: const TextStyle(fontSize: 28),
          ),
        ),
        destinations: [
          NavigationRailDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedHome03),
            label: Text(translate("footerHome")),
          ),
          NavigationRailDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedUser),
            label: Text(translate("footerAbout")),
          ),
          NavigationRailDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings01),
            label: Text(translate("footerSettings")),
          ),
        ],
      ),
    );
  }
}
