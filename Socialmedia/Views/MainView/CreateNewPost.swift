import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import AVFoundation

struct CreateNewPost: View {
    var onPost: (Post)->()
    @State private var postText: String = ""
    @State private var postImageData: Data?
    @State private var audioURL: URL?
    @State private var publishedDate: Date?
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName:String = ""
    @AppStorage("user_UID") private var userUID:String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading:Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showAudioPicker = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var showkeyboard: Bool
    @State private var player: AVPlayer?

    var body: some View {
        VStack{
            HStack{
                Menu{
                    Button("Cancel",role: .destructive){
                        dismiss()
                    }
                }label:{
                    Text("Cancel").font(.callout)
                        .foregroundStyle(Color.black)
                }
                .hAlign(.leading)
                Button(action:createPost){
                    Text("Post")
                        .font(.callout)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal,20)
                        .padding(.vertical,6)
                        .background(.black,in: Capsule())
                }.disabledOpacity(postText == "")
            }
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: 15){
                    TextField("Whats happening?", text: $postText, axis: .vertical)
                        .focused($showkeyboard)
                    if let postImageData, let image = UIImage(data: postImageData){
                        GeometryReader{
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            //delete button
                                .overlay(alignment: .topTrailing){
                                    Button{
                                        withAnimation(.easeInOut(duration: 0.25)){
                                            self.postImageData = nil
                                        }
                                    }label:{
                                        Image(systemName: "trash").tint(.red)
                                            .fontWeight(.bold)
                                    }
                                    .padding(10)
                                }
                        }
                        .clipped()
                        .frame(height:220)
                    }
                    if let audioURL = audioURL {
                                        AudioPlayerView(url: audioURL)
                                    }
                }
                .padding(15)
            }
            Divider()
            HStack{
                Button{
                    showImagePicker.toggle()
                }label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                }
                Button {
                    showAudioPicker = true
                } label: {
                    Image(systemName: "music.note")
                        .font(.title3)
                }.sheet(isPresented: $showAudioPicker) {
                    AudioPicker(audioURL: $audioURL)
                }
            }
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem){newValue in
            if let newValue{
                Task{
                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self
                    ), let image = UIImage(data: rawImageData),let compressedImageData = image.jpegData(compressionQuality: 0.5){
                        //UI Must be done on mainthread
                        await MainActor.run(body: {
                            postImageData = compressedImageData
                            photoItem = nil
                        })
                    }
                }
            }
        }
        .alert(errorMessage,isPresented: $showError,actions: {})
        //loading View
        .overlay{
            LoadingView(show: $isLoading)
        }
    }
    //MARK: Post Content to firebase
    func createPost(){
        isLoading = true
        showkeyboard = false
        Task{
            do{
                guard let profileURL = profileURL else{return}
                //step 1 upload image if any
                //used to delete the post later
                let imageReferenceID = "\(userUID)\(Date())"
                let storageref = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                
//                let songReferenceID = "\(userUID)\(Date())"
//                let storageref = Storage.storage().reference().child("Post_Audio").child(songReferenceID)
                
                if let postImageData{
                    
                    let _ = try await storageref.putDataAsync(postImageData)
                    let downloadURL = try await storageref.downloadURL()
                    //create post obj with image id and url
                    let post = Post(text: postText, imageURL: downloadURL,imageReferenceID: imageReferenceID, publishedDate: Date(), username: userName, userUID : userUID, userProfileURL: profileURL)
//                    let post = Post(text: postText, publishedDate: publishedDate! , username: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                }else{
                    //directly post text data to firebase(no imgs present condition)
                    let post = Post(text: postText,publishedDate: Date(), username: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                    
                }
            }catch{
                await setError(error)
                
            }
        }
    }
    func createDocumentAtFirebase(_ post: Post)async throws{
        //writing doc into firebase firestore
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: post, completion: {error in
            if error == nil{
                //post successfully stored at firebase
                isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                onPost(updatedPost)
                dismiss()
            }
        })
        
    }
    //MARK: Displaying errors as alerts
    
    func setError(_ error: Error) async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

//struct AudioPicker: UIViewControllerRepresentable {
//    @Binding var audioURL: URL?
//
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        var parent: AudioPicker
//
//        init(_ parent: AudioPicker) {
//            self.parent = parent
//        }
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let url = urls.first else { return }
//            parent.audioURL = url
//        }
//    }
//}

struct AudioPicker: UIViewControllerRepresentable {
    @Binding var audioURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Add code here to update the `UIDocumentPickerViewController` when the SwiftUI view updates.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        var parent: AudioPicker

        init(_ parent: AudioPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.audioURL = url
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.audioURL = nil
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

class Player: ObservableObject {
    let url: URL
    @Published var player: AVPlayer?
    @Published var isPlaying = false

    init(url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
    }

    func playPause() {
        guard let player = player else { return }
        if player.rate == 0 {
            isPlaying = true
            player.play()
        } else {
            isPlaying = false
            player.pause()
        }
    }
}

struct AudioPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            Button(action: {
                if player?.rate == 0 {
                    player?.play()
                } else {
                    player?.pause()
                }
            }) {
                Image(systemName: player?.rate == 0 ? "play.fill" : "pause.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
        }
        .onAppear {
            player = AVPlayer(url: url)
        }
        .onDisappear {
            player?.pause()
        }
    }
}

#Preview {
    CreateNewPost{_ in
    }
}




////
////  CreateNewPost.swift
////  Socialmedia
////
////  Created by user4 on 28/02/24.
////
//
//import SwiftUI
//import PhotosUI
//import Firebase
//import FirebaseStorage
//
//struct CreateNewPost: View {
//    var onPost: (Post)->()
//    @State private var postText: String = ""
//    @State private var postImageData: Data?
//    @State private var publishedDate: Date?
//    //@State var postSongData: Data?
//    //stored user data from user defaults (app storage)
//    @AppStorage("user_profile_url") private var profileURL: URL?
//    @AppStorage("user_name") private var userName:String = ""
//    @AppStorage("user_UID") private var userUID:String = ""
//    //view props
//    @Environment(\.dismiss) private var dismiss
//    @State private var isLoading:Bool = false
//    @State private var errorMessage: String = ""
//    @State private var showError: Bool = false
//    @State private var showImagePicker: Bool = false
//    @State private var photoItem: PhotosPickerItem?
//    @FocusState private var showkeyboard: Bool
//    var body: some View {
//        VStack{
//            HStack{
//                Menu{
//                    Button("Cancel",role: .destructive){
//                        dismiss()
//                    }
//                }label:{
//                    Text("Cancel").font(.callout)
//                        .foregroundStyle(Color.black)
//                }
//                .hAlign(.leading)
//                Button(action:createPost){
//                    Text("Post")
//                        .font(.callout)
//                        .foregroundStyle(Color.white)
//                        .padding(.horizontal,20)
//                        .padding(.vertical,6)
//                        .background(.black,in: Capsule())
//                }.disabledOpacity(postText == "")
//            }
//            .padding(.horizontal,15)
//            .padding(.vertical,10)
//            .background{
//                Rectangle()
//                    .fill(.gray.opacity(0.05))
//                    .ignoresSafeArea()
//            }
//            ScrollView(.vertical, showsIndicators: false){
//                VStack(spacing: 15){
//                    TextField("Whats happening?", text: $postText, axis: .vertical)
//                        .focused($showkeyboard)
//                    if let postImageData, let image = UIImage(data: postImageData){
//                        GeometryReader{
//                            let size = $0.size
//                            Image(uiImage: image)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: size.width, height: size.height)
//                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                            //delete button
//                                .overlay(alignment: .topTrailing){
//                                    Button{
//                                        withAnimation(.easeInOut(duration: 0.25)){
//                                            self.postImageData = nil
//                                        }
//                                    }label:{
//                                        Image(systemName: "trash").tint(.red)
//                                            .fontWeight(.bold)
//                                    }
//                                    .padding(10)
//                                }
//                        }
//                        .clipped()
//                        .frame(height:220)
//                    }
//                }
//                .padding(15)
//            }
//            Divider()
//            HStack{
//                Button{
//                    showImagePicker.toggle()
//                }label: {
//                    Image(systemName: "photo.on.rectangle")
//                        .font(.title3)
//                        
//                    
//                }
//                .hAlign(.leading)
//                Button("Done"){
//                    showkeyboard = false
//                }
//            }
//            .foregroundStyle(Color.black)
//            .padding(.horizontal,15)
//                .padding(.vertical,10)
//        }
////        .vAlign(.top)
////        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
////        .onChange(of: photoItem){newValue in
////            if let newValue{
////                Task{
////                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self
////                    ), let image = UIImage(data: rawImageData),let compressedImageData = image.jpegData(compressionQuality: 0.5){
////                        //UI Must be done on mainthread
////                        await MainActor.run(body: {
////                            postImageData = compressedImageData
////                            photoItem = nil
////                        })
////                    }
////                }
////            }
////        }
////        .alert(errorMessage,isPresented: $showError,actions: {})
////        //loading View
////        .overlay{
////            LoadingView(show: $isLoading)
////        }
////    }
////    //MARK: Post Content to firebase
////    func createPost(){
////        isLoading = true
////        showkeyboard = false
////        Task{
////            do{
////                guard let profileURL = profileURL else{return}
////                //step 1 upload image if any
////                //used to delete the post later
////                let imageReferenceID = "\(userUID)\(Date())"
////                let storageref = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
////                
////                if let postImageData{
////                    
////                    let _ = try await storageref.putDataAsync(postImageData)
////                    let downloadURL = try await storageref.downloadURL()
////                    //create post obj with image id and url
////                    let post = Post(text: postText, imageURL: downloadURL,imageReferenceID: imageReferenceID, publishedDate: Date(), username: userName, userUID : userUID, userProfileURL: profileURL)
//////                    let post = Post(text: postText, publishedDate: publishedDate! , username: userName, userUID: userUID, userProfileURL: profileURL)
////                    try await createDocumentAtFirebase(post)
////                }else{
////                    //directly post text data to firebase(no imgs present condition)
////                    let post = Post(text: postText,publishedDate: Date(), username: userName, userUID: userUID, userProfileURL: profileURL)
////                    try await createDocumentAtFirebase(post)
////                    
////                }
////            }catch{
////                await setError(error)
////                
////            }
////        }
////    }
////    func createDocumentAtFirebase(_ post: Post)async throws{
////        //writing doc into firebase firestore
////        let doc = Firestore.firestore().collection("Posts").document()
////        let _ = try doc.setData(from: post, completion: {error in
////            if error == nil{
////                //post successfully stored at firebase
////                isLoading = false
////                var updatedPost = post
////                updatedPost.id = doc.documentID
////                onPost(updatedPost)
////                dismiss()
////            }
////        })
////        
////    }
////    //MARK: Displaying errors as alerts
////    
////    func setError(_ error: Error) async{
////        await MainActor.run(body: {
////            errorMessage = error.localizedDescription
////            showError.toggle()
////        })
////    }
////}
////
////#Preview {
////    CreateNewPost{_ in 
////    }
////}
//
