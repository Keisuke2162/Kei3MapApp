import Entity
import Extensions
import MapKit
import SwiftUI

public class MapViewModel: ObservableObject {
  @Published var cameraPosition: MapCameraPosition
  @Published var displayItems: [DisplayPostItem]
  let postItems: [Post] = Post.mockItems

  public init() {
    self.cameraPosition = .region(.init(
      center: CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529),
      span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    ))
    self.displayItems = postItems.map {
      .init(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude), items: [$0])
    }
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
  @StateObject var viewModel: MapViewModel =  MapViewModel()

  public init() {
  }

  public var body: some View {
    Map(position: $viewModel.cameraPosition) {
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
              ThumbnailAnnotationView(imageURL: item.imageURL)
            } else {
              Text("")
            }
          }
        }
      }
    }
    .mapStyle(.standard)
    .onMapCameraChange {
      viewModel.updateZoomLevel($0.camera.distance)
    }
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
}

//#Preview {
//  MapView()
//}
