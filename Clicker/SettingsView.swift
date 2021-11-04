//
//  SettingsView.swift
//  Clicker
//
//  Created by Dennis Litvinenko on 5/18/21.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hotkeys")
                .font(.headline)
            Divider()
            HStack {
                Text("Toggle supplies")
                Spacer()
                Hotkey.Recorder(name: .supplies)
            }
            HStack {
                Text("Toggle mines")
                Spacer()
                Hotkey.Recorder(name: .mines)
            }
            HStack {
                Text("Toggle AFK")
                Spacer()
                Hotkey.Recorder(name: .afk)
            }
            HStack {
                Text("Toggle Mouse")
                Spacer()
                Hotkey.Recorder(name: .mouse)
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
