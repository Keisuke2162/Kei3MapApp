import SwiftUI
import Entity
import Kingfisher
import _MapKit_SwiftUI

public struct MapView: View {
  @StateObject var viewModel: MapViewModel

  public init(viewModel: MapViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      ZStack {
        Map(position: $viewModel.position, interactionModes: .all) {
          ForEach(viewModel.displayItems) { post in
            if post.items.count > 1 {
              // クラスタリング用のViewを表示
              Annotation("", coordinate: post.coordinate) {
                ClusterAnnotationView(count: post.items.count)
              }
            } else {
              // サムネイルを表示
              Annotation("", coordinate: post.coordinate) {
                if let item = post.items.first {
                  Button {
                    viewModel.selectedItem = item
                  } label: {
                    ThumbnailAnnotationView(imageURL: item.postImageURL)
                  }
                } else {
                  Text("")
                }
              }
            }
          }
          
          if let route = viewModel.route {
            MapPolyline(route)
              .stroke(.indigo, lineWidth: 10)
          }

          UserAnnotation()
        }
        .mapStyle(.standard)
        .onMapCameraChange {
          // 再描画走るので一旦コメントアウト
          // viewModel.updateZoomLevel($0.camera.distance)
        }
        .mapControls {
          MapUserLocationButton()
        }
        .onAppear {
          viewModel.onAppear()
        }
        HStack {
          Spacer()
          VStack {
            Spacer()
            Button {
              viewModel.onTapPostButton()
            } label: {
              Image(systemName: "pencil.and.scribble")
            }
            .frame(width: 56, height: 56)
            .background(Color.white)
            .clipShape(Circle())
            .padding(16)
          }
        }
      }
      .fullScreenCover(isPresented: $viewModel.isShowPostView, content: {
        let viewModel = viewModel.createPostViewModel()
        PostView(viewModel: viewModel)
      })
      .sheet(item: $viewModel.selectedItem) { item in
        PostDetailView(postItem: item, onTapSearchRoute: viewModel.searchRoute)
          .presentationDetents(
            [.height(200)]
          )
      }
    }
    .ignoresSafeArea()
    .toolbar(.hidden, for: .navigationBar)
  }
  
  
  // クラスタリング用のAnnotationView
  struct ClusterAnnotationView: View {
      let count: Int
      var body: some View {
          ZStack {
              Circle()
                  .fill(Color.blue.opacity(0.7))
                  .frame(width: 30, height: 30)
              Text("\(count)")
                  .foregroundColor(.white)
                  .fontWeight(.bold)
          }
      }
  }
  
  // サムネイル表示用のAnnotationView
  struct ThumbnailAnnotationView: View {
      let imageURL: URL
      var body: some View {
        KFImage(imageURL)
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.white, lineWidth: 2)
                    .shadow(radius: 4)
            )
      }
  }
}
