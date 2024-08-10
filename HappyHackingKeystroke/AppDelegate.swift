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
    var audioPlayer: AVAudioPlayer!
    var sound: NSSound?
    
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
            self?.logger.info("[TabActionManager] \(status)")
        } onKeydown: { [weak self] keycode in
            self?.playKeystroke(keycode: keycode)
        }
        sound = NSSound(named: "a")
    }
    
    private func playKeystroke(keycode: Int64) {
        playSound(file: "a", ext: "mp3")
    }
    
    private func playSound(file:String, ext:String) -> Void {
        sound?.stop()
        sound?.play()
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
