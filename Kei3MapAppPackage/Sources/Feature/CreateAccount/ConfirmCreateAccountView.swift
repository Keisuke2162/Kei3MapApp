import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

@MainActor
public class ConfirmCreateAccountViewModel: ObservableObject {
  let accountName: String
  let profileImage: UIImage?
  let onCreated: () -> Void

  @Published var isLoading: Bool = false
  @Published var isShowError: Bool = false

  // TODO: onCreatedのバケツリレーどうにかしたい
  public init(accountName: String, profileImage: UIImage?, onCreated: @escaping () -> Void) {
    self.accountName = accountName
    self.profileImage = profileImage
    self.onCreated = onCreated
  }

  // この辺はAccountManagerとかにまるっと移せるのでは？
  func createAccount() async {
    isShowError = false
    guard let profileImage else { return }
    isLoading = true
    guard let uploadImageURL = await uploadImageToStrorage(uiImage: profileImage) else {
      isLoading = false
      return
    }
    saveUserDataToFireStore(name: accountName, profileImageURLString: uploadImageURL)
    isLoading = false
  }
  
  // プロフィール画像のアップロード（アップロード後のURLを返す）
  private func uploadImageToStrorage(uiImage: UIImage) async -> String? {
    // Storageのパスを設定
    let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
    
    // 画像をデータに変換
    guard let imageData = uiImage.jpegData(compressionQuality: 0.75) else {
      // Failed to convert image to data
      isShowError = true
      return nil
    }

    do {
      // 画像データをアップロード
      _ = try await storageRef.putDataAsync(imageData)
      // アップロードした画像のURLを取得
      let imageURL = try await storageRef.downloadURL()
      return imageURL.absoluteString
    } catch {
      // "Failed to upload image or fetch URL: \(error.localizedDescription)"
      isShowError = true
      return nil
    }
  }

  // FireStoreにアカウントデータを保存する
  private func saveUserDataToFireStore(name: String, profileImageURLString: String) {
    guard let currentUser = Auth.auth().currentUser else {
      // "Failed to get currentUser"
      isShowError = true
      return
    }
  
    // FireStoreのusersコレクション内にUIDでドキュメントを作る
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(currentUser.uid)

    userRef.setData([
      "name": name,
      "thumbnailURL": profileImageURLString
    ]) { error in
      if error != nil {
        // "Error saving user data: \(error.localizedDescription)"
        self.isShowError = true
      } else {
        // アカウント登録完了
        self.onCreated()
      }
    }
  }
}

public struct ConfirmCreateAccountView: View {
  @StateObject private var viewModel: ConfirmCreateAccountViewModel

  public init(viewModel: ConfirmCreateAccountViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    ZStack {
      VStack(spacing: 32) {
        if let image = viewModel.profileImage {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 160, height: 160)
            .clipShape(Circle())
        }

        Text(viewModel.accountName)

        Button {
          Task {
            // アカウント作成
            await viewModel.createAccount()
          }
        } label: {
          Text("Create Account")
        }
        
        if viewModel.isShowError {
          Text("Failed Create Account")
        }
      }
      
      if viewModel.isLoading {
        Color.black.opacity(0.7)
        ProgressView()
      }
    }
  }
}
