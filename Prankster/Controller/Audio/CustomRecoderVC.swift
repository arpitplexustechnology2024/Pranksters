//
//  CustomRecoderVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 21/11/24.
//

import UIKit
import AVFoundation

class CustomRecoderVC: UIViewController {
    
    // MARK: - Images
    private let audioRecorderImage = UIImage(named: "AudioRecoder")
    private let pauseImage = UIImage(named: "Pause")
    private let playImage = UIImage(named: "Play")
    
    // MARK: - UI Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recorder"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = .systemFont(ofSize: 40, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let visualizer = AudioVisualizer()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .icon
        button.isEnabled = false
        button.backgroundColor = .recordeBtn
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AudioRecoder"), for: .normal)
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .icon
        button.isEnabled = false
        button.backgroundColor = .recordeBtn
        return button
    }()
    
    // MARK: - Properties
    private var timer: Timer?
    private var isRecording = false
    private var isPaused = false
    private var recordingSeconds = 0
    private var audioRecorder: AVAudioRecorder?
    weak var delegate: SaveRecordingDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupAudioRecorder()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .comman
        
        [titleLabel, timeLabel, visualizer, cancelButton, recordButton, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [cancelButton, recordButton, saveButton].forEach { button in
            button.layer.cornerRadius = 30
            button.layer.masksToBounds = true
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            visualizer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            visualizer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            visualizer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            visualizer.heightAnchor.constraint(equalToConstant: 300),
            
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -40),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalToConstant: 60),
            recordButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -50),
            cancelButton.widthAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            saveButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: 50),
            saveButton.widthAnchor.constraint(equalToConstant: 60),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Audio Recorder Setup
    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("temp.wav")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error)")
        }
    }
    
    // MARK: - Actions Setup
    private func setupActions() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func recordButtonTapped() {
        if !isRecording {
            startRecording()
            visualizer.startRecording()
            recordButton.setImage(pauseImage, for: .normal)
            cancelButton.isEnabled = true
            saveButton.isEnabled = true
        } else if !isPaused {
            pauseRecording()
            visualizer.stopRecording()
            recordButton.setImage(playImage, for: .normal)
            cancelButton.isEnabled = true
            saveButton.isEnabled = true
        } else {
            resumeRecording()
            visualizer.resumeRecording()
            recordButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @objc private func cancelButtonTapped() {
        stopRecording()
        visualizer.cancelRecording()
        cancelButton.isEnabled = false
        saveButton.isEnabled = false
        recordButton.setImage(audioRecorderImage, for: .normal)
        isPaused = false
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        stopRecording()
        visualizer.stopRecording()
        cancelButton.isEnabled = false
        saveButton.isEnabled = false
        recordButton.setImage(audioRecorderImage, for: .normal)
        isPaused = false
        
        let audioURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("temp.wav")
        
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let topViewController = UIApplication.shared.windows.first?.rootViewController {
                let savePopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveRecordingPopup") as! SaveRecordingPopup
                savePopup.recordedAudioURL = audioURL
                savePopup.delegate = self.delegate
                savePopup.modalTransitionStyle = .crossDissolve
                savePopup.modalPresentationStyle = .overCurrentContext
                topViewController.present(savePopup, animated: true)
            }
        }
    }
    
    private func startRecording() {
        isRecording = true
        audioRecorder?.record()
        startTimer()
    }
    
    private func pauseRecording() {
        isRecording = true
        isPaused = true
        audioRecorder?.pause()
        timer?.invalidate()
    }
    
    private func resumeRecording() {
        isRecording = true
        isPaused = false
        audioRecorder?.record()
        startTimer()
    }
    
    private func stopRecording() {
        isRecording = false
        isPaused = false
        audioRecorder?.stop()
        stopTimer()
    }
    
    private func startTimer() {
        var seconds = recordingSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            seconds += 1
            self?.recordingSeconds = seconds
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            self?.timeLabel.text = String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingSeconds = 0
        timeLabel.text = "00:00"
        isPaused = false
    }
}
