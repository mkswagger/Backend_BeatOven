//
//  MainView.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        //MARK: TabView with recent posts and profile tabs
        
        TabView{
            Text("Recent Posts")
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.fill")
                    Text("Posts")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        //changing tab label tint to black
        .tint(.black)
        
    }
}

#Preview {
    ContentView()
}
