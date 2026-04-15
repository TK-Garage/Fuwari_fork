//
//  MenuManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/25.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Magnet
import Sauce

class MenuManager: NSObject {

    static let shared = MenuManager()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private var captureItem = NSMenuItem()
    private var ocrCaptureItem = NSMenuItem()

    func configure() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
        }

        captureItem = NSMenuItem(title: LocalizedString.Capture.value, action: #selector(AppDelegate.capture), keyEquivalent: HotKeyManager.shared.captureKeyCombo.characters.lowercased())
        captureItem.keyEquivalentModifierMask = HotKeyManager.shared.captureKeyCombo.modifiers.convertSupportCocoaModifiers()

        ocrCaptureItem = NSMenuItem(title: LocalizedString.OCRCapture.value, action: #selector(AppDelegate.captureForOCR), keyEquivalent: "")
        applyOCRCaptureKeyEquivalent()

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: LocalizedString.About.value, action: #selector(AppDelegate.openAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.Preference.value, action: #selector(AppDelegate.openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(captureItem)
        menu.addItem(ocrCaptureItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.QuitFuwari.value, action: #selector(AppDelegate.quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    func updateCaptureMenuItem() {
        captureItem.keyEquivalent = HotKeyManager.shared.captureKeyCombo.characters.lowercased()
        captureItem.keyEquivalentModifierMask = HotKeyManager.shared.captureKeyCombo.modifiers.convertSupportCocoaModifiers()
    }

    func updateOCRCaptureMenuItem() {
        applyOCRCaptureKeyEquivalent()
    }

    private func applyOCRCaptureKeyEquivalent() {
        if let keyCombo = HotKeyManager.shared.ocrCaptureKeyCombo {
            ocrCaptureItem.keyEquivalent = keyCombo.characters.lowercased()
            ocrCaptureItem.keyEquivalentModifierMask = keyCombo.modifiers.convertSupportCocoaModifiers()
        } else {
            ocrCaptureItem.keyEquivalent = ""
            ocrCaptureItem.keyEquivalentModifierMask = []
        }
    }
}
