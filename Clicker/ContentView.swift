//
//  ContentView.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 5/6/21.
//
// TODO:
//  - Add App Icon

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var selection = "Stopped"
    @State private var isClicking = (first: false, second: false, afk: false, sideA: false, sideB: false, mouse: false)
    @State private var showsAppNotFoundAlert = false
    @State private var showsNoPermissionsAlert = false
    @State private var cycles = 0
    @State private var appSelection = 0
    @State private var runningApplications = [NSRunningApplication]()
    @State private var setMouseLocation: CGPoint = .zero
    @Binding var timers: (first: DispatchSourceTimer, second: DispatchSourceTimer, third: DispatchSourceTimer, fourth: DispatchSourceTimer, fifth: DispatchSourceTimer)
    
    // Clicks per second
    @State private var debugTimer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var cyclesPerSecond = 0
    
    var pid: pid_t {
        runningApplications[appSelection].processIdentifier
    }
    
    var body: some View {
        VStack {
            ProcessPicker
            KeysToClickView
            DelayTextFieldsView
            JoinAFKButtons
            StartStopBtns
        }
        .contentShape(Rectangle())
        .padding()
        .onAppear {
            Hotkey.onKeyDown(for: .first, action: {startClicking(keys: .first)})
            Hotkey.onKeyDown(for: .second, action: {startClicking(keys: .second)})
//            Hotkey.onKeyDown(for: .afk, action: {startClicking(keys: .afk)})
            Hotkey.onKeyDown(for: .mouse, action: {startClicking(keys: .mouse)})
            findRunningApplication()
            _ = debugTimer.connect()
            requestPermissions()
            Hotkey.startMonitoring()
            resignFirstResponder()
        }
        .onReceive(appSettings.$showProcesses) {_ in
            findRunningApplication()
        }
        .onReceive(debugTimer) {_ in
            cyclesPerSecond = cycles
            cycles = 0
        }
        .onTapGesture {
            resignFirstResponder()
        }
    }
    
    var ProcessPicker: some View {
        HStack {
            Picker(selection: $appSelection, label: Text("Choose a process")) {
                ForEach(runningApplications.indices, id: \.self) { i in
                    HStack(spacing: 0) {
                        Image(nsImage: runningApplications[i].icon ?? NSImage())
                        Text(runningApplications[i].localizedName ?? "Error")
                    }
                }
            }.onChange(of: appSelection, perform: {_ in
                appSettings.appSelectionName = runningApplications[appSelection].localizedName ?? "Error"
            })
            Button(action: {
                findRunningApplication()
            }, label: {
                Text("Refresh")
            })
        }
        .alert(isPresented: $showsAppNotFoundAlert, content: {
            Alert(title: Text("Application Not Running"), message: Text("The selected application cannot be found or is not running."), dismissButton: .default(Text("OK")))
        })
        .frame(idealWidth: 400, maxWidth: .infinity)
    }
    
    var KeysToClickView: some View {
        HStack(alignment: .center) {
            HStack {
                Text("Keys to press:")
                    .frame(width: 86, alignment: .leading)
                TextField("Enter text...", text: $appSettings.keysToClick, onEditingChanged: {_ in
                    isClicking.first ? restartClicking(keys: .first) : ()
                }, onCommit: resignFirstResponder)
                .frame(width: 110)
            }
            HStack {
                Text("Second keys:")
                    .frame(width: 86, alignment: .leading)
                TextField("Enter text...", text: $appSettings.keysToClick2, onEditingChanged: {_ in
                    isClicking.second ? restartClicking(keys: .second) : ()
                }, onCommit: resignFirstResponder)
                .frame(width: 110)
            }
        }
        .padding(.top, 3)
    }
    
//    var SuppliesSelecionView: some View {
//        HStack {
//            Toggle(isOn: $appSettings.toggleStates[0], label: {
//                Text("Repair")
//            })
//            Divider()
//            Toggle(isOn: $appSettings.toggleStates[1], label: {
//                Text("Armour")
//            })
//            Divider()
//            Toggle(isOn: $appSettings.toggleStates[2], label: {
//                Text("Damage")
//            })
//            Divider()
//            Toggle(isOn: $appSettings.toggleStates[3], label: {
//                Text("Speed")
//            })
//            Divider()
//            Toggle(isOn: $appSettings.toggleStates[4], label: {
//                Text("Mines")
//            })
//        }
//        .frame(idealHeight: 16, maxHeight: .infinity)
//        .padding([.top, .bottom], 3)
//    }
    
    var DelayTextFieldsView: some View {
        HStack(alignment: .center) {
            HStack {
                Text("First delay:")
                    .frame(width: 86, alignment: .leading)
                TextField("ms", text: $appSettings.delay, onEditingChanged: {_ in
                    isClicking.first ? restartClicking(keys: .first) : ()
                }, onCommit: resignFirstResponder)
                .frame(width: 110)
            }
            HStack {
                Text("Second delay:")
                    .frame(width: 86, alignment: .leading)
                TextField("ms", text: $appSettings.delay2, onEditingChanged: {_ in
                    isClicking.second ? restartClicking(keys: .second) : ()
                }, onCommit: resignFirstResponder)
                .frame(width: 110)
            }
        }
    }
    
    var JoinAFKButtons: some View {
        VStack {
            Divider()
//            Button(!isClicking.sideA ? "Join side A" : "Stop side A") {
//                startClicking(keys: .sideA)
//            }
//            Button(!isClicking.afk ? "Start AFK" : "Stop AFK") {
//                startClicking(keys: .afk)
//            }
//            Button(!isClicking.sideB ? "Join side B" : "Stop side B") {
//                startClicking(keys: .sideB)
//            }
        }
        .frame(height: 10)
        .padding(.bottom, 3)
    }
    
    var StartStopBtns: some View {
        HStack(alignment: .center) {
            Text("\(cyclesPerSecond) C/s")
                .frame(width: 90)
                .multilineTextAlignment(.center)
            Button(action: {
                startClicking(keys: .first)
            }, label: {
                Text("\(!isClicking.first ? "Start" : "Stop") First")
                    .frame(width: 90)
            })
            Button(action: {
                startClicking(keys: .second)
            }, label: {
                Text("\(!isClicking.second ? "Start" : "Stop") Second")
                    .frame(width: 90)
            })
            Text(selection)
                .frame(width: 90)
        }
        .alert(isPresented: $showsNoPermissionsAlert, content: {
            Alert(title: Text("Missing Permissions"), message: Text("Clicker needs accessibility permissions to inject keystrokes into other processes. You can allow this in System Preferences > Security & Privacy > Privacy > Accessibility"), primaryButton: .default(Text("Open System Preferences"), action: {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }), secondaryButton: .cancel())
        })
    }
    
    // MARK: - Timer Functions
    
    func initializeTimers() {
        let delay = Int(appSettings.delay) ?? 50
        let delay2 = Int(appSettings.delay2) ?? 50
        timers.first.schedule(deadline: .now(), repeating: .milliseconds(delay))
        timers.first.setEventHandler(handler: {
            if isClicking.first {
                cycles += 1
                // Create string from toggles
                let events = createEvents(from: appSettings.keysToClick.toKeyCodes())
                // Create events from string and inject into pid
                inject(events: events, into: runningApplications[appSelection].processIdentifier)
            }
        })
        timers.second.schedule(deadline: .now(), repeating: .milliseconds(delay2))
        timers.second.setEventHandler(handler: {
            if isClicking.second {
                if !isClicking.first {
                    cycles += 1
                }
                let events = createEvents(from: appSettings.keysToClick2.toKeyCodes())
                inject(events: events, into: pid)
            }
        })
        if let events = createJoinEvents() {
            timers.third.schedule(deadline: .now(), repeating: .milliseconds(50))
            timers.third.setEventHandler(handler: {
                inject(events: events, into: pid)
            })
        }
        timers.fourth.schedule(deadline: .now(), repeating: .seconds(15))
        timers.fourth.setEventHandler(handler: {
            if isClicking.afk {
                runAfkSequence()
            }
        })
        timers.fifth.schedule(deadline: .now(), repeating: .milliseconds(Int(appSettings.mouseDelay) ?? 10))
        timers.fifth.setEventHandler(handler: {
            if isClicking.mouse {
                //let position = mouseLocation
                let events = getMouseEvents(for: setMouseLocation)
                for event in events {
                    event.post(tap: .cghidEventTap)
                }
                cycles += 1
            }
        })
    }
    
    private func runAfkSequence() {
        let aDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keycodes["a"]!), keyDown: true)!
        let aUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keycodes["a"]!), keyDown: false)!
        aDown.flags = []
        aUp.flags = []
        
        let dDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keycodes["d"]!), keyDown: true)!
        let dUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keycodes["d"]!), keyDown: false)!
        dDown.flags = []
        dUp.flags = []
        
        inject(events: [aDown], into: pid)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            inject(events: [aUp], into: pid)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            inject(events: [dDown], into: pid)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            inject(events: [dUp], into: pid)
        }
    }
    
    func startClicking(keys: Keyset) {
        if !hasPermissions() {
            stopClicker()
            showsNoPermissionsAlert.toggle()
            return
        }
        if !selectedAppIsRunning() && !isClicking.first && !isClicking.second && !isClicking.sideA {
            stopClicker()
            showsAppNotFoundAlert.toggle()
            return
        }
        
        if keys == .first {
            isClicking.first.toggle()
            isClicking.first ? startTimer(.first) : timers.first.suspend()
            if !isClicking.first && isClicking.second && appSettings.smartToggle {
                isClicking.second.toggle()
                isClicking.second ? startTimer(.second) : timers.second.suspend()
            }
            updateRunningStatus(isClicking.first)
            cycles = 0
        } else if keys == .second {
            isClicking.second.toggle()
            isClicking.second ? startTimer(.second) : timers.second.suspend()
            if !isClicking.first && isClicking.second && appSettings.smartToggle {
                startClicking(keys: .first)
            }
            updateRunningStatus(isClicking.first)
        } else if keys == .afk {
            isClicking.afk.toggle()
            if !isClicking.afk {
                timers.fourth.suspend()
            } else {
                startTimer(.afk)
            }
        } else if keys == .sideA {
            isClicking.sideA.toggle()
            updateRunningStatus(isClicking.sideA)
            
            if !isClicking.sideA {
                timers.third.suspend()
                if isClicking.sideB {
                    startTimer(.sideA)
                }
            } else {
                if isClicking.sideB {
                    timers.third.suspend()
                }
                startTimer(.sideA)
            }
        } else if keys == .sideB {
            isClicking.sideB.toggle()
            updateRunningStatus(isClicking.sideB)
            
            if !isClicking.sideB {
                timers.third.suspend()
                if isClicking.sideA {
                    startTimer(.sideA)
                }
            } else {
                if isClicking.sideA {
                    timers.third.suspend()
                }
                startTimer(.sideA)
            }
        } else if keys == .mouse {
            isClicking.mouse.toggle()
            if !isClicking.mouse {
                timers.fifth.suspend()
            } else {
                setMouseLocation = NSEvent.mouseLocation
                let halfValue = (NSScreen.screens.first?.frame.height ?? 1)/2
                if setMouseLocation.y > halfValue {
                    setMouseLocation.y = halfValue - (setMouseLocation.y-halfValue)
                } else if setMouseLocation.y < halfValue {
                    setMouseLocation.y = halfValue + (halfValue-setMouseLocation.y)
                }
                startTimer(.mouse)
            }
        }
        
        // MARK: - Debug
        
//        if isClicking.first {
//            secondsElapsed = 0
//            debugTimer = Timer.publish(every: 1, on: .main, in: .common)
//            _ = debugTimer.connect()
//        } else {
//            debugTimer.connect().cancel()
//        }
        
        // MARK: - End Debug
    }
    
    func restartClicking(keys: Keyset) {
        switch keys {
        case .first:
            timers.first.suspend()
            startTimer(.first)
        case .second:
            timers.second.suspend()
            startTimer(.second)
        default:
            break
        }
    }
    
    func updateRunningStatus(_ buttonState: Bool) {
        if selection == "Stopped" && buttonState {
            selection = "Running"
        } else if selection == "Running" {
            if !isClicking.first && !isClicking.second && !isClicking.sideA && !isClicking.sideB && !isClicking.afk {
                selection = "Stopped"
            }
        }
    }
    
    func startTimer(_ timer: Keyset) {
        if timer == .first {
            initializeTimers()
            timers.first.resume()
        } else if timer == .second {
            initializeTimers()
            timers.second.resume()
        } else if timer == .afk {
            initializeTimers()
            timers.fourth.resume()
        } else if timer == .mouse {
            initializeTimers()
            timers.fifth.resume()
        } else { // A or B
            initializeTimers()
            timers.third.resume()
        }
    }
    
    func stopClicker() {
        if isClicking.first {
            timers.first.suspend()
            isClicking.first = false
        }
        if isClicking.second {
            timers.second.suspend()
            isClicking.second = false
        }
        if isClicking.afk {
            timers.fourth.suspend()
            isClicking.afk = false
        }
        if isClicking.sideA || isClicking.sideB {
            //timers.third.suspend()
            isClicking.sideA = false
            isClicking.sideB = false
        }
            //isClicking = (supplies: false, mines: false, afk: false, sideA: false, sideB: false)
            //timers.first.suspend(); timers.second.suspend()//; timers.third.suspend(); timers.fourth.suspend()
    }
    
    // MARK: - Creating/Injecting events
    
    func createJoinEvents() -> [CGEvent]? {
        if isClicking.sideA || isClicking.sideB {
            var events = [CGEvent]()
            if isClicking.sideA {
                events += createEvents(from: [(0x00, nil)])
            }
            if isClicking.sideB {
                events += createEvents(from: [(0x0B, nil)])
            }
            events += createEvents(from: [(0x24, nil)])
            return events
        }
        return nil
    }
    
    func inject(events: [CGEvent], into pid: pid_t) {
        for event in events {
            event.postToPid(pid)
        }
    }
    
    func createEvents(from keycodes: [(keyCode: UInt16, modifiers: CGEventFlags?)], flags: CGEventFlags = []) -> [CGEvent] {
        var events = [CGEvent]()
        for code in keycodes {
            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code.keyCode), keyDown: true)!
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code.keyCode), keyDown: false)!
            keyDown.flags = code.modifiers != nil ? code.modifiers! : flags
            keyUp.flags = code.modifiers != nil ? code.modifiers! : flags
            events.append(keyDown)
            events.append(keyUp)
        }
        return events
    }
    
    func getMouseEvents(for position: CGPoint) -> [CGEvent] {
        if let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: position, mouseButton: .left) {
            if let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: position, mouseButton: .left) {
                return [mouseDown, mouseUp]
            }
            print("Failed to generate second mouse event")
            return[]
        }
        print("Failed to generate first mouse event")
        return []
    }
    
//    func startMouseTracking() {
//        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) {
//            print(NSEvent.mouseLocation)
//            return $0
//        }
//        NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) {_ in
//            print(NSEvent.mouseLocation)
//        }
//    }
    
    // MARK: - General Functions
    
    func resignFirstResponder() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }
    
    func requestPermissions() {
        if !hasPermissions() {
            inject(events: createEvents(from: [(0xFF, nil)]), into: NSRunningApplication.current.processIdentifier)
            cycles = 0
        }
    }
    
    func hasPermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        return accessEnabled
    }
    
    func findRunningApplication() {
        runningApplications = getRunningApplications()
        if appSettings.appSelectionName == "" || appSettings.appSelectionName == "Error" {
            appSettings.appSelectionName = runningApplications[appSelection].localizedName ?? "Error"
            return
        }
        for i in 0..<runningApplications.count {
            if runningApplications[i].localizedName ?? "Error" == appSettings.appSelectionName {
                appSelection = i
                return
            }
        }
    }
    
    func getRunningApplications() -> [NSRunningApplication] {
        if !appSettings.showProcesses {
            return NSWorkspace.shared.runningApplications.filter { app in
                return app.launchDate != nil || app.localizedName == "Finder"
            }
        }
        return NSWorkspace.shared.runningApplications
    }
    
    func selectedAppIsRunning() -> Bool {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: runningApplications[appSelection].bundleIdentifier ?? "Unkown")
        if apps.isEmpty {
            return false
        }
        return true
    }
    
    func printStatus() {
        print("\nStatus: \(selection)")
        print("Clicking application: \(runningApplications[appSelection].localizedName ?? "Unkown")", terminator: "")
        print(" | pid: \(runningApplications[appSelection].processIdentifier)")
        print("\tKeys to click: [1]\(appSettings.keysToClick) | [2]\(appSettings.keysToClick2)")
        print("\t\tDelay1: \(appSettings.delay)\n\t\tDelay2: \(appSettings.delay2)")
        print("isClicking: \(isClicking)\n------------------------------------")
    }
}

extension Hotkey.Name {
    static let first = Self("first")
    static let second = Self("second")
    static let afk = Self("afk")
    static let mouse = Self("mouse")
}

enum Keyset {
    case first
    case second
    case sideA
    case sideB
    case afk
    case mouse
}

extension String {
    func toKeyCodes() -> [(keyCode: UInt16, modifiers: CGEventFlags?)] {
        var arr = [(keyCode: UInt16, modifiers: CGEventFlags?)]()
        for char in self {
            let charModifiers: CGEventFlags? = char.isUppercase ? .maskShift : nil
            if let cgKeyCode = keycodes["\(char.lowercased())"] {
                arr.append((keyCode: cgKeyCode, modifiers: charModifiers))
            } else if let cgKeyCode = parallelKeycodes["\(char)"] {
                arr.append((keyCode: cgKeyCode, modifiers: .maskShift))
            } else {
                print("No keycode for char: \(char)")
            }
        }
        return arr
    }
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.blue : Color.gray)
    }
}
