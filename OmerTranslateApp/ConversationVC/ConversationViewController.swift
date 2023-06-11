//
//  ConversationViewController.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 11.06.2023.
//

import UIKit
import SnapKit
import Vision
import AVFoundation
import Speech

class ConversationViewController: UIViewController {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Konuşma tanıma için kullanılacak dile göre ayarlayın
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioSession = AVAudioSession.sharedInstance()
    
    private lazy var leftMicrophoneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.addTarget(self, action: #selector(microphoneButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(microphoneButtonTouchUp), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.tintColor = .white
        button.backgroundColor = UIColor(hexString: "FF865E")
        button.layer.cornerRadius = 40.0
        button.setPreferredSymbolConfiguration(.init(pointSize: 20.0, weight: .bold), forImageIn: .normal)
        return button
    }()
    
    private lazy var rightMicrophoneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.addTarget(self, action: #selector(microphoneButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(microphoneButtonTouchUp), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.tintColor = .white
        button.backgroundColor = UIColor(hexString: "9685FF")
        button.layer.cornerRadius = 40.0
        button.setPreferredSymbolConfiguration(.init(pointSize: 20.0, weight: .bold), forImageIn: .normal)
        return button
    }()
    
    private lazy var newLabel: UILabel = {
        let label = UILabel()
        label.text = "result"
        label.textAlignment = .center
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.black.cgColor
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let btn = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(deleteBTN))
        setupUI()
        
    }
    
    @objc private func deleteBTN() {
        print("delete")
    }
    
    private func setupUI() {
        view.addSubview(leftMicrophoneButton)
        view.addSubview(rightMicrophoneButton)
        view.addSubview(newLabel)
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        leftMicrophoneButton.snp.makeConstraints { make in
            make.width.height.equalTo(80.0)
            make.bottom.equalToSuperview().inset(90.0)
            make.left.equalToSuperview().inset(30.0)
        }
        
        rightMicrophoneButton.snp.makeConstraints { make in
            make.width.height.equalTo(80.0)
            make.bottom.equalToSuperview().inset(90.0)
            make.right.equalToSuperview().inset(30.0)
        }
        
        newLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(10.0)
            make.height.equalTo(50.0)
            make.bottom.equalTo(rightMicrophoneButton.snp.top).offset(-20.0)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func microphoneButtonTouchDown(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            leftMicrophoneButton.isEnabled = false
        } else {
            startRecording()
        }
    }
    
    @objc func microphoneButtonTouchUp(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            leftMicrophoneButton.isEnabled = false
        }
    }
    
    func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session hatası: \(error)")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("SFSpeechAudioBufferRecognitionRequest oluşturulamadı")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                
                let speechResultText = result.bestTranscription.formattedString
                
                self.newLabel.text = speechResultText
                
                APICaller().translateText(text: speechResultText, targetLanguage: "tr") { translatedText, error in
                    if let error = error {
                        print("Çeviri hatası: \(error.localizedDescription)")
                    } else if let translatedText = translatedText {
                        DispatchQueue.main.async {
//                            self.showTextLetterByLetter(text: translatedText)
//                            self.convertedTextView.text = translatedText
                            // TODO: copy - paste
//                            self.string = translatedText
                            // UIPasteboard.general.string = translatedText
                        }
                        print("Çeviri sonucu: \(translatedText)")
                    }
                }
                
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.leftMicrophoneButton.isEnabled = true
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine hatası: \(error)")
        }
        
        newLabel.text = "Dinleme Başladı..."
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
}
