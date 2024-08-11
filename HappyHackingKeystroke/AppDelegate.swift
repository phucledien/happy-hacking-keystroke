//
//  AppDelegate.swift
//  HappyHackingKeystroke
//
//  Created by Oliver Le on 10/8/24.
//

import Cocoa
import OSLog
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    
    var logger: Logger!
    var eventTabActionManager: CGEventTapAction!
    var currentAudioPlayerIndex = 0
    var audioPlayers: [AVAudioPlayer] = []
    var lastKeycode: Int64 = -1
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        initServices()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func initServices() {
        logger = Logger.custom(category: "AppDeletegate")
        
        eventTabActionManager = CGEventTapAction()
        eventTabActionManager.start { [weak self] status in
            self?.logger.debug("[TabActionManager] \(status)")
        } onKeyDown: { [weak self] keycode in
            self?.playKeystroke(keycode: keycode)
        } onKeyUp: { [weak self] keycode in
            guard let self = self else {return}
            // If key up -> reset last keycode
            if (keycode == self.lastKeycode) {
                self.lastKeycode = -1
            }
        }
    }
    
    private func playKeystroke(keycode: Int64) {
        if lastKeycode == keycode {
            return
        }
        playSound(file: "a", ext: "mp3")
        lastKeycode = keycode
    }
    
    private func playSound(file:String, ext:String) -> Void {
        guard let url = Bundle.main.url(forResource: file, withExtension: ext) else {
            return
        }
        
        // Setup simple ring buffer
        let maxBuffer = 10
        self.currentAudioPlayerIndex += 1
        if (self.currentAudioPlayerIndex >= maxBuffer) {
            self.currentAudioPlayerIndex = 0;
        }
        
       
        var audioPlayer = audioPlayers.item(at: currentAudioPlayerIndex)
        
        if audioPlayer != nil {
            do {
                audioPlayers[currentAudioPlayerIndex] = try AVAudioPlayer(contentsOf: url)
                audioPlayer = audioPlayers.item(at: currentAudioPlayerIndex)
            } catch {
                logger.error("Init the audio player failed \(error)")
            }
        } else {
            do {
                let newAudioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayers.append(newAudioPlayer)
                audioPlayer = newAudioPlayer
            } catch {
                logger.error("Init the audio player failed \(error)")
            }
        }
        
        
        guard let audioPlayer = audioPlayer else {
            // this should never happen
            return
        }
     
        audioPlayer.stop()
        audioPlayer.play()
    }
}

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the view cycles like a view that appeared.
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")

    /// All logs related to tracking and analytics.
    static let statistics = Logger(subsystem: subsystem, category: "statistics")
    
    /// All logs related to Keydown Action.
    static let eventTapAction = Logger(subsystem: subsystem, category: "eventTapAction")

    static func custom(category: String) -> Logger {
        return Logger(subsystem: subsystem, category: category)
    }
}

extension Array {
    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
