import SwiftUI

public struct MapMenuView: View {
  @Environment(\.dismiss) var dismiss

  let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
  
  let onSelectItem: (MenuItem) -> Void

  public init(onSelectItem: @escaping (MenuItem) -> Void) {
    self.onSelectItem = onSelectItem
  }

  public var body: some View {
    GeometryReader { proxy in
      let itemWidth = (proxy.size.width - 64) / 3
      VStack {
        Spacer()
        
        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
          ForEach(MenuItem.allCases, id: \.self) { item in
            Button {
              dismiss()
              onSelectItem(item)
            } label: {
              VStack {
                Image(systemName: item.systemImageName)
                Text(item.rawValue)
                  .font(.caption2)
                  .padding(.top, 4)
              }
              .padding()
              .frame(width: itemWidth, height: itemWidth)
              .background(Color.white)
              .clipShape(.rect(cornerRadius: 15))
            }
          }
        }
        .padding(.horizontal, 16)
        
        Spacer()
        
        HStack {
          Spacer()
          Button {
            dismiss()
          } label: {
            Image(systemName: "pencil.and.scribble")
          }
          .frame(width: 56, height: 56)
          .background(Color.white)
          .clipShape(Circle())
          .padding(16)
          Spacer()
        }
      }
    }
  }
}

