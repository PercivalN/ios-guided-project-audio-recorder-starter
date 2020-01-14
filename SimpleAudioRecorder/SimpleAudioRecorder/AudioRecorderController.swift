//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Paul Solt on 10/1/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation // 1. for audio players

class AudioRecorderController: UIViewController {




    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
	
	private lazy var timeFormatter: DateComponentsFormatter = {
		let formatting = DateComponentsFormatter()
		formatting.unitsStyle = .positional // 00:00  mm:ss
		// NOTE: DateComponentFormatter is good for minutes/hours/seconds
		// DateComponentsFormatter not good for milliseconds, use DateFormatter instead)
		formatting.zeroFormattingBehavior = .pad
		formatting.allowedUnits = [.minute, .second]
		return formatting
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// monospace is good for timers because all the txt have the same spacing
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)

		loadAudio() // 5
		updateViews() // 28

	}

	// Playback APIs

	// What are the function names I need?

	// - get audio file
	// - play
	// - pause
	// - timestamp
	// - is it playing?

	var audioPlayer: AVAudioPlayer? // 2
	var timer: Timer? // 10

	private func loadAudio() {
		// piano.mp3
		// App Bundle
		// Documents - readwrite

		let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")! // 3. Force unwrapping

		audioPlayer = try! AVAudioPlayer(contentsOf: songURL) // 4. // FIXME: catch error and print
		audioPlayer?.delegate = self // 29
	}

	var isPlaying: Bool { // 6
		audioPlayer?.isPlaying ?? false
	}

	func play() { // 7
		audioPlayer?.play()
		updateViews() // 15
		startTimer() // 21
	}

	func pause() { // 8
		audioPlayer?.pause()
		updateViews() // 16
		cancelTimer() // 22
	}

	func playPause() { // 9
		if isPlaying {
			pause()
		} else {
			play()
		}
	}

	private func startTimer() { // 17
		cancelTimer() // 23
		timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
	}

	@objc private func updateTimer(timer: Timer) { // 18
		updateViews()
	}

	private func cancelTimer() { // 18
		timer?.invalidate() // 19
		timer = nil // 20
	}

	// Record APIs


    @IBAction func playButtonPressed(_ sender: Any) {
		playPause() // 10
	}

	// Record APIs

	var audioRecorder: AVAudioRecorder? // 33
	var recordURL: URL? // 49

	var isRecording: Bool { // 34
		return audioRecorder?.isRecording ?? false
	}

	func record() { // 35
		let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! // 36

		let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime]) // 37
		let file = documents.appendingPathComponent(name).appendingPathExtension("caf") // 38
		recordURL = file // 50

		print("record: \(file)") // 39

		// 44.1 KHz is good audio sampling
		let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)! // 40 // FIXME: error handling

		audioRecorder = try! AVAudioRecorder(url: file, format: format) // 41
		audioRecorder?.delegate = self // 48
		audioRecorder?.record() // 43
		updateViews() // 47
	}

	func stop() { // 36
		audioRecorder?.stop()
		audioRecorder = nil
		updateViews() // 46
	}

	func recordToggle() { // 37
		if isRecording {
			stop()
		} else {
			record()
		}

		//isRecording ? stop() : record()
	}

    @IBAction func recordButtonPressed(_ sender: Any) {
		recordToggle() // 42
		updateViews() // 45
    }

	private func updateViews() {
		let playButtonTitle = isPlaying ? "Pause" : "Play" // 11 // Pause or Play
		playButton.setTitle(playButtonTitle, for: .normal) // 12

		let elapsedTime = audioPlayer?.currentTime ?? 0 // 13 // If nothing is playing then it goes to zero
		//timeLabel.text = "\(elapsedTime)" // 14
		timeLabel.text = timeFormatter.string(for: elapsedTime) // 14 // 24

		// This is per asset
		timeSlider.minimumValue = 0 // 25
		timeSlider.maximumValue = Float(audioPlayer?.duration ?? 0) // 26
		timeSlider.value = Float(elapsedTime) // 27

		let recordButtonTitle = isRecording ? "Stop" : "Record" // 43
		recordButton.setTitle(recordButtonTitle, for: .normal) // 44
	}
}

extension AudioRecorderController: AVAudioPlayerDelegate { // 30

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		updateViews() // 31
	}

	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
		if let error = error {
			print("Audio player error: \(error)") // 32
		}
	}
}

extension AudioRecorderController: AVAudioRecorderDelegate { // 48

	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) { // 52
		if let error = error {
			print("Audio recorder error: \(error)")
		}
	}

	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) { //53

		// TODO: 
		print("Finished Recording")
		if let recordURL = recordURL {
			audioPlayer = try! AVAudioPlayer(contentsOf: recordURL)
		}
	}
}

