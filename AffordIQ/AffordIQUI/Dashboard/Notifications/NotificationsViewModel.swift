//
//  NotificationsViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 04.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Combine
import AffordIQFoundation
import AffordIQAuth0

class NotificationsViewModel {
    @Published var notificationSections: [NotificationSection] = []
    var notificationList: [NotificationDTO] = []
    private var subscriptions = Set<AnyCancellable>()
    private var manager: NotificationProtocol
    private var userSession: SessionType
    
    init(
        notificationManager: NotificationProtocol = NotificationManager.shared,
        userSession: SessionType = Auth0Session.shared
    ) {
        self.manager = notificationManager
        self.userSession = userSession
        
        setupListeners()
    }
    
    /// Set notifications as viewed - bell badge will be 0
    func cleanNotifications() {
        manager.cleanCounterBadge()
    }
    
    func setupListeners() {
        // Listen for notification list
        manager.notificationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedList in
                self?.notificationList = receivedList.reversed().filter { $0.userID == self?.userSession.userID }
                self?.groupNotificationsByMonths()
                self?.sortSectionsByMonths()
            }
            .store(in: &subscriptions)
    }
    
    /// Create list of notification list by months
    func groupNotificationsByMonths() {
        let groups = Dictionary(grouping: notificationList) { $0.date.firstDayOfMonth() }
        notificationSections = groups.map(NotificationSection.init(month:notifications:))
    }
    
    /// Sort notification sections by months
    func sortSectionsByMonths() {
        notificationSections.sort { lhs, rhs in lhs.month > rhs.month }
    }
}
