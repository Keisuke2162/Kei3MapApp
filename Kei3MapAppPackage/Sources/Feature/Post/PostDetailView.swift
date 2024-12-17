import Entity
import SwiftUI
import Kingfisher

@MainActor
public class PostDetailViewModel: ObservableObject {
  let postItem: Post

  public init(postItem: Post) {
    self.postItem = postItem
  }
}

public struct PostDetailView: View {
  @StateObject private var viewModel: PostDetailViewModel

  public init(postItem: Post) {
    _viewModel = StateObject(wrappedValue: PostDetailViewModel(postItem: postItem))
  }

  public var body: some View {
    VStack {
      RoundedRectangle(cornerRadius: 0)
        .aspectRatio(1, contentMode: .fit)
        .overlay {
          KFImage(viewModel.postItem.postImageURL)
            .resizable()
            .scaledToFill()
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.top, 16)
      Text(viewModel.postItem.addressString)
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
      Text(viewModel.postItem.postText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 16)
      Spacer()
    }
  }
}
