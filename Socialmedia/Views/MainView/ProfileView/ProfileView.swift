//
//  ProfileView.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    //MARK: My profile Data
    @State private var myProfile:User?
    @AppStorage("log_status") var logStatus:Bool = false
    //MARK: View Properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile{
                    ReusableProfileContent(user: myProfile )
                        .refreshable {
                            //MARK: Refresh User Data
                            self.myProfile = nil
                            await fetchUserData()
                            
                        }
                }else{
                    ProgressView()
                }
            }
            
            .navigationTitle("My Profile")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Menu{
                        //MARK: Two actions
                        //Logout, delete account
                        
                        Button("Logout",action: logOutUser)
                        Button("Delete Account",role: .destructive,action: deleteAccount)
                    }label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay{
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage , isPresented: $showError){
            
        }
        .task{
            //MARK: Initial Fetch
            //module like onAppear so fetch for first time only
            if myProfile != nil{
                return
            }
            await fetchUserData()
        }
    }
    //MARK: Fetching user data
    
    func fetchUserData()async{
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else{return}
        await MainActor.run(body:{
            myProfile = user
        })
    }
    //MARK: Logging User out
    func logOutUser(){
        try?Auth.auth().signOut()
        logStatus = false
    }
    // MARK: Deleting user Account
    func deleteAccount(){
        isLoading = true
        Task{
            do{
                guard let UserID = Auth.auth().currentUser?.uid else{return}
                //Step 1 : First delete profile img
                let reference = Storage.storage().reference().child("Profile_Images").child(UserID)
                try await reference.delete()
                //step 2: delete firestore user doc
                
                try  await Firestore.firestore().collection("Users").document(UserID).delete()
                // Final step delete Auth account and setting up log status to false
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            }catch{
                await setError(error)
            }
            
            
        }
    }
   //MARK: Setting Error
    func setError(_ error: Error)async{
        //MARK: UI must be run on main thread
        
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

#Preview {
    ContentView()
}
