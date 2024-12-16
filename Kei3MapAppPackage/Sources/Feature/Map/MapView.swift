import Entity
import Extensions
import MapKit
import SwiftUI

public class MapViewModel: ObservableObject {
  // 現在位置取得できない場合のデフォルトの位置情報
  static let initialCoordinate2D = CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529)
  let initialLocation: MapCameraPosition = .region(
    .init(
      center: initialCoordinate2D,
      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
  )
  private let locationManager: CLLocationManager = CLLocationManager()

  @Published var position: MapCameraPosition
  @Published var displayItems: [DisplayPostItem]
  @Published var isShowPostView: Bool = false

  let account: Account
  let postItems: [Post] = Post.mockItemsKashiwa

  public init(account: Account) {
    self.account = account
    position = .userLocation(fallback: initialLocation)
    self.displayItems = postItems.map {
      .init(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude), items: [$0])
    }
  }

  func onAppear() {
    locationManager.requestWhenInUseAuthorization()
    if let location = locationManager.location?.coordinate {
      position = .userLocation(fallback: .region(
        .init(
          center: location,
          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
      ))
    }
  }

  // 投稿するボタンタップ
  func onTapPostButton() {
    isShowPostView = true
  }

  // 投稿完了後
  func onPosted() {
    isShowPostView = false
    // TODO: 投稿完了のSnackBar出す？
  }

  // ズームの変更があった場合にデータを更新
  public func updateZoomLevel(_ distance: Double) {
    // TODO: 既存実装だとズームインアウトではなくマップの移動でもdistanceが変化して発火する→ズームインアウト時に変更したい
    let useDistance = distance * 0.1

    var newItems: [DisplayPostItem] = []

    // 投稿一覧
    for postItem in postItems {
      // newItemが空の場合は新規追加
      // TODO: クラスタリングした時にpostItemsの先頭の座標がクラスタリングの座標にせってされるので修正したい（中間地点？）
      if newItems.isEmpty {
        newItems.append(.init(coordinate: .init(latitude: postItem.latitude, longitude: postItem.longitude), items: [postItem]))
        continue
      }

      var isClusterd = false
      // newItemとの距離を測って近ければクラスタリングする
      for i in 0..<newItems.count {
        let postItemLocation = CLLocation(latitude: postItem.latitude, longitude: postItem.longitude)
        let newItemLocation = CLLocation(latitude: newItems[i].coordinate.latitude, longitude: newItems[i].coordinate.longitude)
        // 2点間の距離が一定以下の場合はクラスタリング
        if postItemLocation.distance(from: newItemLocation) <= useDistance {
          newItems[i].items.append(postItem)
          newItems[i].coordinate = midpointBetweenLocations(postItemLocation, newItemLocation)
          isClusterd = true
          break
        }
      }
      // クラスタリングしなければ単独ItemとしてnewItemsに追加
      if !isClusterd {
        newItems.append(.init(coordinate: .init(latitude: postItem.latitude, longitude: postItem.longitude), items: [postItem]))
      }
    }
    displayItems = newItems
  }
  
  // 2点の中間地点の座標を求める
  func midpointBetweenLocations(_ location1: CLLocation, _ location2: CLLocation) -> CLLocationCoordinate2D {
      let lat1 = location1.coordinate.latitude.radians
      let lon1 = location1.coordinate.longitude.radians
      let lat2 = location2.coordinate.latitude.radians
      let lon2 = location2.coordinate.longitude.radians

      let dLon = lon2 - lon1

      let bx = cos(lat2) * cos(dLon)
      let by = cos(lat2) * sin(dLon)

      let midLat = atan2(
          sin(lat1) + sin(lat2),
          sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by)
      )
      let midLon = lon1 + atan2(by, cos(lat1) + bx)

      return CLLocationCoordinate2D(latitude: midLat.degrees, longitude: midLon.degrees)
  }
}

public struct MapView: View {
  @StateObject var viewModel: MapViewModel

  public init(viewModel: MapViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      ZStack {
        Map(position: $viewModel.position) {
          ForEach(viewModel.displayItems, id: \.id) { post in
            if post.items.count > 1 {
              // クラスタリング用のViewを表示
              Annotation("", coordinate: post.coordinate) {
                ClusterAnnotationView(count: post.items.count)
              }
            } else {
              // サムネイルを表示
              Annotation("", coordinate: post.coordinate) {
                if let item = post.items.first {
                  NavigationLink {
                    PostDetailView(postItem: item)
                  } label: {
                    ThumbnailAnnotationView(imageURL: item.imageURL)
                  }
                  // EmojiAnnotationView(emoji: item.iconString)
                } else {
                  Text("")
                }
              }
            }
          }
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
        let location = viewModel.position.region?.center ?? MapViewModel.initialCoordinate2D
        let viewModel = PostViewModel(account: viewModel.account, location: location, onPosted: viewModel.onPosted)
        PostView(viewModel: viewModel)
      })
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
          AsyncImage(url: imageURL) { image in
              image.resizable()
                  .scaledToFill()
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                  .overlay(
                      Circle().stroke(Color.white, lineWidth: 2)
                          .shadow(radius: 4)
                  )
          } placeholder: {
              ProgressView()
          }
      }
  }
  
  //
  struct EmojiAnnotationView: View {
    let emoji: String

    var body: some View {
      ZStack {
        Circle()
          .fill(Color.white.opacity(0.8))
          .frame(width: 48, height: 48)
        Text(emoji)
              .foregroundColor(.white)
              .fontWeight(.bold)
      }
    }
  }
}

//#Preview {
//  MapView()
//}
