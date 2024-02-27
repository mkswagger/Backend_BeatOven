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

//MARK: Register Views
struct RegisterView:View{
    @State var emailID: String = ""
    @State var password:String = ""
    @State var username:String = ""
    @State var userbio:String = ""
    @State var userbiolink:String = ""
    @State var userprofiledata:Data?
    //MARK: View Properties
    
    @Environment(\.dismiss) var dismiss
    @State var showimagePicker:Bool = false
    @State var photoItem:PhotosPickerItem?
    @State var showerror:Bool = false
    @State var errormessage: String = ""
    @State var isLoading:Bool = false
    //MARK: USER DEFAULTS
    
    @AppStorage("log_status")var logStatus:Bool = false
    @AppStorage("user_profile_url")var profileURL:URL?
    @AppStorage("user_name")var usernameStored:String = ""
    @AppStorage("user_UID")var userID:String = ""
    
    var body: some View{
        VStack(spacing: 10){
            Text("SignUp").font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Do sign Up ").font(.title3)
                .hAlign(.leading)
        //MARK: Smaller size optimisations
            
            ViewThatFits{
                VStack{
                    ScrollView{
                        HelperView()
                    }
                    HelperView()
                }
               
            }
            //MARK: Register Button
            HStack{
                Text("Already having an account?").foregroundStyle(Color.gray)
                Button("Login Now"){
                    dismiss()
                }.fontWeight(.bold)
                    .foregroundStyle(Color.black)
            }.font(.callout)
            .vAlign(.bottom)
                
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content:{
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showimagePicker, selection:$photoItem )
        .onChange(of: photoItem){newValue in
            //MARK: Extracting UI Image from photoItem
            if let newValue{
                Task{
                    do{
                        guard let imagedata = try await newValue.loadTransferable(type: Data.self)else{
                            return
                        }
                        //MARK: UI Must be updated on main thread
                        await MainActor.run(body:{ userprofiledata = imagedata})
                    
                        
                    }catch{}
                }
            }
        }
        //MARK: Displaying Alert
        .alert(errormessage, isPresented:$showerror , actions: {})
    }
    @ViewBuilder
    func HelperView()-> some View{
        
        
        VStack(spacing:12){
            
            ZStack{
                if let userprofiledata, let image = UIImage(data: userprofiledata){
                    Image(uiImage: image).resizable()
                        .aspectRatio(contentMode: .fill)
                }else{
                    Image("nullprof-img")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }.frame(width: 85, height: 85)
                .clipShape(Circle())
                .contentShape(Circle())
                .padding(.top,25)
                .onTapGesture {
                    showimagePicker.toggle()
                }
            
            TextField("Username",text: $username)
                .textContentType(.username)
                .border(1, .gray.opacity(0.5))
               
            
            TextField("Email",text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
                .padding(.top,25)
           
            
            SecureField("Password",text: $password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
                .padding(.top,25)
            
            TextField("About You",text: $userbio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
                .padding(.top,25)
            TextField("Bio Link[Optional]",text: $userbiolink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
                .padding(.top,25)
           
            
            Button(action: registerUser, label: {
                Text("Sign Up")
                    .foregroundStyle(Color.white)
            }).fillView(.black)
                .hAlign(.center)
        }
//        .disabledOpacity(username == "" || userbio == "" || emailID == "" || password == "" || userprofiledata == nil)
        .padding(.top,10)
            
        
    }
    func registerUser(){
        isLoading = true
        closekeyboard()
        Task{
            do{
                //step1 create firebase acc
               try await Auth.auth().createUser(withEmail: emailID, password: password)
                guard let userID = Auth.auth().currentUser?.uid else{return}
                guard let imageData = userprofiledata else{return}
                let Storageref = Storage.storage().reference().child("Profile_Images").child(userID)
                let _ = try await Storageref.putDataAsync(imageData)
                //step 3 download photourl
                
                let downloadurl = try await Storageref.downloadURL()
                //creating a userfirestore obj
                let user = User(username: username, userbio: userbio, userbiolink: userbiolink, userid: userID, useremail: emailID, userprofileURL: downloadurl)
                //saving userdata to firebase
                let _ = try Firestore.firestore().collection("Users").document(userID).setData(from: user, completion: {
                    error in
                    if error ==  nil{
                        //MARK: Print saved successfully
                        print("saved successfully")
                        usernameStored = username
                        self.userID = userID
                        profileURL = downloadurl
                        logStatus = true
                        
                    }
                })
                
            }catch{
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    func setError(_ error: Error)async{
        //MARK: UI MUST BE UPDATED ON MAINTHREAD
        await MainActor.run(body: {
            errormessage = error.localizedDescription
            showerror.toggle()
            isLoading = false
            
        })
    }
}
#Preview {
    LoginView()
}
//MARK: View extensions for UI Building
extension View{
    func closekeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func disabledOpacity(_ condition: Bool)-> some View{
        self.disabled(condition)
            .opacity(condition ? 0.6 : 1)
        
    }
    func hAlign(_ alignment:Alignment)-> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment:Alignment)-> some View{
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    //MARK: Custom Border View with padding

    func border(_ width: CGFloat,_ color: Color)-> some View{
        self.padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5 ,style: .continuous)
                    .stroke(color,lineWidth: width)
            }
    }
        //MARK: Custom fill view
        func fillView(_ color: Color)-> some View{
            self.padding(.horizontal,15)
                .padding(.vertical,10)
                .background{
                    RoundedRectangle(cornerRadius: 5 ,style: .continuous)
                        .fill(color)
                }
        }
        
    }



