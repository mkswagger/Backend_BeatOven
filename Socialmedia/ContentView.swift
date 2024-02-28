//
//  ContentView.swift
//  Socialmedia
//
//  Created by mathangy on 27/02/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status")var logStatus:Bool = false
    var body: some View {
        if(logStatus){
            MainView()
        }else{
            LoginView()
        }
        
    }
}

#Preview {
    ContentView()
}
