import Repository
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
