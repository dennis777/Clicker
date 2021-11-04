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
import Carbon

//struct ContentView: View {
//    @State private var pt: CGPoint = .zero
//    var body: some View {
//        let myGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global).onEnded({
//            self.pt = $0.startLocation
//        })
//
//        // Spacers needed to make the VStack occupy the whole screen
//        return VStack {
//            Spacer()
//            Text("Tapped at: \(pt.x), \(pt.y)")
//            Spacer()
//            HStack { Spacer() }
//        }
//        .border(Color.green)
//        .contentShape(Rectangle()) // Make the entire VStack tappabable, otherwise, only the areay with text generates a gesture
//        .gesture(myGesture) // Add the gesture to the Vstack
//    }
//}

struct ContentView: View {
    @ObservedObject var appSettings = AppSettings()
    @State private var selection = "Stopped"
    @State private var isClicking = (supplies: false, mines: false, afk: false, sideA: false, sideB: false, mouse: false)
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
            if !appSettings.compactView {
                ProcessPicker
                SuppliesSelecionView
                DelayTextFieldsView
                JoinButtons
                StartStopBtns
            } else {
                StartStopBtn
            }
        }
        .contentShape(Rectangle())
        .padding()
        .onAppear {
            Hotkey.onKeyDown(for: .supplies, action: {startClicking(keys: .first)})
            Hotkey.onKeyDown(for: .mines, action: {startClicking(keys: .second)})
            Hotkey.onKeyDown(for: .afk, action: {startClicking(keys: .afk)})
            Hotkey.onKeyDown(for: .mouse, action: {startClicking(keys: .mouse)})
            findRunningApplication()
            _ = debugTimer.connect()
            //setupTimers()
            requestPermissions()
            Hotkey.startMonitoring()
            resignFirstResponder()
        }
        .onReceive(appSettings.$showProcesses) {_ in
            runningApplications = getRunningApplications()
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
                runningApplications = getRunningApplications()
                findRunningApplication()
            }, label: {
                Text("Refresh")
            })
        }
        .padding(.top, 5)
        .alert(isPresented: $showsAppNotFoundAlert, content: {
            Alert(title: Text("Application Not Running"), message: Text("The selected application cannot be found or is not running."), dismissButton: .default(Text("OK")))
        })
        .frame(idealWidth: 400, maxWidth: .infinity)
    }
    
    var SuppliesSelecionView: some View {
        HStack {
            Toggle(isOn: $appSettings.toggleStates[0], label: {
                Text("Repair")
            })
            Divider()
            Toggle(isOn: $appSettings.toggleStates[1], label: {
                Text("Armour")
            })
            Divider()
            Toggle(isOn: $appSettings.toggleStates[2], label: {
                Text("Damage")
            })
            Divider()
            Toggle(isOn: $appSettings.toggleStates[3], label: {
                Text("Speed")
            })
            Divider()
            Toggle(isOn: $appSettings.toggleStates[4], label: {
                Text("Mines")
            })
        }
        .frame(idealHeight: 16, maxHeight: .infinity)
        .padding([.top, .bottom], 3)
    }
    
    var DelayTextFieldsView: some View {
        HStack(alignment: .center) {
            HStack {
                Text("Supplies delay:")
                TextField("ms", text: $appSettings.delay, onEditingChanged: {_ in
                    isClicking.supplies ? restartClicking(keys: .first) : ()
                }, onCommit: resignFirstResponder)
                .frame(width: 100)
            }
            HStack {
                Text("Mines delay:")
                TextField("ms", text: $appSettings.delay2, onEditingChanged: {_ in
                    isClicking.mines ? restartClicking(keys: .second) : ()
                }, onCommit: resignFirstResponder)
                .frame(width: 100)
            }
        }
    }
    
    var StartStopBtns: some View {
        HStack(alignment: .center) {
            Text("\(cyclesPerSecond) C/s")
                .frame(width: 90)
                .multilineTextAlignment(.center)
            Button(action: {
                startClicking(keys: .first)
            }, label: {
                Text(!isClicking.supplies ? "Start Supplies" : "Stop Supplies")
                    .frame(width: 90)
            })
            Button(action: {
                startClicking(keys: .second)
            }, label: {
                Text(!isClicking.mines ? "Start Mines" : "Stop Mines")
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
    
    var JoinButtons: some View {
        HStack {
            Button(!isClicking.sideA ? "Join side A" : "Stop side A") {
                startClicking(keys: .sideA)
            }
            Button(!isClicking.afk ? "Start AFK" : "Stop AFK") {
                startClicking(keys: .afk)
            }
            Button(!isClicking.sideB ? "Join side B" : "Stop side B") {
                startClicking(keys: .sideB)
            }
//            Button("Open Debug") {
//                SpeedtestView(debugTimer: $debugTimer, clicksPerCycle: $clicksPerCycle, secondsElapsed: $secondsElapsed, totalClicks: $cycles).openNewWindow(with: "Clicker Debug")
//            }
//            .keyboardShortcut("7")
        }
        .padding(.bottom, 1)
    }
    
    var StartStopBtn: some View {
        VStack {
            Button(!isClicking.supplies ? "Start Supplies" : "Stop Supplies") {
                startClicking(keys: .first)
            }
            Button(!isClicking.mines ? "Start Mines" : "Stop Mines") {
                startClicking(keys: .second)
            }
            Button(!isClicking.afk ? "Start AFK" : "Stop AFK") {
                startClicking(keys: .afk)
            }
            Button(!isClicking.sideA ? "Join side A" : "Stop side A") {
                startClicking(keys: .sideA)
            }
            Button(!isClicking.sideB ? "Join side B" : "Stop side B") {
                startClicking(keys: .sideB)
            }
        }
    }
    
    // MARK: - Timer Functions
    
    func initializeTimers() {
        let delay = Int(appSettings.delay) ?? 50
        let delay2 = Int(appSettings.delay2) ?? 50
        timers.first.schedule(deadline: .now(), repeating: .milliseconds(delay))
        timers.first.setEventHandler(handler: {
            if isClicking.supplies {
                cycles += 1
                // Create string from toggles
                var keysToClick = String()
                for i in 0..<appSettings.toggleStates.count-1 {
                    if appSettings.toggleStates[i] {
                        keysToClick += "\(i+1)"
                    }
                }
                // Create events from string and inject into pid
                let events = createEvents(from: keysToClick.toKeyCodes())
                inject(events: events, into: runningApplications[appSelection].processIdentifier)
            }
        })
        timers.second.schedule(deadline: .now(), repeating: .milliseconds(delay2))
        timers.second.setEventHandler(handler: {
            if isClicking.mines {
                if !isClicking.supplies {
                    cycles += 1
                }
                let events = createEvents(from: "5".toKeyCodes())
                inject(events: events, into: runningApplications[appSelection].processIdentifier)
            }
        })
        if let events = createJoinEvents() {
            timers.third.schedule(deadline: .now(), repeating: .milliseconds(50))
            timers.third.setEventHandler(handler: {
                inject(events: events, into: runningApplications[appSelection].processIdentifier)
            })
        }
        timers.fourth.schedule(deadline: .now(), repeating: .seconds(15))
        timers.fourth.setEventHandler(handler: {
            if isClicking.afk {
                let movement = "adadadadadadadadadad"
                let events = createEvents(from: movement.toKeyCodes())
                inject(events: events, into: runningApplications[appSelection].processIdentifier)
            }
        })
        timers.fifth.schedule(deadline: .now(), repeating: /*.seconds(15)*/.nanoseconds(100000))
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
    
    func startClicking(keys: Keyset) {
        if !hasPermissions() {
            stopClicker()
            showsNoPermissionsAlert.toggle()
            return
        }
        if !selectedAppIsRunning() && !isClicking.supplies && !isClicking.mines && !isClicking.sideA {
            stopClicker()
            showsAppNotFoundAlert.toggle()
            return
        }
        
        if keys == .first {
            isClicking.supplies.toggle()
            isClicking.supplies ? startTimer(.first) : timers.first.suspend()
            if !isClicking.supplies && isClicking.mines && appSettings.smartToggles {
                isClicking.mines.toggle()
                isClicking.mines ? startTimer(.second) : timers.second.suspend()
            }
            updateRunningStatus(isClicking.supplies)
            cycles = 0
        } else if keys == .second {
            isClicking.mines.toggle()
            isClicking.mines ? startTimer(.second) : timers.second.suspend()
            if !isClicking.supplies && isClicking.mines && appSettings.smartToggles {
                startClicking(keys: .first)
            }
            updateRunningStatus(isClicking.supplies)
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
            if isClicking.sideA && !isClicking.sideB {
                startTimer(.sideA)
            } else if !isClicking.sideA && !isClicking.sideB {
                timers.third.suspend()
            } else {
                timers.third.suspend()
                startTimer(.sideB)
            }
        } else if keys == .sideB {
            isClicking.sideB.toggle()
            updateRunningStatus(isClicking.sideB)
            if isClicking.sideB && !isClicking.sideA {
                startTimer(.sideA)
            } else if !isClicking.sideB && !isClicking.sideA {
                timers.third.suspend()
            } else {
                timers.third.suspend()
                startTimer(.sideA)
            }
        } else if keys == .mouse {
            isClicking.mouse.toggle()
            if !isClicking.mouse {
                timers.fifth.suspend()
            } else {
                setMouseLocation = NSEvent.mouseLocation
                
                if setMouseLocation.y > 450 {
                    setMouseLocation.y = 450 - (setMouseLocation.y-450)
                } else if setMouseLocation.y < 450 {
                    setMouseLocation.y = 450 + (450-setMouseLocation.y)
                }
                startTimer(.mouse)
            }
        }
        
        // MARK: - Debug
        
//        if isClicking.supplies {
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
            if !isClicking.supplies && !isClicking.mines && !isClicking.sideA && !isClicking.sideB {
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
        } else {
            initializeTimers()
            timers.third.resume()
        }
    }
    
    func stopClicker() {
        if isClicking.supplies {
            timers.first.suspend()
            isClicking.supplies = false
        }
        if isClicking.mines {
            timers.second.suspend()
            isClicking.mines = false
        }
        if isClicking.afk {
            timers.third.suspend()
            isClicking.afk = false
        }
        if isClicking.sideA || isClicking.sideB {
            timers.fourth.suspend()
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
                events += createEvents(from: [0x00])
            }
            if isClicking.sideB {
                events += createEvents(from: [0x0B])
            }
            events += createEvents(from: [0x24])
            return events
        }
        return nil
    }
    
    func inject(events: [CGEvent], into pid: pid_t) {
        for event in events {
            event.postToPid(pid)
        }
    }
    
    func createEvents(from keycodes: [UInt16], flags: CGEventFlags = []) -> [CGEvent] {
        var events = [CGEvent]()
        for code in keycodes {
            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: true)!
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: false)!
            keyDown.flags = flags
            keyUp.flags = flags
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
    
    func setupTimers() {
        timers.first.activate(); timers.first.suspend()
//        timers.second.activate(); timers.second.suspend()
//        timers.third.activate(); timers.third.suspend()
//        timers.fourth.activate(); timers.fourth.suspend()
//        timers.fifth.activate(); timers.fifth.suspend()
    }
    
    func resignFirstResponder() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }
    
    func requestPermissions() {
        if !hasPermissions() {
            inject(events: createEvents(from: [0xFF]), into: NSRunningApplication.current.processIdentifier)
            cycles = 0
        }
    }
    
    func hasPermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        return accessEnabled
    }
    
    func findRunningApplication() {
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
        print("\tKeys: \(appSettings.toggleStates)")
        print("\t\tDelay1: \(appSettings.delay)\n\t\tDelay2: \(appSettings.delay2)")
        print("isClicking: \(isClicking)\n------------------------------------")
    }
}

extension Hotkey.Name {
    static let supplies = Self("supplies")
    static let mines = Self("mines")
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
    func toKeyCodes() -> [UInt16] {
        var arr = [UInt16]()
        for char in self {
            arr.append(keycodes["\(char)"]!)
        }
        return arr
    }
}


//extension String {
//    /// This converts string to UInt as a fourCharCode
//    public var fourCharCodeValue: Int {
//        var result: Int = 0
//        if let data = self.data(using: String.Encoding.macOSRoman) {
//            data.withUnsafeBytes({ (rawBytes) in
//                let bytes = rawBytes.bindMemory(to: UInt8.self)
//                for i in 0 ..< data.count {
//                    result = result << 8 + Int(bytes[i])
//                }
//            })
//        }
//        return result
//    }
//}
//
//class HotkeySolution {
//    static func getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags) -> UInt32 {
//        let flags = cocoaFlags.rawValue
//        var newFlags: Int = 0
//
//        if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
//            newFlags |= controlKey
//        }
//
//        if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
//            newFlags |= cmdKey
//        }
//
//        if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
//            newFlags |= shiftKey;
//        }
//
//        if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
//            newFlags |= optionKey
//        }
//
//        if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
//            newFlags |= alphaLock
//        }
//
//        return UInt32(newFlags);
//    }
//
//    static func register() {
//        var hotKeyRef: EventHotKeyRef?
//        let modifierFlags: UInt32 = getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags.option)
//
//        let keyCode = kVK_ANSI_9
//        var gMyHotKeyID = EventHotKeyID()
//
//        gMyHotKeyID.id = UInt32(keyCode)
//
//        // Not sure what "swat" vs "htk1" do.
//        gMyHotKeyID.signature = OSType("swat".fourCharCodeValue)
//        // gMyHotKeyID.signature = OSType("htk1".fourCharCodeValue)
//
//        var eventType = EventTypeSpec()
//        eventType.eventClass = OSType(kEventClassKeyboard)
//        eventType.eventKind = OSType(kEventHotKeyReleased)
//
//        // Install handler.
//        InstallEventHandler(GetApplicationEventTarget(), {
//            (nextHanlder, theEvent, userData) -> OSStatus in
//            // var hkCom = EventHotKeyID()
//
//            // GetEventParameter(theEvent,
//            //                   EventParamName(kEventParamDirectObject),
//            //                   EventParamType(typeEventHotKeyID),
//            //                   nil,
//            //                   MemoryLayout<EventHotKeyID>.size,
//            //                   nil,
//            //                   &hkCom)
//
//            print("Clicked 9")
//
//            return noErr
//            /// Check that hkCom in indeed your hotkey ID and handle it.
//        }, 1, &eventType, nil, nil)
//
//        // Register hotkey.
//        let status = RegisterEventHotKey(UInt32(keyCode),
//                                         modifierFlags,
//                                         gMyHotKeyID,
//                                         GetApplicationEventTarget(),
//                                         0,
//                                         &hotKeyRef)
//        assert(status == noErr)
//    }
//}
