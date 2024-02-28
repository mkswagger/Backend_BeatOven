//
//  ReusablePostsView.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI
import Firebase
struct ReusablePostsView: View {
    @Binding var posts: [Post]
    //view properties
    @State var isFetching: Bool = true
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack{// used in like onappear and keeps track of when the user is leaving the screen and entering
                if isFetching{
                    ProgressView()
                        .padding(.top,30)
                }else{
                    if posts.isEmpty{
                        //NO posts found
                        Text("No posts found")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .padding(.top,30)
                        
                    }else{
                        //displaying posts
                        Posts()
                    }
                }
                
            }
            .padding(15)
        }
        .refreshable {
            // scroll to refresh
            isFetching = true
            posts = []
            await fetchPosts()
        }
        .task{
            // fetching for one time
            guard posts.isEmpty else{return}
            await fetchPosts()
            
        }
    }
    // display fetched posts
    @ViewBuilder
    func Posts()-> some View{
        ForEach(posts){post in
//            Text(post.text)
            PostCardView(post: post){updatedPost in
                //updating post in the array
                if let index = posts.firstIndex(where: {post in
                    post.id == updatedPost.id
                    
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                }
            } onDelete: {
                // Removing Post from the array
                withAnimation(.easeInOut(duration: 0.25)){
                    posts.removeAll{post == $0}
                }
                
            }
            Divider()
                .padding(.horizontal,-15)
            
        }
    }
    // fetching posts
    
    func fetchPosts()async{
        do{
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "publishedDate", descending: true)
                .limit(to: 20)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{doc->Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
                isFetching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
