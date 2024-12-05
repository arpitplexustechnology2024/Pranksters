//
//  AudioVisualize.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 21/11/24.
//

import UIKit
import AVFoundation

class AudioVisualizer: UIView {
    private var displayLink: CADisplayLink?
    private var audioRecorder: AVAudioRecorder?
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 3
    private var leftPoints: [CGFloat] = []
    private var rightPoints: [CGFloat] = []
    private let maxBars = 70
    private var isRecording = false
    
    private let centerLineWidth: CGFloat = 2
    private let centerLineColor: UIColor = .red
    private var currentOffset: CGFloat = 0
    private var staticRightPoints: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .visualizer
        layer.cornerRadius = 8
        setupStaticRightWaveform()
        setNeedsDisplay()
    }
    
    private func setupStaticRightWaveform() {
   //     let maxVisibleBars = Int(bounds.width / 2 / (barWidth + barSpacing))
        
        rightPoints = []
        for _ in 0..<maxBars {
            rightPoints.append(0.01)
        }
        staticRightPoints = rightPoints
    }
    
    func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        currentOffset = 0
        leftPoints.removeAll()
        setupAudioRecorder()
        startDisplayLink()
        audioRecorder?.record()
    }
    
    func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        stopDisplayLink()
        setNeedsDisplay()
        audioRecorder?.pause()
    }
    
    func cancelRecording() {
        guard isRecording else { return }
        isRecording = false
        stopDisplayLink()
        rightPoints = staticRightPoints
        audioRecorder?.stop()
        leftPoints.removeAll()
        currentOffset = 0
        setNeedsDisplay()
    }
    
    func resumeRecording() {
        guard !isRecording else { return }
        isRecording = true
        startDisplayLink()
        audioRecorder?.record()
    }
    
    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("temp.wav")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error)")
        }
    }
    
    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveform))
        displayLink?.preferredFramesPerSecond = 30
        displayLink?.add(to: .current, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateWaveform() {
        if isRecording {
            audioRecorder?.updateMeters()
            let power = audioRecorder?.averagePower(forChannel: 0) ?? -160
            let normalizedPower = pow(10, power/20)
            
            leftPoints.insert(CGFloat(normalizedPower), at: 0)
            currentOffset += (barWidth + barSpacing)
            
            if leftPoints.count > maxBars {
                leftPoints.removeLast()
            }
        }
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let midY = bounds.height / 2
        let maxHeight = bounds.height * 0.4
        let cornerRadius: CGFloat = 1.5
        let centerX = bounds.width / 2
        
        let visualizerColor: UIColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        context.setFillColor(visualizerColor.cgColor)
        
        for (index, power) in leftPoints.enumerated() {
            let x = centerX - (CGFloat(index) * (barWidth + barSpacing) + barWidth)
            let height = power * maxHeight
            
            let barRect = CGRect(x: x,
                               y: midY - height / 2,
                               width: barWidth,
                               height: height)
            
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: cornerRadius)
            context.addPath(path.cgPath)
            context.fillPath()
        }
        
        context.setFillColor(UIColor.lightGray.cgColor)
        
        for (index, power) in rightPoints.enumerated() {
            let x = bounds.width - (CGFloat(index) * (barWidth + barSpacing) + barWidth)
            let height = power * maxHeight
            
            if x >= centerX {
                let barRect = CGRect(x: x,
                                   y: midY - height / 2,
                                   width: barWidth,
                                   height: height)
                
                let path = UIBezierPath(roundedRect: barRect, cornerRadius: cornerRadius)
                context.addPath(path.cgPath)
                context.fillPath()
            }
        }
        
        context.setStrokeColor(centerLineColor.cgColor)
        context.setLineWidth(centerLineWidth)
        
        context.move(to: CGPoint(x: centerX, y: 0))
        context.addLine(to: CGPoint(x: centerX, y: bounds.height))
        context.strokePath()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupStaticRightWaveform()
        setNeedsDisplay()
    }
}
