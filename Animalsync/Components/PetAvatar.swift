import SwiftUI
import UIKit

struct PetAvatar: View {
    let pet: Pet
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let image = PetAvatarService.image(for: pet.passportPhotoFilename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appBrand.opacity(0.22), Color.appBrandLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(pet.species.emoji)
                        .font(.system(size: size * 0.48))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.appBrand.opacity(0.18), lineWidth: 1.5))
        .shadow(color: Color.appBrand.opacity(0.12), radius: 4, y: 2)
        .accessibilityLabel("\(pet.name) avatar")
    }
}
