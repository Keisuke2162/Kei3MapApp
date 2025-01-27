import Entity
import Extensions
import SwiftUI
import _PhotosUI_SwiftUI

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
        SelectMapView(account: account)
      case .signin:
        SigninView(viewModel: SigninViewModel(onLoggedIn: viewModel.onSignedin))
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
    .sheet(isPresented: $viewModel.isShowCreateAccountView) {
      NavigationStack {
        SetAccountNameView(onCreated: viewModel.onCreatedAccount)
      }
    }
  }
}

