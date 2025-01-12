import SwiftUI

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
