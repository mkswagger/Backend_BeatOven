//
//  LoginView.swift
//  Socialmedia
//
//  Created by mathangy on 27/02/24.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    //MARK: User details
    @State var emailID: String = ""
    @State var password:String = ""
    
    //MARK: View Properties
    @State var createAccount: Bool = false
    @State var showerror:Bool = false
    @State var errorMessage:String = ""
    @State var isloading:Bool = false
    
    @AppStorage("user_profile_url") var profileURL:URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus:Bool = false
    
    var body: some View {
        VStack(spacing: 10){
            Text("SignIn").font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Do sign in ").font(.title3)
                .hAlign(.leading)
            VStack(spacing:12){
                TextField("Email",text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top,25)
                
                SecureField("Password",text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top,25)
                
                Button(action: resetpassword, label: {
                    Text("Reset Password?")
                }).font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button(action: loginuser, label: {
                    Text("Sign In")
                        .foregroundStyle(Color.white)
                }).fillView(.black)
                    .hAlign(.center)
            }.padding(.top,10)
            
            
            //MARK: Register Button
            HStack{
                Text("Dont have an account?").foregroundStyle(Color.gray)
                Button("Register Now"){
                    createAccount.toggle()
                }.fontWeight(.bold)
                    .foregroundStyle(Color.black)
            }.font(.callout)
            .vAlign(.bottom)
                
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content:{
            LoadingView(show: $isloading)
        })
        //MARK: Register Views
        .fullScreenCover(isPresented: $createAccount){
            RegisterView()
        }
        //MARK: Displaying alert
        .alert(errorMessage,isPresented: $showerror ,actions: {})
    }
    func loginuser(){
        isloading = true
        closekeyboard()
        Task{
            do{
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("user found")
                try await fetchUser()
            }
            catch{
                await setError(error)
            }
        }
    }
    //MARK: IF USER FOUND THEN FETCHING USER DATA FROM FIRESTORE
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        //MARK : UI UPDATING IN MAIN THREAD
        await MainActor.run(body: {
            //setting user defaults and changing app's auth status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userprofileURL
            logStatus = true
        })
    }
    func resetpassword(){
        Task{
            do{
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            }
            catch{
                await setError(error)
            }
        }
    }
    //MARK: Disaplying error via alert
    func setError(_ error: Error)async{
        //MARK: UI MUST BE UPDATED ON MAINTHREAD
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showerror.toggle()
        })
        isloading = false
    }
}


#Preview {
    LoginView()
}
