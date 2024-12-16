import SwiftUI

@MainActor
public class ConfirmCreateAccountViewModel: ObservableObject {
  let accountName: String
  let profileImage: UIImage?

  public init(accountName: String, profileImage: UIImage?) {
    self.accountName = accountName
    self.profileImage = profileImage
  }

  // アカウント作成
  nonisolated func createAccount() async {
  }
}

public struct ConfirmCreateAccountView: View {
  @StateObject private var viewModel: ConfirmCreateAccountViewModel

  public init(viewModel: ConfirmCreateAccountViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
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
          await viewModel.createAccount()
          // アカウント作成完了
          // onCreatedAccount()
        }
      } label: {
        Text("Create Account")
      }
    }
  }
}
