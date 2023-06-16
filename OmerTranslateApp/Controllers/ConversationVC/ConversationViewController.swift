//
//  ConversationViewController.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 11.06.2023.
//

import UIKit
import SnapKit
import AVFoundation
import Speech
import MessageKit

public struct Message: MessageType {
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}


class ConversationViewController: MessagesViewController, MessagesLayoutDelegate {
    
    var messageString = ""
    
    let currentUser = Sender(senderId: "any_unique_id", displayName: "Steven")
    let otherUser = Sender(senderId: "any_unique_id2", displayName: "Ali")
    
    var leftBtnTapped: Bool? = nil
    var rightBtnTapped: Bool? = nil
    
    var messages: [MessageType] = []
    
    private let speechRecognizerTR = SFSpeechRecognizer(locale: Locale(identifier: "tr-TR")) // Konuşma tanıma için kullanılacak dile göre ayarlayın
    private let speechRecognizerEN = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Konuşma tanıma için kullanılacak dile göre ayarlayın
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioSession = AVAudioSession.sharedInstance()
    
    private lazy var leftMicrophoneButton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: .scaleAspectFit, tintColor: .white, cornerRadius: 40.0, imageViewString: "mic.fill")
        button.backgroundColor = UIColor(hexString: "#fc8e5b")
        button.setPreferredSymbolConfiguration(.init(pointSize: 20.0, weight: .bold), forImageIn: .normal)
        button.addTarget(self, action: #selector(leftMicrophoneButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(leftMicrophoneButtonTouchUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightMicrophoneButton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: .scaleAspectFit, tintColor: .white, cornerRadius: 40.0, imageViewString: "mic.fill")
        button.backgroundColor = UIColor(hexString: "d9abff")
        button.setPreferredSymbolConfiguration(.init(pointSize: 20.0, weight: .bold), forImageIn: .normal)
        button.addTarget(self, action: #selector(rightMicrophoneButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(rightMicrophoneButtonTouchUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var newLabel: UILabel = {
        let label = UILabel()
        label.buildLabel(text: "Use microphone and say something", textColor: nil, fontName: "Gilroy-Medium", fontSize: 21.0, alignment: .center)
        label.backgroundColor = UIColor(hexString: "ddffab")
        label.layer.cornerRadius = 5.0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        
        messageInputBar.isHidden = true
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date(), kind: .text("Say something you want translated 🐥")))
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date(), kind: .text("Mikrofana basılı tut ve kendini akışa bırak. 🐢")))
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messagesCollectionView.reloadData()
        
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
        
        messagesCollectionView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY).offset(20.0)
        }
    }
    
    @objc func leftMicrophoneButtonTouchDown(_ sender: UIButton) {
        leftBtnTapped = true
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            leftMicrophoneButton.isEnabled = false
        } else {
            startRecording()
        }
    }
    
    @objc func leftMicrophoneButtonTouchUp(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            leftMicrophoneButton.isEnabled = false
        }
        
        APICaller().translateText(text: messageString, fromLanguage: "tr", targetLanguage: "en") { translatedText, error in
            if let error = error {
                print("Çeviri hatası: \(error.localizedDescription)")
            } else if let translatedText = translatedText {
                
                DispatchQueue.main.async {
//                    self.messageString = translatedText
                    if !translatedText.isEmpty {
                        let message = Message(sender: self.otherUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(translatedText))
                        self.messages.append(message)
                    }
                    
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
                print("Çeviri sonucu: \(translatedText)")
            }
        }
        
    }
    
    @objc func rightMicrophoneButtonTouchDown(_ sender: UIButton) {
        rightBtnTapped = true
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            leftMicrophoneButton.isEnabled = false
        } else {
            startRecording()
        }
    }
     
    @objc func rightMicrophoneButtonTouchUp(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            leftMicrophoneButton.isEnabled = false
        }
        
        APICaller().translateText(text: messageString, fromLanguage: "en", targetLanguage: "tr") { translatedText, error in
            if let error = error {
                print("Çeviri hatası: \(error.localizedDescription)")
            } else if let translatedText = translatedText {
                
                DispatchQueue.main.async {
//                    self.messageString =
                    if !translatedText.isEmpty {
                        let message = Message(sender: self.currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(translatedText))
                        self.messages.append(message)
                    }
                    
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
                print("Çeviri sonucu: \(translatedText)")
            }
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
        
        if leftBtnTapped == true {
            recognitionTask = speechRecognizerTR?.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    let speechResultText = result.bestTranscription.formattedString
                    
                    self.newLabel.text = speechResultText
                    self.messageString = speechResultText
                    
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
        } else if rightBtnTapped == true {
            recognitionTask = speechRecognizerEN?.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    let speechResultText = result.bestTranscription.formattedString
                    
                    self.newLabel.text = speechResultText
                    self.messageString = speechResultText
                    
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

extension ConversationViewController: MessagesDataSource {
    var currentSender: SenderType {
        return currentUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    
    
}
                          

extension ConversationViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {

        if message.sender.senderId == otherUser.senderId {
            return UIColor(hexString: "#fc8e5b")
        } else {
            return UIColor(hexString: "#d9abff")
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == otherUser.senderId {
            return .white
        } else {
            return .white
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if message.sender.senderId == currentUser.senderId {
            avatarView.initials = "🇺🇸"
            avatarView.backgroundColor = UIColor(hexString: "#d9abff")
            
        } else {
            avatarView.initials = "🇹🇷"
            avatarView.backgroundColor = UIColor(hexString: "#fc8e5b")
        }
        
    }
    
}

