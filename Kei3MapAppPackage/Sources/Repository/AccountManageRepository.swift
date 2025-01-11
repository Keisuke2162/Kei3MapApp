import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

protocol AccountManageRepositoryProtocol: AnyObject {
  func uploadProfileImage(image: UIImage) async throws -> URL
  func updateAccountData(name: String, imageURL: URL) async throws
}

public enum AccountError: Error {
  case convertJpegError
  case failedCreateAccount
  case failedGetCurrentAccount
}

public class AccountManageRepository: AccountManageRepositoryProtocol {
  func uploadProfileImage(image: UIImage) async throws -> URL {
    // Storageのパスを設定
    let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
    
    // 画像をデータに変換
    guard let imageData = image.jpegData(compressionQuality: 0.75) else {
      throw AccountError.convertJpegError
    }

    // 画像データをアップロード
    _ = try await storageRef.putDataAsync(imageData)
    // アップロードした画像のURLを取得
    let imageURL = try await storageRef.downloadURL()
    return imageURL
  }

  func updateAccountData(name: String, imageURL: URL) async throws {
    guard let currentUser = Auth.auth().currentUser else {
      throw AccountError.failedGetCurrentAccount
    }
    
    let data: [String: Any] = [
      "name": name,
      "thumbnailURL": imageURL.absoluteString
    ]
    // FireStoreのusersコレクション内にUIDでドキュメントを作る
    let db = Firestore.firestore()
    try await db.collection("users").document(currentUser.uid).setData(data)
  }
}
