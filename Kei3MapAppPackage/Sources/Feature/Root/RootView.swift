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

