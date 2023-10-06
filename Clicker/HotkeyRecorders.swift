//
//  HotkeyRecorders.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 5/18/21.
//

import SwiftUI
import Combine

enum Hotkey {
    //public static var editing = false
    private static var appSettings = AppSettings()
    private static var recording = false
    private static var eventHandlers = [String : () -> Void]()
    
    public static func startMonitoring() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            print("Keydown global \(event.keyCode)")
            if event.isARepeat { return }
            
            // Will call matching closure if event is keycommmand
            _ = performActionIfEventIsKeyCommand(event: event, sender: "global")
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event -> NSEvent? in
            //print("Key\(event.type == .keyDown ? "down" : "up") local \(event.keyCode.description)")
            if isEditing() {
                return event
            }
            if event.isARepeat { return nil }

            if !recording {
                // Will call matching closure if event is keycommmand
                return performActionIfEventIsKeyCommand(event: event)
            }
            return event
        })
    }
    
    public static func performActionIfEventIsKeyCommand(event: NSEvent, sender: String = "local") -> NSEvent? {
        for (eventName, handler) in eventHandlers {
            guard let keyCommand = UserDefaults.standard.object(forKey: "\(eventName)-Hotkey") as? String else {
                print("Failed to fetch key command for \(eventName)")
                return event
            }
            let commmand = getKeyCommand(from: keyCommand)

            if event.keyCode == commmand.keyCode {
                if !event.modifierFlags.isEmpty && event.modifierFlags.description == commmand.modifiers {
                    print("\(event.modifierFlags.description+(keycodeString[event.keyCode] ?? "unkown char")) matches \(commmand.keyCode)")
                    print("Detected from \(sender)")
                    handler()
                    return nil
                }
            }
        }
        return event
    }
    
    private static func isEditing() -> Bool {
        return NSApp.keyWindow?.firstResponder?.superclass?.description() == "NSTextView"
    }
//    public static func isRecording() -> Bool {
//        return recording
//    }

    private static func getKeyCommand(from string: String) -> (modifiers: String, keyCode: UInt16) {
        var modifiers = String()
        var bindedKey = UInt16()

        for char in string {
            if "⌃⌥⇧⌘".contains(String(char)) {
                modifiers += String(char)
            } else {
                bindedKey = keycodeString.key(for: String(char)) ?? 0xFF
            }
        }
        return (modifiers, bindedKey)
    }
    
    public struct Name: Hashable {
        public let rawValue: String

        public init(_ name: String) {
            self.rawValue = name
        }
    }
    
    public static func onKeyDown(for name: Name, action: @escaping () -> Void) {
        eventHandlers[name.rawValue] = action
    }
    
    public struct Recorder: View {
        var name: Name
        var defaultKeyCommand: String? = nil
        
        var body: some View {
            HotkeyRecorder(named: name.rawValue, defaultKeyCommand: defaultKeyCommand)
        }
    }
    
    private struct HotkeyRecorder: View {
        @ObservedObject var appSettings = AppSettings()
        var named: String
        
        @State var defaultKeyCommand: String? = nil
        @State private var recording = false {
            didSet {
                Hotkey.recording = self.recording
            }
        }
        @State private var keyCommand: String? {
            didSet {
                if keyCommand == nil {
                    UserDefaults.standard.removeObject(forKey: "\(named)-Hotkey")
                } else {
                    UserDefaults.standard.set(keyCommand, forKey: "\(named)-Hotkey")
                }
            }
        }
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(.controlBackgroundColor))
                    .frame(width: 120, height: 18)
                    .onTapGesture {
                        withAnimation { recording = true }
                    }
                    .onHover { isHovering in
                        if !isHovering {
                            withAnimation { recording = isHovering }
                        }
                    }
                HStack(alignment: .center) {
                    Text(keyCommand == nil ? "\(recording ? "Press" : "Record") Shortcut" : keyCommand!)
                        .foregroundColor(keyCommand == nil ? Color(.secondaryLabelColor) : Color(.labelColor))
                        .onTapGesture {
                            withAnimation { recording = true }
                        }
                        .onHover { isHovering in
                            if !isHovering {
                                withAnimation { recording = isHovering }
                            }
                        }
                    if keyCommand != nil {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.labelColor))
                            .onTapGesture {
                                keyCommand = nil
                            }
                    }
                }
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(lineWidth: 1.5)
                    .frame(width: 120, height: 20)
                    .foregroundColor(recording ? Color(.systemTeal) : Color(.tertiaryLabelColor))
            }
            .onAppear {
                keyCommand = UserDefaults.standard.object(forKey: "\(named)-Hotkey") as? String ?? defaultKeyCommand ?? nil
                setupLocalMonitoring()
            }
        }
        
        func setupLocalMonitoring() {
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp], handler: { event -> NSEvent? in
                if isEditing() { return event }
                if event.isARepeat { return nil }
                
                if event.type == .keyUp || event.keyCode == 53 {
                    recording = false
                    return nil
                }
                
                if !recording {
                    return event
                }
                
                guard let character = keycodeString[event.keyCode] else {
                    print("Invalid keycommand")
                    return event
                }
                keyCommand = event.modifierFlags.description+character
                return nil
            })
        }
    }
}

extension Hotkey.Name: RawRepresentable {
    public init?(rawValue: String) {
        self.init(rawValue)
    }
}

extension Dictionary where Value: Equatable {
    func key(for value: Value) -> Key? {
        return first(where: { $1 == value })?.key
    }
}

extension NSEvent.ModifierFlags {
    var description: String {
        var description = ""

        if contains(.control) {
            description += "⌃"
        }

        if contains(.option) {
            description += "⌥"
        }

        if contains(.shift) {
            description += "⇧"
        }

        if contains(.command) {
            description += "⌘"
        }

        return description
    }
}
