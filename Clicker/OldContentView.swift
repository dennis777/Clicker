//
//  OldContentView.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 3/31/21.
//
/*
import SwiftUI
import CoreData
import KeyboardShortcuts

struct OldContentView: View {
    @ObservedObject var appSettings = AppSettings()
    @State private var selection = "Stopped"
    @State private var isClicking = (first: false, second: false, sideA: false, sideB: false)
    @State private var showsAlert = false
    @State private var cycles = 0
    @State private var appSelection = 0
    @State private var pid = Int32()
    @State private var runningApplications = [NSRunningApplication]()
    @Binding var timers: (first: DispatchSourceTimer, second: DispatchSourceTimer, third: DispatchSourceTimer)

    var body: some View {
        VStack {
            if !appSettings.compactView {
                Spacer(minLength: 0)
                ProccessPicker
                TextInputs
                HStack {
                    KeyboardShortcuts.Recorder(for: .startFirst)
                    JoinButtons
                    KeyboardShortcuts.Recorder(for: .startSecond)
                }
                StartStopBtns
                Spacer(minLength: 0)
            } else {
                VStack {
                    Spacer(minLength: 0)
                    StartStopBtn
                    Spacer(minLength: 0)
                }
            }
        }
        .padding()
        .onAppear {
            KeyboardShortcuts.onKeyUp(for: .startFirst, action: {startClicking(keys: .first)})
            KeyboardShortcuts.onKeyUp(for: .startSecond, action: {startClicking(keys: .second)})
            findRunningApplication()
            pid = runningApplications[appSelection].processIdentifier
            timers.first.activate(); timers.first.suspend()
            timers.second.activate(); timers.second.suspend()
            timers.third.activate(); timers.third.suspend()
        }
        .onReceive(appSettings.$showProcesses) {_ in
            runningApplications = getRunningApplications()
            findRunningApplication()
        }
        .frame(minWidth: appSettings.compactView ? 35 : 440, minHeight: 170)
    }
    
    var ProccessPicker: some View {
        HStack {
            if #available(OSX 11.0, *) {
                Picker(selection: $appSelection, label: Text("Choose a proccess")) {
                    ForEach(runningApplications.indices, id: \.self) { i in
                        HStack(spacing: 0) {
                            Image(nsImage: runningApplications[i].icon ?? NSImage())
                            Text(runningApplications[i].localizedName ?? "Error")
                        }
                    }
                }.onChange(of: appSelection, perform: {_ in
                    pid = runningApplications[appSelection].processIdentifier
                    appSettings.appSelectionName = runningApplications[appSelection].localizedName ?? "Error"
                })
            } else {
                Picker(selection: $appSelection, label: Text("Choose a proccess")) {
                    ForEach(runningApplications.indices, id: \.self) { i in
                        HStack(spacing: 0) {
                            Image(nsImage: runningApplications[i].icon ?? NSImage())
                            Text(runningApplications[i].localizedName ?? "Error")
                        }
                    }
                }
            }
            Button(action: {
                runningApplications = getRunningApplications()
                findRunningApplication()
            }, label: {
                Text("Refresh")
            })
        }
    }
    
    var TextInputs: some View {
        VStack {
            HStack {
                HStack {
                    Text("Keys to press:")
                    TextField("Keys to click", text: $appSettings.keysToClick)
                }
                HStack {
                    Text("Second keys:")
                    TextField("Keys to click", text: $appSettings.keysToClick2)
                }
            }
            if #available(OSX 11.0, *) {
                HStack {
                    HStack {
                        Text("Delay (ms):")
                        TextField("Delay (ms)", text: $appSettings.delay)
                            .onChange(of: appSettings.delay, perform: {_ in
                                isClicking.first ? timers.first.suspend() : ()
                                isClicking.first ? startTimer(.first) : ()
                            })
                    }
                    HStack {
                        Text("Secondary (ms):")
                            .frame(width: 105)
                        TextField("Delay (ms):", text: $appSettings.delay2)
                            .frame(minWidth: 5)
                            .onChange(of: appSettings.delay2, perform: {_ in
                                isClicking.second ? timers.second.suspend() : ()
                                isClicking.second ? startTimer(.second) : ()
                            })
                    }
                }
            } else {
                HStack {
                    HStack {
                        Text("Delay (ms):")
                        TextField("Delay (ms)", text: $appSettings.delay)
                    }
                    HStack {
                        Text("Secondary (ms):")
                            .frame(width: 105)
                        TextField("Delay (ms):", text: $appSettings.delay2)
                            .frame(minWidth: 5)
                    }
                }
            }
        }
    }
    
    var StartStopBtns: some View {
        HStack {
            Text("\(cycles) Cycles")
                .frame(width: 90)
            Spacer()
            Button(action: {
                startClicking(keys: .first)
            }, label: {
                Text(!isClicking.first ? "Start First" : "Stop First")
                    .frame(width: 80)
            })
            Button(action: {
                startClicking(keys: .second)
            }, label: {
                Text(!isClicking.second ? "Start Second" : "Stop Second")
                    .frame(width: 80)
            })
            Spacer()
            Text(selection)
                .frame(width: 90)
        }
    }
    
    var JoinButtons: some View {
        HStack {
            Button(action: {
                startClicking(keys: .sideA)
            }, label: {
                Text(!isClicking.sideA ? "Join A" : "Stop A")
            })
            Button(action: {
                startClicking(keys: .sideB)
            }, label: {
                Text(!isClicking.sideB ? "Join B" : "Stop B")
            })
        }
    }
    
    var StartStopBtn: some View {
        VStack {
            Button(action: {
                startClicking(keys: .first)
            }, label: {
                Text(!isClicking.first ? "Start First" : "Stop First")
            })
            Button(action: {
                startClicking(keys: .second)
            }, label: {
                Text(!isClicking.second ? "Start Second" : "Stop Second")
            })
            Button(action: {
                startClicking(keys: .sideA)
            }, label: {
                Text(!isClicking.sideA ? "Join A" : "Stop A")
            })
            Button(action: {
                startClicking(keys: .sideB)
            }, label: {
                Text(!isClicking.sideB ? "Join B" : "Stop B")
            })
        }
    }
    
    // MARK: - Functions
    
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
    
    func initializeTimers() {
        let delay = Int(appSettings.delay) ?? 50
        let delay2 = Int(appSettings.delay2) ?? 50
        timers.first.schedule(deadline: .now(), repeating: .milliseconds(delay))
        timers.first.setEventHandler(handler: {
            let events = createEvents(from: appSettings.keysToClick.toKeyCodes())
            startInjecting(events: events, into: pid)
        })
        timers.second.schedule(deadline: .now(), repeating: .milliseconds(delay2))
        timers.second.setEventHandler(handler: {
            let events = createEvents(from: appSettings.keysToClick2.toKeyCodes())
            startInjecting(events: events, into: pid)
        })
        if let events = createJoinEvents() {
            timers.third.schedule(deadline: .now(), repeating: .milliseconds(delay))
            timers.third.setEventHandler(handler: {
                startInjecting(events: events, into: pid)
            })
        }
    }
    
    func startClicking(keys: Keyset) {
        if !selectedAppIsRunning() { stopClicker() }
        if keys == .first {
            isClicking.first.toggle()
            isClicking.first ? startTimer(.first) : timers.first.suspend()
            updateRunningStatus(isClicking.first)
            if !isClicking.first && isClicking.second && appSettings.checked {
                isClicking.second.toggle()
                isClicking.second ? startTimer(.second) : timers.second.suspend()
            }
            cycles = 0
        } else if keys == .second {
            isClicking.second.toggle()
            isClicking.second ? startTimer(.second) : timers.second.suspend()
            updateRunningStatus(isClicking.second)
            if !isClicking.first && isClicking.second && appSettings.checked {
                startClicking(keys: .first)
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
        }
    }
    
    func updateRunningStatus(_ buttonState: Bool) {
        if selection == "Stopped" && buttonState {
            selection = "Running"
        } else if selection == "Running" {
            if !isClicking.first && !isClicking.second && !isClicking.sideA && !isClicking.sideB {
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
        } else {
            initializeTimers()
            timers.third.resume()
        }
    }
    
    func stopClicker() {
        isClicking = (first: false, second: false, sideA: false, sideB: false)
        showsAlert = true
        return
    }
    
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
    
    func startInjecting(events: [CGEvent], into pid: pid_t) {
        for event in events {
            event.postToPid(pid)
        }
        cycles += 1
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
    
    //Debug
    func printStatus() {
        print("Status: \(selection)")
        print("Clicking application: \(runningApplications[appSelection].localizedName ?? "Unkown")")
        print("\tKeys1: \(appSettings.keysToClick)\n\tKeys2: \(appSettings.keysToClick2)\n")
        print("\t\tDelay1: \(appSettings.delay)\n\t\tDelay2: \(appSettings.delay2)\n")
        print("isClicking: \(isClicking)\n------------------------------------")
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

extension KeyboardShortcuts.Name {
    static let startFirst = Self("startFirst")
    static let startSecond = Self("startSecond")
}

enum Keyset {
    case first
    case second
    case sideA
    case sideB
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
*/
