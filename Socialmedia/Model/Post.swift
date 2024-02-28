//
//  Post.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI
import FirebaseFirestoreSwift
// MARK: Post Model

struct Post: Identifiable, Codable , Equatable, Hashable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date?
    var likedIDs: [String] = []
    var username: String
    var userUID: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likedIDs
        case username
        case userUID
        case userProfileURL
    }
}
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        text = try container.decode(String.self, forKey: .text)
//        imageReferenceID = try container.decode(String.self, forKey: .imageReferenceID)
//        likedIDs = try container.decode([String].self, forKey: .likedIDs)
//        username = try container.decode(String.self, forKey: .username)
//        userUID = try container.decode(String.self, forKey: .userUID)
//
//        // Convert String to URL
//        let imageURLString = try container.decode(String.self, forKey: .imageURL)
//        imageURL = URL(string: imageURLString)?.absoluteString
//
//        let userProfileURLString = try container.decode(String.self, forKey: .userProfileURL)
//        userProfileURL = URL(string: userProfileURLString)?.absoluteString ?? <#default value#>
//
//        // Convert String to Date
//        let dateString = try container.decode(String.self, forKey: .publishedDate)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        if let date = dateFormatter.date(from: dateString) {
//            publishedDate = dateFormatter.string(from: date)
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(text, forKey: .text)
//        try container.encode(imageReferenceID, forKey: .imageReferenceID)
//        try container.encode(likedIDs, forKey: .likedIDs)
//        try container.encode(username, forKey: .username)
//        try container.encode(userUID, forKey: .userUID)
//
//        // Convert URL to String
//        try container.encode(imageURL, forKey: .imageURL)
//        try container.encode(userProfileURL, forKey: .userProfileURL)
//
//        // Convert Date to String
//        try container.encode(publishedDate, forKey: .publishedDate)
//    }


