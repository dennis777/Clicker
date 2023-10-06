//
//  HelpView.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 4/3/21.
//

import SwiftUI

struct HelpView: View {
    @ObservedObject var appSettings = AppSettings()
    @Binding var isOpen: Bool

    var body: some View {
        ScrollView {
            // workaround to enable text selection on macOS 12+
            if #available(macOS 12.0, *) {
                ActualView()
                    .textSelection(.enabled)
                    .padding()
            } else {
                ActualView()
                    .padding()
            }
        }
        .frame(idealWidth: 320, maxWidth: .infinity, idealHeight: 420, maxHeight: .infinity)
        .onDisappear {
            isOpen = false
        }
        .onAppear {
            isOpen = true
        }
    }
}

struct ActualView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Clicker Help Version 2.1.1 by Dennis")
                .font(.title2)
                .fontWeight(.bold)
            Group {
                Divider()
                Text("New this update")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .underline()
                    .padding(.bottom, 1)
                ForEach(Array(updates.enumerated()), id: \.element) { i, update in
                    HStack(alignment: .top) {
                        Text("\(i+1).")
                        Text("\(update)\n")
                    }
                }
            }
            Group {
                Divider()
                Text("Settings/Options")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .underline()
                    .padding(.bottom, 1)
                Text("Show Processes:\nEnable this option if you cannot find your app target.\n")
                Text("Enable Smart Toggles:\nEnable it to start clicking first automatically when you start clicking second, and stop second when you stop first. Note: this does NOT link them (i.e starting/stopping the first would start/stop second and visa versa)")
            }
            Group {
                Divider()
                Text("General/Info")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .underline()
                    .padding(.bottom, 1)
                Text("Clicker requires accessibility permissions since it injects keystrokes into other processes. This can be changed in System Preferences > Security & Privacy > Privacy > Accessibility. The clicker will not work with permissions disabled.\n")
                Text("This clicker is designed to be run on macOS 11.0 (Big Sur) and higher.")
            }
            Group {
                Divider()
                Text("Known Bugs/Issues")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .underline()
                    .padding(.bottom, 1)
                Text("Clicker starts to click slowly or may even stop clicking altogether after a few minutes of use. This is a bug within macOS and has to do with the way it handles memory. This seems to affect macs without the M-series of chips (M1, M2, etc.)\n")
                Text("Report any other issues to the developer.")
            }
            Group {
                Divider()
                Text("\nClicker was made to be free of charge for all macOS users to whom this application was given to. If you are paying for this application, delete it and contact the developer. Do not distribute without permission.\n")
                    .font(.caption)
                    .fontWeight(.light)
//                Text("\nCopyright © \(String(Calendar.current.dateComponents([.year], from: Date()).year ?? 1800).replacingOccurrences(of: ",", with: "")) Dennis. All rights reserved.")
//                        .font(.caption)
//                        .fontWeight(.ultraLight)
            }
        }
    }
}

let updates = [
    "Clicker automatically remembers and reattaches to the app last targeted before it closed. This means that if your client/browser is open before you pen Clicker, it will find the application target, and attach to it automagically :)",
    "Relocated hotkey/shortcut recorders to designated preferences pane. This can be access by either pressing (⌘,) or can be found in the menu under the pp name next to the  in the top left. Any menu item can be searched for using the menu help search function.",
    "You can now set hotkeys without any modifier keys (⌃⌥⇧⌘). This allows much simpler toggling especially if mining mid air. Default hotkeys are not set, but this can be changed in settings.",
    "Added a mouse clicker, set up a keyboard shortcut to activate it in settings.",
    "Clicker now has an official App Icon 🥳",
    "Fixed bug where application would open in an ugly huge size, and removed application tabbing.",
    "Fixed many bugs with hotkeys not working.",
    "Fixed bug where changing keys to press textbox would still click the old payload.",
    "Fixed bug where typing in delay boxes would still sometimes toggle the clicker.",
    "Fixed crashing when receiving 'Selected app not running' alert and then selecting a different app.",
    "General stability improvements."
]
