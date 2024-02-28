//
//  PostCardView.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseStorage

struct PostCardView: View {
    var post: Post
    //callbacks
    var onUpdate: (Post)->()
    var onDelete: ()->()
    //view properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListener: ListenerRegistration? //for live updates
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6){
                Text(post.username)
                    .font(.callout)
                    .fontWeight(.semibold)
//                Text((post.publishedDate?.formatted(date: .numeric, time: .shortened))!)
//                    .font(.caption2)
//                    .foregroundStyle(Color.gray)
                if let publishedDate = post.publishedDate{
                    Text(publishedDate.formatted(date: .numeric, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(Color.gray)
                }
                else{
                    Text("No date")
                }
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical,8)
                //post image if any
                if let postImageURL = post.imageURL{
                    GeometryReader{
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                    }
                    .frame(height: 200)
                }
                PostInteraction()
            }
        }
        .shadow(radius: 10)
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            //displaying delete button if it is author's post
            if post.userUID == userUID{
                Menu{
                    Button("Delete Post", role: .destructive , action: {})
                }label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundStyle(Color.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x:8)
            }
            
        })
        .onAppear{
            if docListener == nil{
                guard let postID = post.id else{return}
                docListener = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({snapshot, error in
                    if let snapshot{
                        if snapshot.exists{
                            //document updated
                            //fetching updated doc
                            if let updatedPost = try? snapshot.data(as: Post.self){
                                onUpdate(updatedPost)
                            }
                        }else{
                            onDelete()
                        }
                    }
                })
                
            }
        }
    }
    // MARK: Like/Dislike Interaction
    
    @ViewBuilder
    func PostInteraction()->some View{
        HStack(spacing: 6){
            Button(action: likePost){
                Image(systemName: post.likedIDs.contains(userUID) ? "heart.fill" : "heart" )
                //checks if user's name is in the array of likedids and if yes the colour changes else no
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundStyle(Color.gray)
        }
        .foregroundStyle(Color.black)
        .padding(.vertical,8)
        
    }
    //liking post
    func likePost(){
        Task{
            guard let postID = post.id else{return}
            if post.likedIDs.contains(userUID){ //remove the user's uid id the person has already liked if not add to the array
                //removing user id from the array
               try await  Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
                
            }else{
                //see for removing part once and update
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID])
                ])
            }
        }
    }
    //delete post
    
}


