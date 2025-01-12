import _PhotosUI_SwiftUI

public protocol PhotoProcessingServiceProtocol: AnyObject {
  func extractLocation(data: Data) -> CLLocationCoordinate2D?
}

public class PhotoProcessingService: PhotoProcessingServiceProtocol {
  public init() {
  }

  public func extractLocation(data: Data) -> CLLocationCoordinate2D? {
    // Make CGImageSource
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    // Get Metadata
    guard let meta = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else { return nil }
    // Get GPS Data
    guard let gpsData = meta[kCGImagePropertyGPSDictionary] as? [CFString: Any],
          let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
          let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef] as? String,
          let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
          let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef] as? String else { return nil }
    let photoLatitude = latitudeRef == "S" ? -latitude : latitude     // 北緯・南緯判定
    let photoLongitude = longitudeRef == "W" ? -longitude : longitude // 東経・西経判定
    return CLLocationCoordinate2D(latitude: photoLatitude, longitude: photoLongitude)
  }
}
