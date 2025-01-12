import Foundation

public struct Account: Codable {
  public var userID: String = ""
  public let userName: String
  public let userProfileImageURL: URL?

  public init(userID: String, userName: String, userProfileImageURL: URL?) {
    self.userID = userID
    self.userName = userName
    self.userProfileImageURL = userProfileImageURL
  }

  enum CodingKeys: String, CodingKey {
    case userName = "name"
    case userProfileImageURL = "thumbnailURL"
  }
}
