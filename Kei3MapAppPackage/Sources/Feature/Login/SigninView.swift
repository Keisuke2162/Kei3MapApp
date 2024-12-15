import Extensions
import SwiftUI

@MainActor
public class SigninViewModel: ObservableObject {
  public init() {
  }
}

public struct SigninView: View {
  public init() {
  }
  public var body: some View {
    ZStack {
      Image("kei3mappapp_top", bundle: Bundle.main)
    }
    .ignoresSafeArea()
  }
}

//#Preview {
//  SigninView()
//}
