/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The root view controller that provides a button to start and stop recording, and which displays the speech recognition results.
*/

import UIKit
import Speech

public class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var recordButton: UIButton!
    
    // MARK: View Controller Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the record buttons until authorization has been granted.
        recordButton.isEnabled = false
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer.delegate = self
        
        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in

            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                    
                default:
                    self.recordButton.isEnabled = false
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
//        // Keep speech recognition data on device
//        if #available(iOS 13, *) {
//            recognitionRequest.requiresOnDeviceRecognition = false
//        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // self.textView.text = result.bestTranscription.formattedString
                for transcription in result.transcriptions {
                    var text : String = ""
                    let count : Int = transcription.segments.count
                    if count >= 2 {
                        text += transcription.segments[count - 2].substring + " "
                        text += transcription.segments[count - 1].substring
                    }
                    self.changeColor(text)
                }
                
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        textView.text = "Speak up big hoss"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    
    private func changeColor(_ text : String) {
        print(text)
        if text.contains("text") {
            if text.contains("red") || text.contains("read") {
                self.textView.textColor = UIColor.red
                self.textView.text = "Making text red"
            } else if text.contains("black") {
                self.textView.textColor = UIColor.black
                self.textView.text = "Making text black"
            } else if text.contains("blue") {
                self.textView.textColor = UIColor.blue
                self.textView.text = "Making text blue"
            } else if text.contains("green") {
                self.textView.textColor = UIColor.green
                self.textView.text = "Making text green"
            } else if text.contains("yellow") {
                self.textView.textColor = UIColor.yellow
                self.textView.text = "Making text yellow"
            } else if text.contains("orange") {
                self.textView.textColor = UIColor.orange
                self.textView.text = "Making text orange"
            } else if text.contains("white") {
                self.textView.textColor = UIColor.white
                self.textView.text = "Making text white"
            } else if text.contains("brown") {
                self.textView.textColor = UIColor.brown
                self.textView.text = "Making text brown"
            } else if text.contains("purple") {
                self.textView.textColor = UIColor.purple
                self.textView.text = "Making text purple"
            }
        }
        if text.contains("background") {
            if text.contains("red") || text.contains("read") {
                self.textView.backgroundColor = UIColor.red
                self.textView.text = "Making background red"
            } else if text.contains("black") {
                self.textView.backgroundColor = UIColor.black
                self.textView.text = "Making background black"
            } else if text.contains("blue") {
                self.textView.backgroundColor = UIColor.blue
                self.textView.text = "Making background blue"
            } else if text.contains("green") {
                self.textView.backgroundColor = UIColor.green
                self.textView.text = "Making background green"
            } else if text.contains("yellow") {
                self.textView.backgroundColor = UIColor.yellow
                self.textView.text = "Making background yellow"
            } else if text.contains("orange") {
                self.textView.backgroundColor = UIColor.orange
                self.textView.text = "Making background orange"
            } else if text.contains("white") {
                self.textView.backgroundColor = UIColor.white
                self.textView.text = "Making background white"
            } else if text.contains("brown") {
                self.textView.backgroundColor = UIColor.brown
                self.textView.text = "Making background brown"
            } else if text.contains("purple") {
                self.textView.backgroundColor = UIColor.purple
                self.textView.text = "Making background purple"
            }
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            do {
                try startRecording()
                recordButton.setTitle("Stop Recording", for: [])
            } catch {
                recordButton.setTitle("Recording Not Available", for: [])
            }
        }
    }
}

