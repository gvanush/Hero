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


fileprivate struct SignalSample {
    var valueItem: SignalValueItem?
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
            0.5 * lineWidth + CGFloat(1.0 - value) * (rect.height - lineWidth)
        }
        
        var path = Path()
        
        var slice = samples[samples.startIndex..<samples.endIndex]
        
        outer: while var index = slice.lastIndex(where: { $0.valueItem != nil }) {
            
            var x = getX(samples[index].timestamp)
            guard x >= rect.minX else {
                break
            }
            
            let lastValueItem = samples[index].valueItem!
            var y = getY(lastValueItem.value)
            
            path.move(to: .init(x: x, y: y))
            path.addLine(to: .init(x: x, y: y)) // for drawing solo samples
            
            guard lastValueItem.interpolate else {
                slice = samples[samples.startIndex..<index]
                continue
            }
            
            index = samples.index(before: index)
            
            while index >= samples.startIndex {
                
                guard x >= rect.minX else {
                    break outer
                }
                
                guard let valueItem = samples[index].valueItem else {
                    break
                }
                
                x = getX(samples[index].timestamp)
                y = getY(valueItem.value)
                
                path.addLine(to: .init(x: x, y: y))
                
                guard valueItem.interpolate else {
                    break
                }
                
                index = samples.index(before: index)
            }
            
            if index < samples.startIndex {
                break
            }
            
            slice = samples[samples.startIndex..<index]
        }
        
        return path
        
    }
    
}

struct SignalValueItem {
    var value: Float
    var interpolate = true
}

/*
 The goal is to draw the signal as it will appear when applied to the objects. Therefore signal is sampled
 on display sync rather than using the source samples of the signal. For example, gesture sampling rate
 can be more than the screen refresh rate however only gesture samples sampled during display sync
 are drawn.
 */
struct SignalGraphView: View {
    
    @Binding var restartFlag: Bool
    let signal: (Int, TimeInterval) -> SignalValueItem?
    let onStart: () -> Void
    @State private var samples = Deque<SignalSample>()
    @State private var timer = Timer.publish(every: TimeInterval.infinity, on: .main, in: .common).autoconnect()
    @State private var startTime: TimeInterval?
    @State private var time: TimeInterval = 0.0
    @State private var fps: Double = 1.0
    private var showsRestartIcon = true
    
    static let samplingRate = UIScreen.main.maximumFramesPerSecond
    static let lineWidth: CGFloat = 1.5
    
    init(restartFlag: Binding<Bool> = .constant(false), signal: @escaping (Int, TimeInterval) -> SignalValueItem?, onStart: @escaping () -> Void) {
        _restartFlag = restartFlag
        self.signal = signal
        self.onStart = onStart
    }
    
    var body: some View {
        GeometryReader { geometry in
            SignalGraph(samples: samples, signalMaxFrequency: Self.samplingRate, lineWidth: Self.lineWidth)
                .stroke(.primary, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round, lineJoin: .round))
                .clipped()
                .background { background }
                .modifier(SizeModifier())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(contentMode: .fit)
        .overlay(alignment: .bottomTrailing, content: {
            if showsRestartIcon {
                Button {
                    restartFlag = true
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .tint(.primary)
                .frame(width: 34.0, height: 34.0)
            }
        })
        .onFrame { frame in
            guard let startTime = startTime, !restartFlag else {
                startTime = frame.timestamp
                time = 0.0
                samples.removeAll()
                onStart()
                restartFlag = false
                return
            }
            let lastTime = time
            time = frame.timestamp - startTime
            fps = 1.0 / (time - lastTime)
            samples.append(.init(valueItem: signal(Self.samplingRate, time), timestamp: time))
        }
        .onPreferenceChange(SizePreferenceKey.self) { size in
            timer = Timer.publish(every: graphTimespan(width: size.width, signalMaxFrequency: Self.samplingRate, lineWidth: Self.lineWidth), on: .main, in: .common).autoconnect()
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
    
    func showsRestartIcon(_ shows: Bool) -> some View {
        var view = self
        view.showsRestartIcon = shows
        return view
    }
    
    var background: some View {
        ZStack {
            VStack {
                HStack {
                    Text("1")
                        .font(.caption)
                        .foregroundColor(.secondaryLabel)
                    Spacer()
                    Group {
                        Text(Measurement(value: time, unit: UnitDuration.seconds), formatter: Self.timeFormatter)
                        Divider()
                            .padding(.vertical, 4.0)
                        Text(Measurement(value: fps, unit: UnitFrequency.framesPerSecond), formatter: Self.fpsFormatter)
                    }
                    .font(.callout.monospacedDigit())
                    .foregroundColor(.tertiaryLabel)
                }
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
                ZStack {
                    HStack {
                        Text("0")
                            .font(.caption)
                            .foregroundColor(.secondaryLabel)
                        Spacer()
                    }
                    HStack(spacing: 2.0) {
                        Spacer()
                        if let valueItem = samples.last?.valueItem {
                            Group {
                                Image(systemName: "bolt")
                                    .imageScale(.small)
                                Text(NSNumber(value: valueItem.value), formatter: Self.valueFormatter)
                            }
                            .font(.callout.monospacedDigit())
                            .foregroundColor(.secondaryLabel)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 4.0)
        }
        .background(content: {
            Color.secondarySystemBackground
        })
        .cornerRadius(4.0)
        .shadow(radius: 0.5)
    }
    
    static let timeFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.numberFormatter.roundingMode = .halfEven
        formatter.numberFormatter.minimumFractionDigits = 1
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    } ()
    
    static let fpsFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.roundingMode = .halfEven
        formatter.numberFormatter.minimumFractionDigits = 0
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    } ()
    
    static let valueFormatter = {
        let formatter = NumberFormatter()
        formatter.roundingMode = .halfEven
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    } ()
    
}

struct SignalGraphView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
