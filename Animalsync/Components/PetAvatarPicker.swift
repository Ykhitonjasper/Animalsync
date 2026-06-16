import SwiftUI

struct PetAvatarPicker: View {
    let species: Species
    var image: UIImage?
    var onPickCamera: () -> Void
    var onPickLibrary: () -> Void
    var onRemove: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            ZStack(alignment: .bottomTrailing) {
                avatarPreview
                Image(systemName: "camera.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(AppTheme.brandGradient, in: Circle())
                    .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                    .offset(x: 4, y: 4)
            }

            Text("Add a photo so you can spot your pet at a glance.")
                .font(.caption)
                .foregroundStyle(Color.appMuted)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                #if !targetEnvironment(simulator)
                Button(action: onPickCamera) {
                    Label("Camera", systemImage: "camera")
                        .font(.caption.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(AppSecondaryButtonStyle())
                #endif

                Button(action: onPickLibrary) {
                    Label("Library", systemImage: "photo")
                        .font(.caption.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(AppSecondaryButtonStyle())
            }

            if image != nil {
                Button("Remove photo", role: .destructive, action: onRemove)
                    .font(.caption.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity)
        .appCard()
    }

    @ViewBuilder
    private var avatarPreview: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 112, height: 112)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.appBrand.opacity(0.25), lineWidth: 2))
                .shadow(color: Color.appBrand.opacity(0.15), radius: 8, y: 4)
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
                Text(species.emoji)
                    .font(.system(size: 48))
            }
            .frame(width: 112, height: 112)
            .overlay(Circle().strokeBorder(Color.appBrand.opacity(0.2), lineWidth: 2))
        }
    }
}
