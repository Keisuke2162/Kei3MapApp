import Entity
import Extensions
import MapKit
import Services
import SwiftUI
import Repository
import FirebaseFirestore

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
  @Published var displayItems: [DisplayPostItem] = []
  @Published var isShowPostView: Bool = false

  let account: Account
  var postItems: [Post] = []

  public init(account: Account) {
    self.account = account
    position = .userLocation(fallback: .automatic)
  }
  
  // TODO: 別ファイルにcreate系まとめたい
  @MainActor
  func createPostViewModel() -> PostViewModel {
    return .init(
      account: account,
      location: position.region?.center ?? MapViewModel.initialCoordinate2D,
      onPosted: onPosted)
  }

  func onAppear() {
    locationManager.requestWhenInUseAuthorization()
//    if let location = locationManager.location?.coordinate {
//      position = .userLocation(fallback: .region(
//        .init(
//          center: location,
//          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        )
//      ))
//    }
    
    // 投稿一覧取得
    Task { @MainActor in
      let posts = await fetchPost()
      postItems = posts
      self.displayItems = posts.map {
        .init(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude), items: [$0])
      }
    }
  }
  
  // 投稿一覧取得
  // TODO: いずれ直近24時間以内とかにしたい
  private func fetchPost() async -> [Post] {
    do {
      let querySnapshot = try await Firestore.firestore()
        .collection("posts")
        .order(by: "createdAt", descending: true)
        .limit(to: 20)
        .getDocuments()
      let postData = querySnapshot.documents.compactMap { document in
        try? document.data(as: Post.self)
      }
      return postData
    } catch {
      // "Failed fetch timeline data \(error.localizedDescription)"
      return []
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
