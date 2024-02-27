//
//  SocialmediaApp.swift
//  Socialmedia
//
//  Created by mathangy on 27/02/24.
//

import SwiftUI
import Firebase
@main
struct SocialmediaApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
