//
//  SignalGraphView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.07.22.
//

import SwiftUI
import DequeModule
import DisplayLink
import Combine


struct SignalSample {
    var value: Float?
    let timestamp: TimeInterval
}

fileprivate func graphTimespan(width: CGFloat, signalMaxFrequency: Int, lineWidth: CGFloat) -> TimeInterval {
    TimeInterval(width / (CGFloat(signalMaxFrequency) * lineWidth))
}

fileprivate func graphWidth(timespan: TimeInterval, signalMaxFrequency: Int, lineWidth: CGFloat) -> CGFloat {
    CGFloat(timespan * TimeInterval(signalMaxFrequency)) * lineWidth
}

/*
 Draws the graph of given signal prvoided in 'samples'.
 Expects 'samples' to be sorted in ascending order by 'timestamp' property, so that the first one is the earliest sample.
 x axis is the time and y axis is the value. The latest sample is drawn at the rightmost location,
 and the rest of the samples are drawn to the left of it (to the past time).
 
 Allocates one logical unit on screen along x axis per sample to fully reflect the signal without aliasing.
 This way each sample will be mapped to a ditinct logical point on the screen.
 For this reason it receives the 'signalMaxFrequency' so that delta time interval between two neighboring samples
 is bigger than or equal to 1 / 'signalMaxFrequency'. So delta times 'signalMaxFrequency' will be at least one.
 
 
 This all means that signal with higher frequency will be wider on the screen and move from right to left faster when
 new samples are pushed. However since presenting the oroginal signal is a priority this a acceptable and inteded.
 */
fileprivate struct SignalGraph<V>: Shape where V: RandomAccessCollection, V.Element == SignalSample {
    
    let samples: V
    let signalMaxFrequency: Int
    let lineWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        guard !samples.isEmpty else { return Path() }
        
        let latestSampleTimestamp = samples.last!.timestamp
        let getX = { timestamp in
            rect.maxX - graphWidth(timespan: latestSampleTimestamp - timestamp, signalMaxFrequency: signalMaxFrequency, lineWidth: lineWidth)
        }
        let getY = { (value: Float) in
            CGFloat(1.0 - value) * rect.height
        }
        
        var path = Path()
        
        var slice = samples[samples.startIndex..<samples.endIndex]
        
        outer: while var index = slice.lastIndex(where: { $0.value != nil }) {
            
            var x = getX(samples[index].timestamp)
            var y = getY(samples[index].value!)
            
            path.move(to: .init(x: x, y: y))
            if x >= rect.minX {
                path.addLine(to: .init(x: x, y: y)) // for drawing samples without neighbors
            }
            index = samples.index(before: index)
            
            while index >= samples.startIndex && samples[index].value != nil {
                
                if x < rect.minX {
                    break outer
                }
                
                x = getX(samples[index].timestamp)
                y = getY(samples[index].value!)
                
                path.addLine(to: .init(x: x, y: y))
                
                if index == samples.startIndex {
                    break
                }
                index = samples.index(before: index)
            }
            
            slice = samples[samples.startIndex..<index]
        }
        
        return path
        
    }
    
}

/*
 The goal is to draw the signal as it will appear when applied to the objects. Therefore signal is sampled
 on display sync rather than using the source samples of the signal. For example, gesture sampling rate
 can be more than the screen refresh rate however only gesture samples sampled during display sync
 are drawn.
 */
struct SignalGraphView: View {
    
    let name: String
    let signal: () -> Float?
    @State private var samples = Deque<SignalSample>()
    @State private var timer = Timer.publish(every: TimeInterval.infinity, on: .main, in: .common).autoconnect()
    
    static let signalMaxFrequency = UIScreen.main.maximumFramesPerSecond
    static let lineWidth: CGFloat = 1.5
    
    var body: some View {
        GeometryReader { geometry in
            SignalGraph(samples: samples, signalMaxFrequency: Self.signalMaxFrequency, lineWidth: Self.lineWidth)
                .stroke(.primary, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round, lineJoin: .round))
                .background { background }
                .modifier(SizeModifier())
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .onFrame { frame in
            samples.append(.init(value: signal(), timestamp: frame.timestamp))
        }
        .onPreferenceChange(SizePreferenceKey.self) { size in
            timer = Timer.publish(every: graphTimespan(width: size.width, signalMaxFrequency: Self.signalMaxFrequency, lineWidth: Self.lineWidth), on: .main, in: .common).autoconnect()
        }
        .onReceive(timer) { _ in
            
            guard !samples.isEmpty else { return }
            
            // Remove samples older than graph's timespan relative to the latest sample
            let latestSampleTimestamp = samples.last!.timestamp
            if let count = samples.firstIndex(where: { latestSampleTimestamp - $0.timestamp <= timer.upstream.interval }) {
                samples.removeFirst(count)
            } else {
                samples.removeAll()
            }
        }
    }
    
    var background: some View {
        ZStack {
            Color.systemFill
            VStack {
                HStack {
                    Spacer()
                    Text("1")
                        .font(.callout)
                        .foregroundColor(.tertiaryLabel)
                }
                Spacer()
                ZStack {
                    HStack {
                        Spacer()
                        Text("0")
                            .font(.callout)
                            .foregroundColor(.tertiaryLabel)
                    }
                    HStack(spacing: 4.0) {
                        Spacer()
                        Image(systemName: "waveform.path.ecg")
                        Text(name)
                        Spacer()
                    }
                    .font(.callout)
                    .foregroundColor(.secondaryLabel)
                }
            }
            .padding(.horizontal, 4.0)
        }
    }
    
}

struct SignalGraphView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
