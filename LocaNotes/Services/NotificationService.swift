//
//  NotificationService.swift
//  LocaNotes
//
//  Created by Anthony C on 2/28/21.
//

import Foundation
import UserNotifications

class NotificationService {
    let center: UNUserNotificationCenter
    
    init() {
        center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            // handle denial in this closure
        }
    }
}
