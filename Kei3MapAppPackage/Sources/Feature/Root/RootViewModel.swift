import Entity
import FirebaseAuth
import FirebaseFirestore
import Repository

@MainActor
public class RootViewModel: ObservableObject {
  private let accountManageRepository: AccountManageRepositoryProtocol = AccountManageRepository()
  @Published var isShowCreateAccountView: Bool = false
  @Published var showPageType: PageType = .loading

  private let db = Firestore.firestore()

  public enum PageType {
    case loading
    case map(Account)
    case signin
  }

  public init() {
  }

  func onAppear() {
    signIn()
  }

  // サインイン完了後処理
  func onSignedin() {
    signIn()
  }
  
  // アカウント作成完了後処理
  func onCreatedAccount() {
    isShowCreateAccountView = false
    signIn()
  }
  
  func signIn() {
    Task {
      showPageType = .loading
      do {
        if let account = try await accountManageRepository.signin() {
          showPageType = .map(account)
        } else {
          // アカウントがなければサインイン（サインアップ）画面へ
          showPageType = .signin
        }
      } catch {
        // エラー処理
        isShowCreateAccountView = true
      }
    }
  }
}
