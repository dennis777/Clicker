//
//  SettingsView.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 5/18/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading) {
            Text("Convenience")
                .font(.headline)
            Divider()
            HStack {
                Text("Enable smart toggle")
                Spacer()
                Toggle("", isOn: $appSettings.smartToggle)
            }
            .padding(.bottom, 30)
            Text("Hotkeys")
                .font(.headline)
            Divider()
            HStack {
                Text("Toggle first")
                Spacer()
                Hotkey.Recorder(name: .first)//, defaultKeyCommand: "9")
            }
            HStack {
                Text("Toggle second")
                Spacer()
                Hotkey.Recorder(name: .second)//, defaultKeyCommand: "0")
            }
//            HStack {
//                Text("Toggle AFK")
//                Spacer()
//                Hotkey.Recorder(name: .afk)
//            }
            HStack {
                Text("Toggle mouse")
                Spacer()
                Hotkey.Recorder(name: .mouse)//, defaultKeyCommand: "⌥\\")
            }
            .padding(.bottom, 30)
            Text("Other")
                .font(.headline)
            Divider()
            HStack {
                Text("Mouse click speed")
                Spacer()
                TextField("ms", text: $appSettings.mouseDelay)
//                Toggle("", isOn: $appSettings.smartToggle)
            }
        }
        .padding()
        .frame(width: 275)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Label("Settings", systemImage: "gearshape")
                    .font(.title)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
