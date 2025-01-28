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
    ZStack {
      MapReader { reader in
        Map(position: $viewModel.position, interactionModes: .all) {
          // 投稿を表示
          ForEach(viewModel.displayItems) { post in
            // クラスタリング
            if post.items.count > 1 {
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

          // 経路を表示
          if let route = viewModel.route {
            MapPolyline(route)
              .stroke(.indigo, lineWidth: 10)
          }

          UserAnnotation()
        }
        .animation(.smooth, value: viewModel.position)
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
        .onTapGesture(perform: { screenCoord in
          if let coordinate = reader.convert(screenCoord, from: .local) {
            // タップした箇所の説明を取得
            viewModel.onTapMap(coordinate: coordinate)
          }
        })
      }
      .ignoresSafeArea()
      
//      if viewModel.isShowMenuView {
//        Color.black.opacity(0.5)
//          .ignoresSafeArea()
//          .transition(.opacity)
//      }
      
      // Menu
      Color.black
        .opacity(viewModel.isShowMenuView ? 0.5 : 0)
        .ignoresSafeArea()
        .transition(.opacity)
      VStack(alignment: .center) {
        Spacer()
        
        if viewModel.isShowMenuView {
          MapMenuView { menuType in
            viewModel.onSelectedMenu(type: menuType)
          }
          .transition(.opacity)
        }

        Button {
          withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.isShowMenuView.toggle()
          }
        } label: {
          Image(systemName: viewModel.isShowMenuView ? "xmark" : "filemenu.and.cursorarrow")
        }
        .frame(width: 56, height: 56)
        .background(Color.white)
        .clipShape(Circle())
        .padding(16)
      }
    }
//    .fullScreenCover(isPresented: $viewModel.isShowMenuView, content: {
//      MapMenuView(onSelectItem: viewModel.onSelectedMenu(type:))
//    })
    .fullScreenCover(isPresented: $viewModel.isShowPostView, content: {
      let viewModel = viewModel.createPostViewModel()
      PostView(viewModel: viewModel)
    })
    .sheet(item: $viewModel.selectedItem) { item in
      MapItemInformationSheet(postImageURL: item.postImageURL, address: item.addressString, description: item.postText, onTapSearchRoute: viewModel.searchRoute)
        .presentationDetents(
          [.height(200)]
        )
    }
    .sheet(isPresented: $viewModel.showMapItemSheet, content: {
      if let item = viewModel.selectedMapItem {
        MapItemInformationSheet(address: item.name ?? "", description: "", onTapSearchRoute: viewModel.searchRoute)
          .presentationDetents(
            [.height(200)]
          )
      }
    })
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
