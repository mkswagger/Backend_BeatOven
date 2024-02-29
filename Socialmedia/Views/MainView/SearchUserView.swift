//
//  SearchUserView.swift
//  Socialmedia
//
//  Created by user4 on 29/02/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
struct SearchUserView: View {
    //view properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            List{
                ForEach(fetchedUsers){
                    user in
                    NavigationLink{
                        
                    }label: {
                        Text(user.username)
                            .font(.callout)
                            .hAlign(.leading)
                    }
                }
            }.listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Search User")
                .searchable(text: $searchText)
                .onSubmit(of: .search, {
                    Task{await searchUsers()}
                })
                .toolbar{
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Cancel"){
                            dismiss()
                        }
                        .tint(.black)
                    }
                }
        }
    }
    func searchUsers()async{
        do{
            let querylowerCased = searchText.lowercased()
            let queryupperCased = searchText.uppercased()
            let documents = try await Firestore.firestore().collection("Users").whereField("username", isGreaterThanOrEqualTo:queryupperCased)
                .whereField("username", isLessThanOrEqualTo: "\(querylowerCased)\u{f8ff}")
                .getDocuments()
        }catch{
            print(error.localizedDescription)
        }
    }
}

#Preview {
    SearchUserView()
}
