import SwiftUI

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
