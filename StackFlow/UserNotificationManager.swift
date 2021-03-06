//
//  NotificationManager.swift
//  StackFlow
//
//  Created by Huai-Che Lu on 3/30/17.
//  Copyright © 2017 Keymochi. All rights reserved.
//

import Cocoa
import Foundation

public typealias UserNotificationDidActivateAction = (_ userNotification: NSUserNotification) -> Void

public class UserNotificationManager: NSObject {
    static private var instance: UserNotificationManager!
    
    var initiateFlowUserNotificationDidActivateAction: UserNotificationDidActivateAction?
    var contextSwitchingUserNotificationDidActivateAction: UserNotificationDidActivateAction?
    
    fileprivate static let contextSwitchingUserNotificationIdentifier = "StackFlow.Notification.ContextSwitching"
    fileprivate static let initiateFlowUserNotificationIdentifier = "StackFlow.Notification.InitiateFlow"
    
    static var sharedInstance: UserNotificationManager {
        // Lazy instantiation
        if instance == nil {
            instance = UserNotificationManager()
            instance.userNotificationCenter.delegate = instance
        }
        return instance!
    }
    
    static func setSharedInstance(to: UserNotificationManager?) {
        instance = to
    }
    
    private var productName: String {
        return "StackFlow" // Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
    
    private var userNotificationCenter: NSUserNotificationCenter {
        return NSUserNotificationCenter.default
    }
    
    public func sendInitiateFlowUserNotification(forMaxMinutes maxMinutes: UInt, didActivateAction: UserNotificationDidActivateAction?) {
        let userNotification = packageUserNotification(withTitle: self.productName,
                                                       informativeText: "\(maxMinutes / 60) hours of free time until the next meeting! Want to initiate a flow time?",
                                                       actionButtonTitle: "Sure",
                                                       alternativeActionButtonTitles: ["2 hr", "1.5 hr", "1 hr"],
                                                       identifier: UserNotificationManager.initiateFlowUserNotificationIdentifier)
        userNotificationCenter.deliver(userNotification)
        
        initiateFlowUserNotificationDidActivateAction = didActivateAction
    }
    
    public func sendContextSwitchingUserNotification(withDidActivateAction didActivateAction: UserNotificationDidActivateAction?) {
        let userNotification = packageUserNotification(withTitle: self.productName, informativeText: "Do you want to take a breath?", actionButtonTitle: "Breathe", alternativeActionButtonTitles: nil, identifier: UserNotificationManager.contextSwitchingUserNotificationIdentifier)
        userNotificationCenter.deliver(userNotification)
        
        contextSwitchingUserNotificationDidActivateAction = didActivateAction
    }
    
    private func packageUserNotification(withTitle title: String?,
                                         informativeText: String?,
                                         actionButtonTitle: String?,
                                         alternativeActionButtonTitles: [String]?,
                                         identifier: String?) -> NSUserNotification {
        let userNotification = NSUserNotification()
        
        userNotification.title = title
        userNotification.informativeText = informativeText
        userNotification.soundName = NSUserNotificationDefaultSoundName
        userNotification.hasActionButton = true
        if let actionButtonTitle = actionButtonTitle {
            userNotification.actionButtonTitle = actionButtonTitle
        }
        
        if let alternativeActionButtonTitles = alternativeActionButtonTitles {
            userNotification.setValue(true, forKey: "_alwaysShowAlternateActionMenu")
            userNotification.setValue(alternativeActionButtonTitles, forKey: "_alternateActionButtonTitles")
            userNotification.additionalActions = alternativeActionButtonTitles.map {
                NSUserNotificationAction(identifier: $0, title: $0)
            }
        }
        
        userNotification.identifier = identifier
        
        return userNotification
    }
}

extension UserNotificationManager: NSUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("Notification delivered: \(notification)")
    }
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        print("Notification activated: \(notification)")
        
        
        switch notification.activationType {
        case .additionalActionClicked, .actionButtonClicked:
            if let identifier = notification.identifier {
                switch identifier {
                case UserNotificationManager.initiateFlowUserNotificationIdentifier:
                    initiateFlowUserNotificationDidActivateAction?(notification)
                case UserNotificationManager.contextSwitchingUserNotificationIdentifier:
                    contextSwitchingUserNotificationDidActivateAction?(notification)
                default:
                    print("not supported")
                }
            }
        case .contentsClicked:
            print("Contents Clicked")
        case .replied:
            print("Replied")
        case .none:
            print("None")
        }
    }
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
