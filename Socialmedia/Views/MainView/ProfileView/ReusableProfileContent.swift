//
//  ReusableProfileContent.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI
import SDWebImageSwiftUI
struct ReusableProfileContent: View {
    var user:User
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack{
                HStack(spacing: 12){
                    WebImage(url: user.userprofileURL).placeholder{
                        //MARK: Placeholder image
                        Image("NullProfile")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100 , height: 100)
                    .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 6){
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(user.userbio)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .lineLimit(3)
                        // MARK: Displaying Bio Link, If given while signin
                        if let bioLink = URL(string: user.userbiolink){
                            Link(user.userbiolink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                Text("Posts").font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                    .hAlign(.leading)
                    .padding(.vertical,15)
               
            }.padding(15)
        }
    }
}

