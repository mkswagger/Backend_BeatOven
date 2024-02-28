//
//  PostsView.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI

struct PostsView: View {
    @State private var recentPosts: [Post] = []
    @State private var createNewPost: Bool = false
    var body: some View {
        NavigationStack{
            ReusablePostsView(posts: $recentPosts)            .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing){
                    Button{
                        createNewPost.toggle()
                    }label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(13)
                            .background(.black,in:Circle())
                    }
                    .padding(15)
                }
                .navigationTitle("Posts")
        }
            .fullScreenCover(isPresented: $createNewPost){
                CreateNewPost{post in
                    // adding created posts at the top of the recent posts
                    recentPosts.insert(post, at: 0)
                }
            }
    }
}

#Preview {
    PostsView()
}
