import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Repository

@MainActor
public class ConfirmCreateAccountViewModel: ObservableObject {
  let accountManageRepository: AccountManageRepositoryProtocol = AccountManageRepository()
  let accountName: String
  let profileImage: UIImage?
  let onCreated: () -> Void

  @Published var isLoading: Bool = false
  @Published var isShowError: Bool = false

  // TODO: onCreatedのバケツリレーどうにかしたい
  public init(
    accountName: String,
    profileImage: UIImage?,
    onCreated: @escaping () -> Void) {
      self.accountName = accountName
      self.profileImage = profileImage
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
