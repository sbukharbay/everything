//
//  FirebaseDBManager.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 22/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseCore

enum FirebaseEnvironment: String {
    case debugDatabaseURL = "https://affordiq-development-default-rtdb.europe-west1.firebasedatabase.app/"
    case demoDatabaseURL = "https://affordiq-staging-default-rtdb.europe-west1.firebasedatabase.app/"
    case prodDatabaseURL = "https://affordiq-default-rtdb.europe-west1.firebasedatabase.app/"
}

/// Firebase realtime database manager
public class FirebaseDBManager {
    public static var shared = FirebaseDBManager()
    
    var reference: DatabaseReference
    
    private init() {
        #if DEBUG
        reference = Database.database(url: FirebaseEnvironment.debugDatabaseURL.rawValue).reference()
        #elseif DEMO
        reference = Database.database(url: FirebaseEnvironment.demoDatabaseURL.rawValue).reference()
        #else
        reference = Database.database(url: FirebaseEnvironment.prodDatabaseURL.rawValue).reference()
        #endif
    }
    
    func getDataFromFirebaseDB(with url: String) async -> DataSnapshot? {
        do {
            return try await reference.child(url).getData()
        } catch {
            print(error)
        }
        
        return nil
    }
}
