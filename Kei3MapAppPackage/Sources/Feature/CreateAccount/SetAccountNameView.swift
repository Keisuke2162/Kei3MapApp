import SwiftUI

public struct SetAccountNameView: View {
  @State private var accountName: String = ""

  public init() {
  }

  public var body: some View {
    VStack(spacing: 32) {
      Text("Setting Account Name")
      TextField("", text: $accountName)
        .frame(height: 56)
        .padding(.horizontal, 32)
        .font(.title2.bold())
        .textFieldStyle(RoundedBorderTextFieldStyle())
      
      NavigationLink {
        let viewModel = SetAccountThumbnailViewModel(accountName: accountName)
        SetAccountThumbnailView(viewModel: viewModel)
      } label: {
        Text("Next")
      }
    }
  }
}
