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
                    Text("Fixed many bugs with hotkeys not working.\n")
                    Text("Fixed bug where changing supplies toggles would still click old settings.\n")
                    Text("Fixed bug where typing in delay boxes would still sometimes toggle the clicker.\n")
                    Text("Fixed crashing when receiving 'Selected app not running' alert and then selecting a different app.\n")
                    Text("General stability improvements.\n")
                    Text("")
                }
                Group {
                    Divider()
                    Text("Settings/Options")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .underline()
                        .padding(.bottom, 1)
                    Text("Show All Processes: enable this option if you cannot find your app target.\n")
                    Text("Enable Compact View: enable to split screen your app with you client/browser of choice in the event you are experienceing unreliable clicking. Scroll to 'Known Bugs' for more information.\n")
                    Text("Enable Smart Toggles: enable it to start supplies automatically when you start mining, and stop mining when you stop supplies; however, this does not link them (i.e starting/stopping the first would start/stop second and visa versa). Instead, this rather loosely connects the two in an inverse relation fashion. Starting supplies does not start mining and stopping mines does not stop supplies, but starting mines starts supplies, and stopping supplies stops mining.")
                }
                Group {
                    Divider()
                    Text("General/Info")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .underline()
                        .padding(.bottom, 1)
                    Text("Clicker requires that app sandboxing is disabled since it injects keystrokes into other processes. This can be changed in System Preferences > Security & Privacy > Privacy > Accessibility. The clicker will not work with sandboxing enabled.\n")
                    Text("This clicker is designed to be run on macOS 11.0 (Big Sur) and higher.")
                }
                Group {
                    Divider()
                    Text("Known Bugs/Issues")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .underline()
                        .padding(.bottom, 1)
                    Text("Clicker starts to click slowly or may even stop clicking altogether after a few minutes of use. This is a bug within macOS and has to do with the way it handles memory. There is a workaround for this however.\n")
                    Text("Workaround: enable compact view under Menu > Show compact view or by pressing ⌘2 and split screen the clicker with the client/browser, the clicker will work reliably.\n")
                    Text("Side A/B and AFK click will not work if the game client/browser window is not focused. There is no workaround. To use side A/B or AFK the client/browser must be focused.\n")
                    Text("Report any other issues to the developer.")
                }
                Group {
                    Divider()
                    Text("\nClicker was made to be free of charge for all macOS users to whom this application was given to. If you are paying for this application, delete it and contact the developer Dennis. All credits to the programmer and creator Dennis. Do not distribute without permission.\n")
                        .font(.caption)
                        .fontWeight(.light)
                        Text("\nCopyright © 2020-2021 Dennis. All rights reserved.")
                            .font(.caption2)
                            .fontWeight(.ultraLight)
                }
            }
            .padding()
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
