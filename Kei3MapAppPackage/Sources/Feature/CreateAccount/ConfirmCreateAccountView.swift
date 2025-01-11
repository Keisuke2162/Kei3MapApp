import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Repository

@MainActor
public class ConfirmCreateAccountViewModel: ObservableObject {
  let accountManageRepository: AccountManageRepositoryProtocol
  let accountName: String
  let profileImage: UIImage?
  let onCreated: () -> Void

  @Published var isLoading: Bool = false
  @Published var isShowError: Bool = false

  // TODO: onCreatedのバケツリレーどうにかしたい
  public init(
    accountName: String,
    profileImage: UIImage?,
    accountManageRepository: AccountManageRepositoryProtocol,
    onCreated: @escaping () -> Void) {
      self.accountName = accountName
      self.profileImage = profileImage
      self.accountManageRepository = accountManageRepository
      self.onCreated = onCreated
  }

  // この辺はAccountManagerとかにまるっと移せるのでは？
  func createAccount() async {
    isShowError = false
    guard let profileImage else { return }
    isLoading = true
    do {
      let url = try await accountManageRepository.uploadProfileImage(image: profileImage)
      try await accountManageRepository.updateAccountData(name: accountName, imageURL: url)
      isLoading = false
      self.onCreated()
    } catch {
      isLoading = false
      isShowError = true
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
