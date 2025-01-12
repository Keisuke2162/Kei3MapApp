import Entity
import Services
import Extensions
import FirebaseStorage
import FirebaseFirestore
import Repository
import _PhotosUI_SwiftUI

@MainActor
public class PostViewModel: ObservableObject {
  // Environmentでいい感じにできるかも
  private let photoProcessingService: PhotoProcessingServiceProtocol = PhotoProcessingService()
  private let locationService: LocationServiceProtocol = LocationService()
  private let postRepository: PostRepositoryProtocol = PostRepository()

  private let account: Account
  private let onPosted: () -> Void
  private let location: CLLocationCoordinate2D

  @Published var text: String = ""
  @Published var postPhotoItem: PhotosPickerItem?
  @Published var postImage: UIImage?
  @Published var isImagePickerPresented = false
  @Published var errorMessage: String = ""
  @Published var isLoading: Bool = false
  @Published var isSuccessPost: Bool = false
  @Published var photoLocation: CLLocationCoordinate2D?
  @Published var addressString: String = "addressString"

  public init(
    account: Account,
    location: CLLocationCoordinate2D,
    onPosted: @escaping () -> Void) {
      self.account = account
      self.location = location
      self.onPosted = onPosted
  }

  func onChangePhotoItem() {
    guard let item = postPhotoItem else { return }
    // 写真をUIImageに変換
    Task {
      postImage = await item.toUIImage()
    }
    // Exif
    item.loadTransferable(type: Data.self) { result in
      switch result {
      case .success(let data):
        guard let data else { return }
        Task.detached { // バックグラウンド実行
          guard let location = await self.photoProcessingService.extractLocation(data: data) else { return }
          let address = await self.locationService.getAddressString(coordinate: location)
          // メインスレッド
          await MainActor.run {
            self.photoLocation = location
            self.addressString = address
          }
        }
      case .failure:
        // failed loadTransferable
        return
      }
    }
  }

  func onTapPostButton() {
    guard let postImage else { return }
    isLoading = true
    Task {
      do {
        let url = try await postRepository.postImage(image: postImage)
        try await postRepository.post(account: account, title: text, imageURL: url, photoLocation: photoLocation ?? location, addressText: addressString)
        isLoading = false
        onPosted()
      } catch {
        // エラー処理
      }
    }
  }
}
