//
//  TrayMenu.swift
//  tray_manager
//
//  Created by Lijy91 on 2022/5/8.
//

import AppKit

public class TrayMenu: NSMenu, NSMenuDelegate {
    public var onMenuItemClick:((NSMenuItem) -> Void)?
    
    private static let menuIconSize = NSSize(width: 16, height: 16)

    // Parse a macOS-style shortcut hint like "⌘⇧Space" or "⌘Q" into
    // NSMenuItem.keyEquivalent + modifier mask so the system renders it
    // right-aligned and in the standard (light gray) style.
    private static func parseKeyEquivalent(from hint: String) -> (String, NSEvent.ModifierFlags)? {
        var s = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return nil }

        var modifiers: NSEvent.ModifierFlags = []

        // Consume modifier symbols from the front.
        while true {
            if s.hasPrefix("⌘") {
                modifiers.insert(.command)
                s.removeFirst(1)
                continue
            }
            if s.hasPrefix("⇧") {
                modifiers.insert(.shift)
                s.removeFirst(1)
                continue
            }
            if s.hasPrefix("⌥") {
                modifiers.insert(.option)
                s.removeFirst(1)
                continue
            }
            if s.hasPrefix("⌃") {
                modifiers.insert(.control)
                s.removeFirst(1)
                continue
            }
            if s.lowercased().hasPrefix("fn") {
                modifiers.insert(.function)
                s.removeFirst(2)
                continue
            }
            if s.hasPrefix("⇪") {
                modifiers.insert(.capsLock)
                s.removeFirst(1)
                continue
            }
            break
        }

        let keyLabel = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyLabel.isEmpty { return nil }

        // Map common keys.
        if keyLabel.caseInsensitiveCompare("Space") == .orderedSame {
            return (" ", modifiers)
        }

        // Single character keys (Q, K, 1, etc).
        if keyLabel.count == 1 {
            return (keyLabel.lowercased(), modifiers)
        }

        // Fallback: unsupported key name.
        return nil
    }
    
    private static func loadMenuItemImage(from itemDict: [String: Any]) -> NSImage? {
        if let base64Icon = itemDict["base64Icon"] as? String,
           let data = Data(base64Encoded: base64Icon),
           let image = NSImage(data: data) {
            image.size = menuIconSize
            return image
        }
        // Fallback: treat `icon` as an absolute file path if provided.
        if let iconPath = itemDict["icon"] as? String,
           !iconPath.isEmpty,
           FileManager.default.fileExists(atPath: iconPath),
           let image = NSImage(contentsOfFile: iconPath) {
            image.size = menuIconSize
            return image
        }
        return nil
    }
    
    public override init(title: String) {
        super.init(title: title)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(_ args: [String: Any]) {
        super.init(title: "")
        
        let items: [NSDictionary] = args["items"] as! [NSDictionary];
        for item in items {
            let menuItem: NSMenuItem
            
            let itemDict = item as! [String: Any]
            let id: Int = itemDict["id"] as! Int
            let type: String = itemDict["type"] as! String
            let label: String = itemDict["label"] as? String ?? ""
            let shortcut: String = itemDict["shortcut"] as? String ?? ""
            let toolTip: String = itemDict["toolTip"] as? String ?? ""
            let checked: Bool? = itemDict["checked"] as? Bool
            let disabled: Bool = itemDict["disabled"] as? Bool ?? true
            
            if (type == "separator") {
                menuItem = NSMenuItem.separator()
            } else {
                menuItem = NSMenuItem()
            }
            
            menuItem.tag = id
            menuItem.title = label
            menuItem.toolTip = toolTip
            if let image = TrayMenu.loadMenuItemImage(from: itemDict) {
                menuItem.image = image
            }

            if !shortcut.isEmpty, let parsed = TrayMenu.parseKeyEquivalent(from: shortcut) {
                menuItem.keyEquivalent = parsed.0
                menuItem.keyEquivalentModifierMask = parsed.1
            }

            menuItem.isEnabled = !disabled
            menuItem.action = !disabled ? #selector(statusItemMenuButtonClicked) : nil
            menuItem.target = self
            
            switch (type) {
            case "separator":
                break
            case "submenu":
                if let submenuDict = itemDict["submenu"] as? NSDictionary {
                    let submenu = TrayMenu(submenuDict as! [String : Any])
                    submenu.onMenuItemClick = { [weak self] (menuItem: NSMenuItem) in
                        guard let strongSelf = self else { return }
                        strongSelf.statusItemMenuButtonClicked(menuItem)
                    }
                    self.setSubmenu(submenu, for: menuItem)
                }
                break
            case "checkbox":
                if (checked == nil) {
                    menuItem.state = .mixed
                } else {
                    menuItem.state = checked! ? .on : .off
                }
                break
            default:
                break
            }
            self.addItem(menuItem)
        }
        self.delegate = self
    }
    
    @objc func statusItemMenuButtonClicked(_ sender: Any?) {
        if (sender is NSMenuItem && onMenuItemClick != nil) {
            let menuItem = sender as! NSMenuItem
            self.onMenuItemClick!(menuItem)
        }
    }
    
    // NSMenuDelegate
    
    public func menuDidClose(_ menu: NSMenu) {
        
    }
}
