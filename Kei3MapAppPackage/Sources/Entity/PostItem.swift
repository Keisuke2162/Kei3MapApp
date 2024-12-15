import Foundation
import MapKit

public struct Post: Identifiable {
  public let id = UUID()
  public let postText: String
  public let latitude: Double
  public let longitude: Double
  public let imageURL: URL = URL(string: "https://via.placeholder.com/150x150")!
  public let iconString: String

  public init(postText: String, latitude: Double, longitude: Double, iconString: String) {
    self.postText = postText
    self.latitude = latitude
    self.longitude = longitude
    self.iconString = iconString
  }

  public static let mockItems: [Post] = [
    .init(postText: "東京タワー", latitude: 35.6586, longitude: 139.7454, iconString: "🗼"),
    .init(postText: "富士山", latitude: 35.3606, longitude: 138.7274, iconString: "🗻"),
    .init(postText: "大阪城", latitude: 34.6873, longitude: 135.5259, iconString: "🏯"),
    .init(postText: "厳島神社", latitude: 34.2958, longitude: 132.3199, iconString: "⛩️"),
    .init(postText: "姫路城", latitude: 34.8394, longitude: 134.6939, iconString: "🏯"),
    .init(postText: "沖縄美ら海水族館", latitude: 26.6944, longitude: 127.8784, iconString: "🦈"),
    .init(postText: "札幌時計台", latitude: 43.0621, longitude: 141.3544, iconString: "🕰️"),
  ]

  public static let mockItemsKashiwa: [Post] = [
    .init(postText: "モラージュ柏", latitude: 35.8833642, longitude: 139.9671091, iconString: ""),
    .init(postText: "セブンイレブン", latitude: 35.8830425, longitude: 139.9673129, iconString: ""),
    .init(postText: "事務キチ", latitude: 35.8830425, longitude: 139.9673129, iconString: ""),
    .init(postText: "マナル", latitude: 35.8812692, longitude: 139.9673344, iconString: ""),
    .init(postText: "公園", latitude: 35.8812692, longitude: 139.9673344, iconString: ""),
    .init(postText: "路上", latitude: 35.8832077, longitude: 139.9701456, iconString: ""),
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
