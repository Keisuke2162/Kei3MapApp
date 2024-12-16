import SwiftUI
import _PhotosUI_SwiftUI

@MainActor
public class SetAccountThumbnailViewModel: ObservableObject {
  let accountName: String
  let onCreated: () -> Void

  @Published var photoItem: PhotosPickerItem? {
    didSet {
      setProfileUIImage()
    }
  }
  @Published var profileImage: UIImage?
  @Published var isImagePickerPresented = false

  public init(accountName: String, onCreated: @escaping () -> Void) {
    self.accountName = accountName
    self.onCreated = onCreated
  }

  // UIImageに変換
  func setProfileUIImage() {
    Task {
      profileImage = await photoItem?.toUIImage()
    }
  }
}

public struct SetAccountThumbnailView: View {
  @StateObject private var viewModel: SetAccountThumbnailViewModel

  public init(viewModel: SetAccountThumbnailViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    ZStack {
      VStack(spacing: 32) {
        Spacer()
        Button {
          viewModel.isImagePickerPresented = true
        } label: {
          if let profileImage = viewModel.profileImage {
            Image(uiImage: profileImage)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 160, height: 160)
              .clipShape(Circle())
          } else {
            Color.indigo
              .frame(width: 160, height: 160)
              .clipShape(Circle())
          }
        }
        NavigationLink {
          let viewModel = ConfirmCreateAccountViewModel(accountName: viewModel.accountName, profileImage: viewModel.profileImage, onCreated: viewModel.onCreated)
          ConfirmCreateAccountView(viewModel: viewModel)
        } label: {
          Text("Next")
        }
        Spacer()
      }
      .padding()
      .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.photoItem)
    }
  }
}
