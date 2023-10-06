//
//  Settings.swift
//  Clicker 2.0
//
//  Created by Dennis Litvinenko on 11/17/20.
//

import Foundation
import Combine

class AppSettings: ObservableObject {
//    @Published var toggleStates: [Bool] {
//        didSet {
//            UserDefaults.standard.set(toggleStates, forKey: "toggleStates")
//        }
//    }
    @Published var keysToClick: String {
        didSet {
            UserDefaults.standard.set(keysToClick, forKey: "keysToClick")
        }
    }

    @Published var keysToClick2: String {
        didSet {
            UserDefaults.standard.set(keysToClick2, forKey: "keysToClick2")
        }
    }
    
    @Published var delay: String {
        didSet {
            UserDefaults.standard.set(delay, forKey: "delay")
        }
    }
    
    @Published var delay2: String {
        didSet {
            UserDefaults.standard.set(delay2, forKey: "delay2")
        }
    }
    
    @Published var mouseDelay: String {
        didSet {
            UserDefaults.standard.set(mouseDelay, forKey: "mouseDelay")
        }
    }
//    @Published var firstHotkey: String {
//        didSet {
//            UserDefaults.standard.set(firstHotkey, forKey: "firstHotkey")
//        }
//    }
//    @Published var secondHotkey: String {
//        didSet {
//            UserDefaults.standard.set(secondHotkey, forKey: "secondHotkey")
//        }
//    }
//    @Published var afkHotkey: String {
//        didSet {
//            UserDefaults.standard.set(afkHotkey, forKey: "afkHotkey")
//        }
//    }
    
    // MARK: - Settings
    
    @Published var showProcesses: Bool {
        didSet {
            UserDefaults.standard.set(showProcesses, forKey: "showProcesses")
        }
    }
//    @Published var compactView: Bool {
//        didSet {
//            UserDefaults.standard.set(compactView, forKey: "compactView")
//        }
//    }
    @Published var smartToggle: Bool {
        didSet {
            UserDefaults.standard.set(smartToggle, forKey: "smartToggle")
        }
    }
    @Published var appSelectionName: String {
        didSet {
            UserDefaults.standard.set(appSelectionName, forKey: "appSelectionName")
        }
    }
    @Published var editing: Bool {
        didSet {
            UserDefaults.standard.set(editing, forKey: "editing")
        }
    }
    @Published var willGreet: Bool {
        didSet {
            UserDefaults.standard.set(willGreet, forKey: "willGreet")
        }
    }
    @Published var willShowUpdateScreen: Bool {
        didSet {
            UserDefaults.standard.set(willShowUpdateScreen, forKey: "willGreet")
        }
    }
    
    init() {
        self.keysToClick = UserDefaults.standard.object(forKey: "keysToClick") as? String ?? "1234"
        self.keysToClick2 = UserDefaults.standard.object(forKey: "keysToClick2") as? String ?? "5"
//        self.toggleStates =  UserDefaults.standard.object(forKey: "toggleStates") as? [Bool] ?? [true,true,true,true,true]
        self.delay = UserDefaults.standard.object(forKey: "delay") as? String ?? "50"
        self.delay2 = UserDefaults.standard.object(forKey: "delay2") as? String ?? "50"
        self.mouseDelay = UserDefaults.standard.object(forKey: "mouseDelay") as? String ?? "10"
        
//        self.firstHotkey = UserDefaults.standard.object(forKey: "firstHotkey") as? String ?? "9"
//        self.secondHotkey = UserDefaults.standard.object(forKey: "secondHotkey") as? String ?? "0"
        //self.afkHotkey = UserDefaults.standard.object(forKey: "afkHotkey") as? String ?? "8"
        
        self.showProcesses = UserDefaults.standard.object(forKey: "showProcesses") as? Bool ?? false
//        self.compactView = UserDefaults.standard.object(forKey: "compactView") as? Bool ?? false
        self.smartToggle = UserDefaults.standard.object(forKey: "smartToggle") as? Bool ?? true
        
        self.appSelectionName = UserDefaults.standard.object(forKey: "appSelectionName") as? String ?? ""
        self.editing = false
        self.willGreet = UserDefaults.standard.object(forKey: "willGreet") as? Bool ?? true
        self.willShowUpdateScreen = UserDefaults.standard.object(forKey: "willShowUpdateScreen") as? Bool ?? true        
    }
    
    public let welcomeMessage = "Press ⌘/ to open help\n\nPress ⌘, to open settings and set hotkeys"
    
    public let updateMessage = "Clicker automatically remembers and reattaches to the app last targeted before it closed. This means that your client/browser must be open before you open Clicker. That way, it will find and attach to the target automagically :)\n\nRelocated hotkey/shortcut recorders to designated preferences pane. This can be access by either pressing (⌘,) or can be found in the menu under the app name next to the  in the top left. Any menu item can be searched for using the menu help search function.\n\nYou can now set hotkeys without any modifier keys (⌃⌥⇧⌘). This allows much simpler toggling especially if mining mid air. Default hotkeys are not set, but this can be changed in settings.\n\nAdded a mouse clicker, set up a keyboard shortcut to activate it in settings.\n\nClicker how has an official App Icon 🥳\n\nFixed bug where application would open in a ugly huge size, and removed application tabbing.\n\nFixed many bugs with hotkeys not working.\n\nFixed bug where changing supplies toggles would still click old settings.\n\nFixed bug where typing in delay boxes would still sometimes toggle the clicker.\n\nFixed crashing when receiving 'Selected app not running' alert and then selecting a different app.\n\nGeneral stability improvements."
}
