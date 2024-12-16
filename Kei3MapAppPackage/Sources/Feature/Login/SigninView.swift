import Extensions
import SwiftUI
import _AuthenticationServices_SwiftUI

// viewmodel
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import CryptoKit

@MainActor
public class SigninViewModel: NSObject, ObservableObject {
  @Published var errorMessage = ""
  private var currentNonce: String?
  public let onLoggedIn: () -> Void
  
  public override init() {
    self.onLoggedIn = {}
  }
  
  public init(onLoggedIn: @escaping () -> Void) {
    self.onLoggedIn = onLoggedIn
    super.init()
  }
  
  func signInWithGoogle() {
    guard let rootViewController = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else {
      errorMessage = "RootViewController is not found"
      return
    }
    
    guard let clientID = FirebaseApp.app()?.options.clientID else {
      errorMessage = "Not found clientID"
      return
    }
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
      if let error {
        self.errorMessage = error.localizedDescription
        return
      }
      
      guard let user = result?.user,
            let idToken = user.idToken?.tokenString else {
        self.errorMessage = "Google sign-in failed"
        return
      }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
      
      // ユーザー作成orサインイン
      Auth.auth().signIn(with: credential) { authResult, error in
        if let error {
          self.errorMessage = "Firebase authentication failed: \(error.localizedDescription)"
        } else {
          self.onLoggedIn()
        }
      }
    }
  }
  
  func signInWithApple() {
    let nonce = randomNonceString()
    currentNonce = nonce
    
    let appleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
    appleIDRequest.requestedScopes = [.fullName, .email]
    appleIDRequest.nonce = sha256(nonce)
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDRequest])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }
}

extension SigninViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }

  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        errorMessage = "Invalid state: Nonce not set"
        return
      }
      
      guard let appleIDToken = appleIDCredential.identityToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        errorMessage = "Unable to fetch identity token"
        return
      }
      
      let credential = OAuthProvider.credential(
        providerID: AuthProviderID.apple,
        idToken: idTokenString,
        rawNonce: nonce
      )
      
      Auth.auth().signIn(with: credential) { [weak self] result, error in
        if let error {
          self?.errorMessage = error.localizedDescription
        } else {
          self?.onLoggedIn()
        }
      }
    }
  }
  
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
    errorMessage = error.localizedDescription
  }

  // Nonceの生成、ハッシュ化
  private func randomNonceString(length: Int = 32) -> String {
    let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms: [UInt8] = (0..<16).map { _ in numericCast(arc4random_uniform(UInt32(charset.count))) }
      randoms.forEach { random in
        if remainingLength > 0 {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }
  
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hasheData = SHA256.hash(data: inputData)
    return hasheData.compactMap { String(format: "%02x", $0) }.joined()
  }
}


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
