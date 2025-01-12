import CoreLocation

public protocol LocationServiceProtocol: AnyObject {
  func getAddressString(coordinate: CLLocationCoordinate2D) async -> String
}

public class LocationService: LocationServiceProtocol {
  public init() {
  }

  public func getAddressString(coordinate: CLLocationCoordinate2D) async -> String {
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

    do {
      let placemarks = try await geoCoder.reverseGeocodeLocation(location)
      if let placemark = placemarks.first {
        let country = placemark.country ?? ""
        let administrativeArea = placemark.administrativeArea ?? ""
        let locality = placemark.locality ?? ""
        return "\(country) \(administrativeArea) \(locality)"
      } else {
        return "-"
      }
    } catch {
      return "-"
    }
  }
}
