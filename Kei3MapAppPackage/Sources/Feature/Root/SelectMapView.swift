import Entity
import Extensions
import SwiftUI
import _PhotosUI_SwiftUI

public struct SelectMapView: View {
  let account: Account

  public init(account: Account) {
    self.account = account
  }

  public var body: some View {
    
    NavigationStack {
      Form {
        NavigationLink {
          let viewModel = MapViewModel(account: account)
          MapView(viewModel: viewModel)
        } label: {
          Text("SwiftUI")
        }
        
        NavigationLink {
          Text("UIKit Map")
        } label: {
          Text("UIKit")
        }
      }
    }
  }
}

