import Entity
import SwiftUI
import Kingfisher

public struct PostDetailView: View {
  let postItem: Post
  let onTapSearchRoute: () -> Void
  let gradientView: LinearGradient = .init(gradient: Gradient(colors: [.red, .green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
  @Environment(\.dismiss) var dismiss

  public init(postItem: Post, onTapSearchRoute: @escaping () -> Void) {
    self.postItem = postItem
    self.onTapSearchRoute = onTapSearchRoute
  }

  public var body: some View {
    VStack {
      Spacer()
      HStack(spacing: 8) {
        RoundedRectangle(cornerRadius: 0)
          .aspectRatio(1, contentMode: .fit)
          .overlay {
            KFImage(postItem.postImageURL)
              .resizable()
              .scaledToFill()
          }
          .frame(width: 80)
          .clipShape(RoundedRectangle(cornerRadius: 4))
        VStack(spacing: 4) {
          Spacer()
          Text(postItem.addressString)
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
          Text(postItem.postText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
          Spacer()
        }
      }
      .padding(.leading, 16)
      
      Button {
        onTapSearchRoute()
        dismiss()
      } label: {
        Text("経路案内🚶")
          .font(.title3.bold())
          .tint(Color.black)
          .padding(.horizontal, 32)
          .padding(.vertical, 8)
          .background(gradientView)
      }
      .clipShape(.rect(cornerRadius: 16))
    }
    Spacer()
  }
}
