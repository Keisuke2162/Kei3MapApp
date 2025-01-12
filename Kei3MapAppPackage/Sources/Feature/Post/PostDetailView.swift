import Entity
import SwiftUI
import Kingfisher

public struct PostDetailView: View {
  let postItem: Post

  public init(postItem: Post) {
    self.postItem = postItem
  }

  public var body: some View {
    VStack {
      RoundedRectangle(cornerRadius: 0)
        .aspectRatio(1, contentMode: .fit)
        .overlay {
          KFImage(postItem.postImageURL)
            .resizable()
            .scaledToFill()
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.top, 16)
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
}
