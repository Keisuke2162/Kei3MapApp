import Entity
import SwiftUI
import Kingfisher

public struct MapItemInformationSheet: View {
  private let postImageURL: URL?
  private let address: String
  private let description: String
  private let onTapSearchRoute: () -> Void

  private let gradientView: LinearGradient = .init(gradient: Gradient(colors: [.red, .green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)

  @Environment(\.dismiss) var dismiss

  public init(
    postImageURL: URL? = nil,
    address: String,
    description: String,
    onTapSearchRoute: @escaping () -> Void) {
      self.postImageURL = postImageURL
      self.address = address
      self.description = description
      self.onTapSearchRoute = onTapSearchRoute
  }

  public var body: some View {
    VStack {
      Spacer()
      HStack(spacing: 8) {
        if let postImageURL {
          RoundedRectangle(cornerRadius: 0)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
              KFImage(postImageURL)
                .resizable()
                .scaledToFill()
            }
            .frame(width: 80)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        VStack(spacing: 4) {
          Spacer()
          Text(address)
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
          Text(description)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
          Spacer()
        }
      }
      .padding(.leading, 16)
      
      Button {
        onTapSearchRoute()
        dismiss()
      } label: {
        Text("経路案内🚶")
          .font(.title3.bold())
          .tint(Color.black)
          .padding(.horizontal, 32)
          .padding(.vertical, 8)
          .background(gradientView)
      }
      .clipShape(.rect(cornerRadius: 16))
    }
    Spacer()
  }
}
