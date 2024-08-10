//
//  CGEventTapAction.swift
//  HappyHackingKeystroke
//
//  Created by Oliver Le on 10/8/24.
//

import Foundation
import OSLog
import Cocoa

final class CGEventTapAction {
    let logger: Logger

    private var runState: RunState? = nil

    private struct RunState {
        let port: CFMachPort
        let setStatus: (String) -> Void
        let onKeydown: (Int64) -> Void
    }

    init() {
        self.logger = Logger.eventTapAction
    }
    
    func start(_ setStatus: @escaping (String) -> Void, onKeydown: @escaping (Int64) -> Void) {
        precondition(self.runState == nil)
        
        logger.debug("will create tap")
        let info = Unmanaged.passRetained(self).toOpaque()
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        guard let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { (proxy, type, event, info) -> Unmanaged<CGEvent>? in
                let obj = Unmanaged<CGEventTapAction>.fromOpaque(info!).takeUnretainedValue()
                obj.didReceiveEvent(event)
                // We don’t replace the event, so the new event is the same as
                // the old event, so we return it unretained.
                return Unmanaged.passUnretained(event)
            },
            userInfo: info
        ) else {
            logger.debug("did not create tap")
            // We retained `self` above, but the event tap didn’t get created so
            // we need to clean up.
            Unmanaged<CGEventTapAction>.fromOpaque(info).release()
            setStatus("Failed to create event tap.")
            return
        }
        let rls = CFMachPortCreateRunLoopSource(nil, port, 0)!
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, .defaultMode)
        self.runState = RunState(port: port, setStatus: setStatus, onKeydown: onKeydown)
        logger.debug("did create tap")
    }
    
    private func didReceiveEvent(_ event: CGEvent) {
        logger.debug("did receive event")
        guard let runState = self.runState else { return }
        runState.setStatus("Last event at \(Date()).")
        let keycode = event.getIntegerValueField(.keyboardEventKeycode)
        runState.onKeydown(keycode)
    }

    func stop() {
        guard let runState = self.runState else { return }
        self.runState = nil

        logger.debug("will stop tap")
        CFMachPortInvalidate(runState.port)
        // We passed a retained copy of `self` to the `info` parameter
        // when we created the tap.  We need to release that now that we’ve
        // invalidated the tap.
        Unmanaged.passUnretained(self).release()
        logger.debug("did stop tap")
    }
}
