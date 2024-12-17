import Foundation
import MapKit

public struct Post: Codable, Identifiable {
  public var id = UUID()

  public let userID: String
  public let postText: String
  public let latitude: Double
  public let longitude: Double
  public let postImageURL: URL
  public let addressString: String
  public let createdAt: Date
  
  enum CodingKeys: String, CodingKey {
    case userID, postText, postImageURL, latitude, longitude, addressString, createdAt
  }

  public init(postText: String, latitude: Double, longitude: Double, postImageURL: URL, addressString: String) {
    self.userID = ""
    self.postText = postText
    self.latitude = latitude
    self.longitude = longitude
    self.postImageURL = postImageURL
    self.addressString = addressString
    self.createdAt = Date()
  }
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

// MARK: Mock
extension Post {
  public static let mockURL = URL(string: "https://via.placeholder.com/150x150")!
  public static let mockItems: [Post] = [
    .init(postText: "東京タワー", latitude: 35.6586, longitude: 139.7454, postImageURL: mockURL, addressString: ""),
    .init(postText: "富士山", latitude: 35.3606, longitude: 138.7274, postImageURL: mockURL, addressString: ""),
    .init(postText: "大阪城", latitude: 34.6873, longitude: 135.5259, postImageURL: mockURL, addressString: ""),
    .init(postText: "厳島神社", latitude: 34.2958, longitude: 132.3199, postImageURL: mockURL, addressString: ""),
    .init(postText: "姫路城", latitude: 34.8394, longitude: 134.6939, postImageURL: mockURL, addressString: ""),
    .init(postText: "沖縄美ら海水族館", latitude: 26.6944, longitude: 127.8784, postImageURL: mockURL, addressString: ""),
    .init(postText: "札幌時計台", latitude: 43.0621, longitude: 141.3544, postImageURL: mockURL, addressString: ""),
  ]

  public static let mockItemsKashiwa: [Post] = [
    .init(postText: "モラージュ柏", latitude: 35.8833642, longitude: 139.9671091, postImageURL: mockURL, addressString: "日本　千葉県　柏市"),
    .init(postText: "セブンイレブン", latitude: 35.8830425, longitude: 139.9673129, postImageURL: mockURL, addressString: "日本　千葉県　柏市"),
    .init(postText: "事務キチ", latitude: 35.8830425, longitude: 139.9673129, postImageURL: mockURL, addressString: "日本　千葉県　柏市"),
    .init(postText: "マナル", latitude: 35.8812692, longitude: 139.9673344, postImageURL: mockURL, addressString: "日本　千葉県　柏市"),
    .init(postText: "公園", latitude: 35.8812692, longitude: 139.9673344, postImageURL: mockURL, addressString: "日本　千葉県　柏市"),
    .init(postText: "路上", latitude: 35.8832077, longitude: 139.9701456, postImageURL: mockURL, addressString: "日本　千葉県　柏市"),
  ]
}
