import Entity
import Extensions
import FirebaseStorage
import FirebaseFirestore
import Foundation
import UIKit
import _PhotosUI_SwiftUI


protocol PostRepositoryProtocol: AnyObject {
  func postImage(image: UIImage) async throws -> URL
  func post(account: Account, title: String, imageURL: URL, photoLocation: CLLocationCoordinate2D, addressText: String) async throws
}

public enum PostError: Error {
  case convertJpegError
  case failedPost
}

public class PostRepository: PostRepositoryProtocol {
  func postImage(image: UIImage) async throws -> URL {
    let storageRef = Storage.storage().reference().child("post_images/\(UUID().uuidString).jpg")

    guard let imageData = image.jpegData(compressionQuality: 0.75) else {
      throw PostError.convertJpegError
    }

    _ = try await storageRef.putDataAsync(imageData)
    let imageURL = try await storageRef.downloadURL()
    return imageURL
  }

  func post(account: Account, title: String, imageURL: URL, photoLocation: CLLocationCoordinate2D, addressText: String) async throws {
    let data: [String: Any] = [
      "userID": account.userID,
      "postText": title,
      "postImageURL": imageURL.absoluteString,
      "latitude": photoLocation.latitude,
      "longitude": photoLocation.longitude,
      "addressString": addressText,
      "createdAt": Date()
    ]
    // FireStoreのusersコレクション内にUIDでドキュメントを作る
    let db = Firestore.firestore()
    try await db.collection("posts").document(UUID().uuidString).setData(data)
  }
}
