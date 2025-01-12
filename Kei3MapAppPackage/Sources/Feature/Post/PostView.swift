import Entity
import Services
import Extensions
import FirebaseStorage
import FirebaseFirestore
import Repository
import SwiftUI
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
            viewModel.onTapPostButton()
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
      .onChange(of: viewModel.postPhotoItem) { oldValue, newValue in
        viewModel.onChangePhotoItem()
      }

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
