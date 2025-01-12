import Extensions
import SwiftUI
import _AuthenticationServices_SwiftUI

public struct SigninView: View {
  @StateObject private var viewModel: SigninViewModel

  public init(viewModel: SigninViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    VStack {
      Spacer()
      RoundedRectangle(cornerRadius: 0)
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 160, height: 160)
        .overlay {
          Image("icon-app")
            .resizable()
            .scaledToFill()
        }
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .padding(.top, 16)
      Spacer()
      VStack(spacing: 8) {
        SignInWithAppleButton(.signIn) { request in
          viewModel.signInWithApple()
        } onCompletion: { _ in }
          .frame(width: 200, height: 44)
          .clipShape(.rect(cornerRadius: 8))
          .padding(.top, 16)
          .signInWithAppleButtonStyle(.white)
        
        // Googleログイン
        Button {
          viewModel.signInWithGoogle()
        } label: {
          Image("google_sign_in")
        }
        .frame(width: 200)
        .clipShape(.rect(cornerRadius: 8))
        .padding(.top, 32)
      }
      Spacer()
    }
  }
}

//#Preview {
//  SigninView()
//}
