import Extensions
import SwiftUI
import _PhotosUI_SwiftUI

import FirebaseAuth
import FirebaseFirestore

@MainActor
public class RootViewModel: ObservableObject {
//  @Published var isLoading: Bool = false
//  @Published var account: Account?
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

  func onAppear() async {
     await signin()
  }

  // サインイン完了後処理
  func onSignedin() {
    Task {
      await signin()
    }
  }
  
  // アカウント作成完了後処理
  func onCreatedAccount() {
    isShowCreateAccountView = false
    Task {
      await signin()
    }
  }

  // サインイン処理
  private func signin() async {
    showPageType = .loading
    guard let currentUser = Auth.auth().currentUser else {
      // アカウントがなければサインイン画面を表示
      showPageType = .signin
      return
    }
    
    print("テスト \(currentUser.uid)")
    // プロフィール取得
    let docRef = db.collection("users").document(currentUser.uid)
    do {
      let document = try await docRef.getDocument()
      guard let data = document.data() else {
        // アカウント情報が取得できなければアカウント作成画面を表示
        isShowCreateAccountView = true
        return
      }
      let userName = data["name"] as? String ?? ""
      let profileImageURL = URL(string: data["thumbnailURL"] as? String ?? "")

      let account = Account(userID: currentUser.uid, userName: userName, userProfileImageURL: profileImageURL)
      
      showPageType = .map(account)
    } catch {
      // アカウント情報が取得できなければアカウント作成画面を表示
      isShowCreateAccountView = true
    }
  }
}

public struct RootView: View {
  @StateObject private var viewModel: RootViewModel = RootViewModel()

  public init() {
  }

  public var body: some View {
    ZStack {
      switch viewModel.showPageType {
      case .loading:
        ProgressView()
      case .map(let account):
        let viewModel = MapViewModel(account: account)
        MapView(viewModel: viewModel)
      case .signin:
        SigninView(viewModel: SigninViewModel(onLoggedIn: viewModel.onSignedin))
      }
    }
    .task {
      await viewModel.onAppear()
    }
    .sheet(isPresented: $viewModel.isShowCreateAccountView) {
      NavigationStack {
        SetAccountNameView(onCreated: viewModel.onCreatedAccount)
      }
    }
  }
}

public struct Account: Codable {
  public var userID: String = ""
  public let userName: String
  public let userProfileImageURL: URL?

  public init(userID: String, userName: String, userProfileImageURL: URL?) {
    self.userID = userID
    self.userName = userName
    self.userProfileImageURL = userProfileImageURL
  }

  enum CodingKeys: String, CodingKey {
    case userName = "name"
    case userProfileImageURL = "thumbnailURL"
  }
}
