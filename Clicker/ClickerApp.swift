//
//  ClickerApp.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 3/31/21.
//

import SwiftUI

@main
struct ClickerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var appSettings = AppSettings()
    @State private var helpOpened = false
    @State private var timers = (first: DispatchSource.makeTimerSource(queue: .main),
                                 second: DispatchSource.makeTimerSource(queue: .main),
                                 third: DispatchSource.makeTimerSource(queue: .main),
                                 fourth: DispatchSource.makeTimerSource(queue: .main),
                                 fifth: DispatchSource.makeTimerSource(queue: .main))
    
    var body: some Scene {
        WindowGroup {
            ContentView(timers: $timers)
                .frame(width: 450, height: 165)
                .frame(maxWidth: appSettings.compactView ? 130 : .infinity, maxHeight: .infinity)
        }
        .commands {
            CommandMenu("Menu") {
                Button((appSettings.showProcesses ? "Hide" : "Show")+" all processes") {
                    appSettings.showProcesses.toggle()
                }
                .keyboardShortcut("1")
                Button((appSettings.compactView ? "Hide" : "Show")+" compact view") {
                    appSettings.compactView.toggle()
                }
                .keyboardShortcut("2")
                Button((appSettings.smartToggles ? "Disable" : "Enable")+" smart toggles") {
                    appSettings.smartToggles.toggle()
                }
                .keyboardShortcut("3")
                #if DEBUG
                Divider()
                Button("Resize Window") {
                    NotificationCenter.default.post(name: NSNotification.Name("setWindowSize"), object: nil)
                }
                Button("Reset User defaults") {
                    UserDefaults.reset()
                }
                #endif
            }
            CommandGroup(replacing: .help) {
                Button(action: {
                    if !helpOpened {
                        helpOpened.toggle()
                        HelpView(isOpen: $helpOpened).openNewWindow(with: "Help")
                    }
                }, label: {
                    Text("Clicker Help")
                })
                .keyboardShortcut("/")
            }
            CommandGroup(replacing: .newItem, addition: {})
            CommandGroup(replacing: .pasteboard, addition: {})
            CommandGroup(replacing: .undoRedo, addition: {})
        }
        
        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var didSetWindowSize = false
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.window = NSApp.mainWindow
        
        if !didSetWindowSize {
            setWindowSize()
            didSetWindowSize.toggle()
            
            if UserDefaults.standard.object(forKey: "displayedWelcomeMessages") as? Bool == nil {
                let alert1 = NSAlert()
                alert1.messageText = "Welcome to Clicker"
                alert1.informativeText = AppSettings().welcomeMessage
                alert1.runModal()
                
                let alert2 = NSAlert()
                alert2.messageText = "New this update"
                alert2.informativeText = AppSettings().updateMessage
                alert2.runModal()
                
                UserDefaults.standard.setValue(true, forKey: "displayedWelcomeMessages")
            }
        }
    }
    
//    func applicationDidUpdate(_ notification: Notification) {
//        guard let mainWindow = NSApp.mainWindow else {
//            print("Cannot get height")
//            return
//        }
//        if mainWindow.frame.height == 228 && !AppSettings().compactView {
//            setWindowSize()
//        }
//    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        NotificationCenter.default.addObserver(self, selector: #selector(setWindowSize), name: NSNotification.Name("setWindowSize"), object: nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        UserDefaults.standard.removeObject(forKey: "NSWindow Frame Main Window")
        return true
    }
    
    @objc func setWindowSize() {
        window?.setContentSize(NSSize(width: 450, height: 180))
    }
}

extension View {
    private func newWindowInternal(with title: String) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 20, y: 20, width: 320, height: 420),
            styleMask: [.titled, .miniaturizable, .resizable, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        window.center()
        window.isReleasedWhenClosed = false
        window.title = title
        window.makeKeyAndOrderFront(nil)
        return window
    }
    
    func openNewWindow(with title: String = "new Window") {
        self.newWindowInternal(with: title).contentView = NSHostingView(rootView: self)
    }
}

extension UserDefaults {
    static func reset() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
