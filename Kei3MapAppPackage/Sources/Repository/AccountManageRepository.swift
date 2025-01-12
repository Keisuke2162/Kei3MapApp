import Entity
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

// これServiceでは...?
public protocol AccountManageRepositoryProtocol: AnyObject {
  func uploadProfileImage(image: UIImage) async throws -> URL
  func updateAccountData(name: String, imageURL: URL) async throws
  func signin() async throws -> Account?
}

public enum AccountError: Error {
  case convertJpegError
  case failedCreateAccount
  case failedGetCurrentAccount
  case failedGetAccountData
}

public class AccountManageRepository: AccountManageRepositoryProtocol {
  public init() {
  }

  public func uploadProfileImage(image: UIImage) async throws -> URL {
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

  public func updateAccountData(name: String, imageURL: URL) async throws {
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

  public func signin() async throws -> Account? {
    guard let currentUser = Auth.auth().currentUser else { return nil } //ユーザーがないのでサインイン画面へ
    let db = Firestore.firestore()
    // プロフィール取得
    let docRef = db.collection("users").document(currentUser.uid)
    let document = try await docRef.getDocument() // ユーザーはあるのでアカウント登録画面へ
    guard let data = document.data() else { throw AccountError.failedGetAccountData } //アカウントデータがFireStoreにないのでアカウント登録画面へ
    let userName = data["name"] as? String ?? ""
    let profileImageURL = URL(string: data["thumbnailURL"] as? String ?? "")

    return Account(userID: currentUser.uid, userName: userName, userProfileImageURL: profileImageURL)
  }
}
