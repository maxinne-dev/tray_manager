import 'package:flutter_test/flutter_test.dart';
import 'package:tray_manager/tray_manager.dart';

void main() {
  group('TrayMenuItem', () {
    test('toJson includes shortcut when provided', () {
      final item = TrayMenuItem(
        key: 'show_window',
        label: 'Assistant',
        shortcut: '⌘⇧Space',
      );

      final json = item.toJson();
      expect(json['label'], 'Assistant');
      expect(json['shortcut'], '⌘⇧Space');
    });

    test('toJson omits shortcut when null/empty', () {
      final item = TrayMenuItem(key: 'x', label: 'X');
      expect(item.toJson().containsKey('shortcut'), isFalse);
    });
  });
}


