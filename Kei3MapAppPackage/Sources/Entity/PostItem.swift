import Foundation
import MapKit

public struct Post: Identifiable {
  public let id = UUID()
  public let title: String
  public let latitude: Double
  public let longitude: Double
  public let imageURL: URL = URL(string: "https://via.placeholder.com/150x150")!

  public init(title: String, latitude: Double, longitude: Double) {
    self.title = title
    self.latitude = latitude
    self.longitude = longitude
  }

  public static let mockItems: [Post] = [
    .init(title: "東京タワー", latitude: 35.6586, longitude: 139.7454),
    .init(title: "富士山", latitude: 35.3606, longitude: 138.7274),
    .init(title: "金閣寺", latitude: 35.0394, longitude: 135.7292),
    .init(title: "大阪城", latitude: 34.6873, longitude: 135.5259),
    .init(title: "厳島神社", latitude: 34.2958, longitude: 132.3199),
    .init(title: "姫路城", latitude: 34.8394, longitude: 134.6939),
    .init(title: "沖縄美ら海水族館", latitude: 26.6944, longitude: 127.8784),
    .init(title: "白川郷", latitude: 36.2590, longitude: 136.8987),
    .init(title: "上高地", latitude: 36.2426, longitude: 137.6414),
    .init(title: "札幌時計台", latitude: 43.0621, longitude: 141.3544),
  ]
}

public struct DisplayPostItem: Identifiable {
  public let id = UUID()
  public var coordinate: CLLocationCoordinate2D
  public var items: [Post]

  public init(coordinate: CLLocationCoordinate2D, items: [Post]) {
    self.coordinate = coordinate
    self.items = items
  }
}
