//
//  SpeedtestView.swift
//  SpeedtestView
//
//  Created by Dennis Litvinenko on 7/21/21.
//

import SwiftUI

struct ClicksHistory {
    let id = UUID()
    let seconds: Int
    let cycles: Int
}

struct SpeedtestView: View {
    @Binding var debugTimer: Timer.TimerPublisher
    @Binding var clicksPerCycle: Int
    @Binding var secondsElapsed: Int
    @Binding var totalClicks: Int
    @State private var clicksPerCycleHistory = [ClicksHistory]()
    @State private var rate = 0.0
    @State private var speedtestText = ""
    @State private var cycle = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Click speed: \(rate, specifier: "%.2f") c/s")
            Divider()
            Text("Clicks per cycle: \(cycle)")
            List {
                ForEach(clicksPerCycleHistory, id: \.id) { item in
                    Text("Seconds: \(item.seconds), clicks: \(item.cycles)")
                }
            }
            Spacer()
        }
        .padding()
        .frame(width: 250, height: 350)
        .onReceive(debugTimer) {_ in
            if secondsElapsed == 0 {
                clicksPerCycleHistory.removeAll()
            }
            secondsElapsed += 1
            rate = Double(totalClicks)/Double(secondsElapsed)
            
            cycle = clicksPerCycle
            clicksPerCycleHistory.append(ClicksHistory(seconds: secondsElapsed, cycles: clicksPerCycle))
            clicksPerCycle = 0
        }
    }
}
