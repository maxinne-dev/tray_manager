import 'package:menu_base/menu_base.dart';

/// A tray menu item with an explicit shortcut/hotkey hint.
///
/// On macOS this is rendered using NSMenuItem.keyEquivalent so it appears
/// right-aligned and in the system default (light gray) style.
///
/// Other platforms may ignore this field.
class TrayMenuItem extends MenuItem {
  /// Shortcut hint string (macOS style), e.g. "⌘⇧Space" or "⌘Q".
  final String? shortcut;

  TrayMenuItem({
    super.key,
    super.type = 'normal',
    super.label,
    super.toolTip,
    super.icon,
    super.checked,
    super.disabled = false,
    super.submenu,
    super.onClick,
    super.onHighlight,
    super.onLoseHighlight,
    this.shortcut,
  });

  @override
  Map<String, dynamic> toJson() {
    final m = super.toJson();
    final s = shortcut;
    if (s != null && s.isNotEmpty) {
      m['shortcut'] = s;
    }
    return m;
  }
}
