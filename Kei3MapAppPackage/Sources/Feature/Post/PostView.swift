import Extensions
import FirebaseStorage
import FirebaseFirestore
import SwiftUI
import _PhotosUI_SwiftUI

@MainActor
public class PostViewModel: ObservableObject {
  public let account: Account
  public let onPosted: () -> Void

  @Published var text: String = ""
  @Published var postPhotoItem: PhotosPickerItem? {
    didSet {
      setPostUIImage()
      processPhoto()
    }
  }
  @Published var postImage: UIImage?
  @Published var isImagePickerPresented = false
  @Published var errorMessage: String = ""
  @Published var isLoading: Bool = false
  @Published var isSuccessPost: Bool = false
  @Published var photoLocation: CLLocationCoordinate2D?
  @Published var addressString: String = "addressString"

  public init(account: Account, onPosted: @escaping () -> Void) {
    self.account = account
    self.onPosted = onPosted
  }

  // 写真をUIImageに変換
  func setPostUIImage() {
    Task {
      postImage = await postPhotoItem?.toUIImage()
    }
  }
  
  // 写真のDataを取得
  func processPhoto() {
    addressString = ""
    guard let postPhotoItem else { return }
    postPhotoItem.loadTransferable(type: Data.self) { result in
      switch result {
      case .success(let data):
        guard let data else { return }
        guard let location = self.extractLocation(data: data) else {
          return
        }
        Task { @MainActor in
          self.photoLocation = location
          self.addressString = await self.getAddress(coordinate: location)
        }
      case .failure:
        // 読み込みに失敗
        return
      }
    }
  }

  nonisolated private func extractLocation(data: Data) -> CLLocationCoordinate2D? {
    // CGImageSource作成
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    // メタデータ取得
    guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else { return nil }
    // GPS情報を取得
    guard let gpsData = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any],
          let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
          let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef] as? String,
          let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
          let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef] as? String else {
      return nil
    }
    // 経度、緯度
    let photoLatitude = latitudeRef == "S" ? -latitude : latitude
    let photoLongitude = longitudeRef == "W" ? -longitude : longitude
    return CLLocationCoordinate2D(latitude: photoLatitude, longitude: photoLongitude)
  }

  nonisolated private func getAddress(coordinate: CLLocationCoordinate2D) async -> String {
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

    do {
      let placemarks = try await geoCoder.reverseGeocodeLocation(location)
      if let placemark = placemarks.first {
        // ざっくり住所を作成
        let country = placemark.country ?? ""
        let administrativeArea = placemark.administrativeArea ?? ""
        let locality = placemark.locality ?? ""
        return "\(country) \(administrativeArea) \(locality)"
      } else {
        return "getPlacemarkError"
      }
    } catch {
      return "reverseGeocodeLocationError"
    }
  }

  // 投稿処理
  func post() async {
    guard let postImage else { return }
    isLoading = true
    guard let uploadImageURL = await uploadImageToStrorage(uiImage: postImage) else { return }
    saveUserDataToFireStore(imageURLString: uploadImageURL)
    isLoading = false
    onPosted()
  }
  
  // 投稿画像をStorageにアップ（アップロード後のURLを返す）
  private func uploadImageToStrorage(uiImage: UIImage) async -> String? {
    let storageRef = Storage.storage().reference().child("post_images/\(UUID().uuidString).jpg")

    guard let imageData = uiImage.jpegData(compressionQuality: 0.75) else {
      errorMessage = "Failed to convert image to data"
      return nil
    }

    do {
      _ = try await storageRef.putDataAsync(imageData)
      let imageURL = try await storageRef.downloadURL()
      return imageURL.absoluteString
    } catch {
      errorMessage = "Failed to upload image or fetch URL: \(error.localizedDescription)"
      return nil
    }
  }
  
  // 投稿データをFirestoreにアップ
  private func saveUserDataToFireStore(imageURLString: String) {
    let data: [String: Any] = [
      "userID": account.userID,
      "postText": text,
      "postImageURL": imageURLString,
      "createdAt": Date()
    ]
    // FireStoreのusersコレクション内にUIDでドキュメントを作る
    let db = Firestore.firestore()
    db.collection("posts").document(UUID().uuidString).setData(data) { error in
      if let error {
        self.errorMessage = "Failed post: \(error.localizedDescription)"
      } else {
        self.isSuccessPost = true
      }
    }
  }
}

public struct PostView: View {
  @StateObject private var viewModel: PostViewModel
  @Environment(\.dismiss) var dismiss

  public init(viewModel: PostViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    ZStack {
      VStack {
        HStack {
          Button {
            // TODO: onCanceledに変更
            dismiss()
          } label: {
            Text("Cancel")
          }
          Spacer()
          Button {
            Task {
              await viewModel.post()
            }
          } label: {
            Text("Post")
          }
        }
        .padding(.horizontal, 16)
  
        if let postImage = viewModel.postImage {
          RoundedRectangle(cornerRadius: 0)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              Image(uiImage: postImage)
                .resizable()
                .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(.top, 16)
        } else {
          RoundedRectangle(cornerRadius: 0)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              Button {
                viewModel.isImagePickerPresented = true
              } label: {
                Image(systemName: "camera")
              }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(.top, 16)
            .background(Color.clear)
        }
        // 写真を変更ボタン
        HStack {
          Spacer()
          Button {
            viewModel.isImagePickerPresented = true
          } label: {
            Image(systemName: "camera.fill")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 24, height: 24)
              .padding(8)
          }
          .padding(.trailing, 16)
        }
        .frame(height: 56)
        
        Text(viewModel.addressString)
        
        TextEditor(text: $viewModel.text)
          .padding(.horizontal, 16)
      }
      .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.postPhotoItem)

      if viewModel.isLoading {
        ProgressView()
          .ignoresSafeArea()
      }
      
      if viewModel.isSuccessPost {
        Color.blue.opacity(0.3)
          .background(ignoresSafeAreaEdges: .bottom)
        Text("Success Post!")
          .font(.title)
          .padding()
          .background(Color.blue)
          .foregroundStyle(Color.white)
      }

      if !viewModel.errorMessage.isEmpty {
        Color.red.opacity(0.3)
          .background(ignoresSafeAreaEdges: .bottom)
        Text(viewModel.errorMessage)
          .font(.title)
          .padding()
          .background(Color.red)
          .foregroundStyle(Color.white)
      }
    }
  }
}
