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

	var audioPlayer: AVAudioPlayer? // 2
	var isPlaying: Bool { // 6
		audioPlayer?.isPlaying ?? false
	}

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
	}

	// Playback APIs

	// What are the function names I need?

	// - get audio file
	// - play
	// - pause
	// - timestamp
	// - is it playing?

	private func loadAudio() {
		// piano.mp3
		// App Bundle
		// Documents - readwrite

		let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")! // 3. Force unwrapping

		audioPlayer = try! AVAudioPlayer(contentsOf: songURL) // 4. // FIXME: catch error and print
	}

	func play() { // 7
		audioPlayer?.play()
	}

	func pause() { // 8
		audioPlayer?.pause()
	}

	func playPause() { // 9
		if isPlaying {
			pause()
		} else {
			play()
		}
	}

	// Record APIs


    @IBAction func playButtonPressed(_ sender: Any) {
		playPause() // 10
	}
    
    @IBAction func recordButtonPressed(_ sender: Any) {
    
    }
}

