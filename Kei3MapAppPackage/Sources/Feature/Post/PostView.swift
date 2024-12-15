import Extensions
import SwiftUI
import _PhotosUI_SwiftUI

@MainActor
public class PostViewModel: ObservableObject {
//  let user: SNSUser
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

  public init() {
  }

  // 写真をUIImageに変換
  func setPostUIImage() {
    Task {
      postImage = await postPhotoItem?.toUIImage()
    }
  }
  
  // 写真のDataを取得
  func processPhoto() {
    guard let postPhotoItem else { return }
    postPhotoItem.loadTransferable(type: Data.self) { result in
      switch result {
      case .success(let data):
        guard let data else { return }
        
      case .failure(let failure):
        // 読み込みに失敗
        return
      }
    }
  }

  func extractLocation(data: Data) {
    // CGImageSource作成
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
    // メタデータ取得
    guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else { return }
    // GPS情報を取得
    guard let gpsData = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any],
          let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
          let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef] as? String,
          let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
          let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef] as? String else {
      photoLocation = nil
      return
    }
    // 経度、緯度
    let photoLatitude = latitudeRef == "S" ? -latitude : latitude
    let photoLongitude = longitudeRef == "W" ? -longitude : longitude
    photoLocation = CLLocationCoordinate2D(latitude: photoLatitude, longitude: photoLongitude)
  }
}

public struct PostView: View {
  @StateObject private var viewModel: PostViewModel = PostViewModel()
  public let onPosted: () -> Void

  public init(onPosted: @escaping () -> Void) {
    self.onPosted = onPosted
  }

  public var body: some View {
    ZStack {
      VStack {
        HStack {
          Button {
            // TODO: onCanceledに変更
            onPosted()
          } label: {
            Text("Cancel")
          }
          Spacer()
          Button {
            // TODO: 投稿処理呼ぶ
            onPosted()
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
