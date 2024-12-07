//
//  MapView.swift
//  Kei3MapAppPackage
//
//  Created by Kei on 2024/12/08.
//

import Entity
import MapKit
import SwiftUI

public class MapViewModel: ObservableObject {
  let items: [Post] = Post.mockItems

  public init() {
  }
}

public struct MapView: View {
  @StateObject var viewModel: MapViewModel =  MapViewModel()

  public init() {
  }

  public var body: some View {
  
    Map(interactionModes: .all) {
      ForEach(viewModel.items, id: \.id) { item in
        Annotation(item.title,
                   coordinate: .init(
                    latitude: CLLocationDegrees(floatLiteral: item.latitude),
                    longitude: CLLocationDegrees(floatLiteral: item.longitude)
                   )
        ) {
          ZStack {
            Color.white
            AsyncImage(url: item.imageURL)
              .padding(4)
          }
          .frame(width: 40, height: 40, alignment: .center)
        }
      }
    }
  }
}

//#Preview {
//  MapView()
//}
