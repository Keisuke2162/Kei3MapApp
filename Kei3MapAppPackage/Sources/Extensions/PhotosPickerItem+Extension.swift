import Foundation
import SwiftUI
import _PhotosUI_SwiftUI

extension PhotosPickerItem {
  public func toUIImage() async -> UIImage? {
    if let data = try? await self.loadTransferable(type: Data.self) {
      return UIImage(data: data)
    } else {
      return nil
    }
  }
}
