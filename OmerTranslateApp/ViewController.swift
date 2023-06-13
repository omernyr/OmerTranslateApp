//
//  ViewController.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 10.06.2023.
//

import UIKit
import SnapKit
import Vision
import AVFoundation
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    //MARK: Speech
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Konuşma tanıma için kullanılacak dile göre ayarlayın
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioSession = AVAudioSession.sharedInstance()
    
    
    private var string: String?
    private var strings: [String] = []
    private let imagePickerController = UIImagePickerController()
    
    private lazy var newVC: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(goToNewVC), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameAppLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick translation"
        label.textColor = .black
        label.font = UIFont(name: "Gilroy-Medium", size: 41.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var libraryLabel: UILabel = {
        let label = UILabel()
        label.text = "Conversation"
        label.textColor = .black
        label.font = UIFont(name: "Gilroy-Medium", size: 15.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var speakLabel: UILabel = {
        let label = UILabel()
        label.text = "Speak"
        label.textColor = .black
        label.font = UIFont(name: "Gilroy-Medium", size: 15.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var cameraLabel: UILabel = {
        let label = UILabel()
        label.text = "Camera"
        label.textColor = .black
        label.font = UIFont(name: "Gilroy-Medium", size: 15.0)
        label.textAlignment = .center
        return label
    }()
    
    private let convertedBackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UIColor(hexString: "FEF9EF")
        return view
    }()
    
    private let resultBackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UIColor(hexString: "FEF9EF")
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1.0
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 5.0
        return imageView
    }()
    
    private lazy var libraryImageButton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: .scaleAspectFit, tintColor: .white, cornerRadius: 40.0, imageViewString: "person.line.dotted.person.fill")
        button.backgroundColor = UIColor(hexString: "A2D2FF")
        button.setPreferredSymbolConfiguration(.init(pointSize: 20.0, weight: .bold), forImageIn: .normal)
        button.addTarget(self, action: #selector(goToConversVC), for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraImageButton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: .scaleAspectFit, tintColor: .white, cornerRadius: 40.0, imageViewString: "camera")
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.backgroundColor = UIColor(hexString: "9685FF")
        button.setPreferredSymbolConfiguration(.init(pointSize: 20.0, weight: .bold), forImageIn: .normal)
        return button
    }()
    
    private lazy var microphoneButton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: .scaleAspectFit, tintColor: .white, cornerRadius: 55.0, imageViewString: "mic.fill")
        button.addTarget(self, action: #selector(microphoneButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(microphoneButtonTouchUp), for: .touchUpInside)
        button.backgroundColor = UIColor(hexString: "FF865E")
        button.setPreferredSymbolConfiguration(.init(pointSize: 20.0, weight: .bold), forImageIn: .normal)
        return button
    }()

    private lazy var copyPastebutton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: .scaleAspectFit, tintColor: .black, cornerRadius: nil, imageViewString: "rectangle.portrait.on.rectangle.portrait")
        button.addTarget(self, action: #selector(copyText), for: .touchUpInside)
        return button
    }()
    
    @objc private lazy var editButton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: nil, tintColor: .black, cornerRadius: nil, imageViewString: "square.and.pencil")
        button.addTarget(self, action: #selector(editResult), for: .touchUpInside)
        return button
    }()
    
    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Gilroy-Medium", size: 19.0)
        textView.layer.cornerRadius = 10.0
        textView.textColor = .black
        textView.textAlignment = .center
        textView.backgroundColor = UIColor(hexString: "FEF9EF")
        return textView
    }()
    
    private let convertedTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Gilroy-Medium", size: 19.0)
        textView.layer.cornerRadius = 10.0
        textView.textColor = .black
        textView.backgroundColor = UIColor(hexString: "FEF9EF")
        textView.textAlignment = .center
        textView.isEditable = false
        return textView
    }()
    
    private let translateButton: UIButton = {
        let button = UIButton()
        button.buildButton(contentMode: .scaleToFill, tintColor: .secondaryLabel, cornerRadius: nil, imageViewString: "arrow.up.arrow.down")
        button.setTitle("Translate to", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = UIFont(name: "Gilroy-Medium", size: 15.0) // Yazı boyutunu küçültmek için
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        SFSpeechRecognizer.requestAuthorization { authStatus in
            var isEnabled = false
            
            switch authStatus {
            case .authorized:
                isEnabled = true
                
            case .denied:
                isEnabled = false
                print("Kullanıcı konuşma tanıma iznini reddetti")
                
            case .restricted:
                isEnabled = false
                print("Konuşma tanıma engellendi")
                
            case .notDetermined:
                isEnabled = false
                print("Konuşma tanıma izni henüz belirlenmedi")
                
            @unknown default:
                isEnabled = false
                print("Bilinmeyen bir hata oluştu")
            }
            
            DispatchQueue.main.async {
                self.microphoneButton.isEnabled = isEnabled
            }
        }
        
        let rightBtn = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(myBtn))
        navigationItem.leftBarButtonItem = rightBtn
    }
    
    @objc func myBtn() {
        printContent("btn")
    }
    
    @objc private func goToConversVC() {
        let vc = ConversationViewController()
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
    
    @objc private func goToNewVC() {
        let vc = NewViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func microphoneButtonTouchDown(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
        } else {
            startRecording()
        }
    }
    
    @objc func microphoneButtonTouchUp(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            microphoneButton.isEnabled = false
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
                
                self.resultTextView.text = speechResultText
                
                APICaller().translateText(text: speechResultText, fromLanguage: "en", targetLanguage: "tr") { translatedText, error in
                    if let error = error {
                        print("Çeviri hatası: \(error.localizedDescription)")
                    } else if let translatedText = translatedText {
                        DispatchQueue.main.async {
//                            self.showTextLetterByLetter(text: translatedText)
                            self.convertedTextView.text = translatedText
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
                
                self.microphoneButton.isEnabled = true
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
        
        resultTextView.text = "Dinleme Başladı..."
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    @objc func openCamera() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus == .authorized {
            openCameraController()
        } else if cameraAuthorizationStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.openCameraController()
                    } else {
                        // Kullanıcı kamera erişim iznini vermedi
                        // Gerekirse uygun bir bildirim gösterebilirsiniz
                    }
                }
            }
        } else {
            // Kullanıcının kamera erişim izni yok veya reddedildi
            // Gerekirse uygun bir bildirim gösterebilirsiniz
        }
    }
    
    func openCameraController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        } else {
            // Cihazda kamera kullanılamıyor
            // Gerekirse uygun bir bildirim gösterebilirsiniz
        }
    }
    
    @objc private func editResult() {
        resultTextView.becomeFirstResponder() // Klavyeyi açar
    }
    
    @objc private func copyText() {
        UIPasteboard.general.string = string
    }
    
    @objc private func selectPhoto() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    private func setupUI() {
        
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(libraryImageButton)
        view.addSubview(cameraImageButton)
        view.addSubview(microphoneButton)
        view.addSubview(translateButton)
        view.addSubview(resultBackView)
        view.addSubview(convertedBackView)
        view.addSubview(libraryLabel)
        view.addSubview(speakLabel)
        view.addSubview(cameraLabel)
        view.addSubview(nameAppLabel)
        view.addSubview(newVC)
        resultBackView.addSubview(resultTextView)
        resultBackView.addSubview(editButton)
        convertedBackView.addSubview(copyPastebutton)
        convertedBackView.addSubview(convertedTextView)
        
        resultTextView.delegate = self
        imagePickerController.delegate = self
        speechRecognizer?.delegate = self
        configureConstraints()
        addGestureRecognizerToConvertedTextView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true) // Klavyeyi kapat
    }
    
    private func addGestureRecognizerToConvertedTextView() {
        let oneTapPressGesture = UITapGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        oneTapPressGesture.numberOfTapsRequired = 2
        convertedTextView.addGestureRecognizer(oneTapPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .ended {
            if let text = convertedTextView.text {
                UIPasteboard.general.string = text
            }
        }
    }
    
    private func configureConstraints() {
        
        libraryImageButton.snp.makeConstraints { make in
            make.width.height.equalTo(80.0)
            make.bottom.equalToSuperview().inset(90.0)
            make.left.equalToSuperview().inset(30.0)
        }
        
        cameraImageButton.snp.makeConstraints { make in
            make.width.height.equalTo(80.0)
            make.bottom.equalToSuperview().inset(90.0)
            make.right.equalToSuperview().inset(30.0)
        }
        
        microphoneButton.snp.makeConstraints { make in
            make.width.height.equalTo(110.0)
            make.centerY.equalTo(cameraImageButton.snp.centerY)
            make.centerX.equalToSuperview()
        }

        resultTextView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(110.0)
            make.centerX.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
            make.bottom.equalTo(resultBackView.snp.bottom).inset(10.0)
            make.right.equalToSuperview().inset(10.0)
            make.width.equalTo(30.0)
            make.height.equalTo(30.0)
        }
        
        resultBackView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20.0)
            make.height.equalTo(150.0)
            make.centerX.equalToSuperview()
        }
        
        convertedTextView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(110.0)
            make.centerX.equalToSuperview()
        }
        
        copyPastebutton.snp.makeConstraints { make in
            make.bottom.equalTo(convertedBackView.snp.bottom).inset(10.0)
            make.right.equalToSuperview().inset(10.0)
            make.width.equalTo(30.0)
            make.height.equalTo(30.0)
        }
        
        convertedBackView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20.0)
            make.height.equalTo(150.0)
            make.centerX.equalToSuperview()
            make.top.equalTo(translateButton.snp.bottom).offset(10.0)
            make.bottom.equalTo(microphoneButton.snp.top).offset(-50.0)
        }
        
        translateButton.snp.makeConstraints { make in
            make.width.equalTo(200.0)
            make.height.equalTo(30.0)
            make.centerX.equalToSuperview()
            make.top.equalTo(resultBackView.snp.bottom).offset(10.0)
        }
        
        libraryLabel.snp.makeConstraints { make in
            make.width.equalTo(110.0)
            make.height.equalTo(20.0)
            make.centerX.equalTo(libraryImageButton.snp.centerX)
            make.top.equalTo(libraryImageButton.snp.bottom).offset(5.0)
        }
        
        speakLabel.snp.makeConstraints { make in
            make.width.equalTo(60.0)
            make.height.equalTo(20.0)
            make.centerX.equalTo(microphoneButton.snp.centerX)
            make.top.equalTo(microphoneButton.snp.bottom).offset(5.0)
        }
        
        cameraLabel.snp.makeConstraints { make in
            make.width.equalTo(60.0)
            make.height.equalTo(20.0)
            make.centerX.equalTo(cameraImageButton.snp.centerX)
            make.top.equalTo(cameraImageButton.snp.bottom).offset(5.0)
        }
        
        nameAppLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(50.0)
//            make.height.equalTo(80.0)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(resultBackView.snp.top).offset(-20.0)
        }
        
        newVC.snp.makeConstraints { make in
            make.width.height.equalTo(80.0)
            make.bottom.equalTo(nameAppLabel.snp.top).offset(20.0)
            make.centerX.equalToSuperview()
        }
        
    }
    
    private func recognizeText(image: UIImage?) {
        
        guard let cgImage = image?.cgImage else { return }
        
        // MARK: Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // MARK: Request
        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
            let text = observations.compactMap { item in
                item.topCandidates(1).first?.string
            }.joined(separator: " ")
            
            DispatchQueue.main.async {
                self.showTextLetterByLetter(text: text)
                print("İngilizce -->> \(text)")
                
                APICaller().translateText(text: "\(text)", fromLanguage: "en", targetLanguage: "tr") { (translatedText, error) in
                    if let error = error {
                        print("Çeviri hatası: \(error.localizedDescription)")
                    } else if let translatedText = translatedText {
                        DispatchQueue.main.async {
//                            self.showTextLetterByLetter(text: translatedText)
                            self.convertedTextView.text = translatedText
                            // TODO: copy - paste
                            self.string = translatedText
                            // UIPasteboard.general.string = translatedText
                        }
                        print("Çeviri sonucu: \(translatedText)")
                    }
                }
            }
        }
        
        // MARK: Process
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func showTextLetterByLetter(text: String) {
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if index < text.count {
                let character = text[text.index(text.startIndex, offsetBy: index)]
                self.resultTextView.text.append(character)
                index += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let imageSelected = info[.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = imageSelected
            imageView.layer.cornerRadius = 10.0
            //            cancelButton.isHidden = false
            //            addButton.isHidden = false
            recognizeText(image: imageSelected)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let text = textView.text else { return }
        
        APICaller().translateText(text: text, fromLanguage: "en", targetLanguage: "tr") { translatedText, error in
            if let error = error {
                print("Çeviri hatası: \(error.localizedDescription)")
            } else if let translatedText = translatedText {
                DispatchQueue.main.async {
                    
                    self.convertedTextView.text = translatedText
                    // TODO: copy - paste
                    self.string = translatedText
                    // UIPasteboard.general.string = translatedText
                }
                print("Çeviri sonucu: \(translatedText)")
            }
        }
        
        
        print(resultTextView.text ?? "")
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        return true
        
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder() // Klavyeyi kapat
        return true
    }
}


