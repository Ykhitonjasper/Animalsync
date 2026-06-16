import SwiftUI
import UIKit

struct DocumentThumbnail: View {
    let document: PetDocument

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: AppTheme.radiusSM, style: .continuous)
                    .fill(Color.appBrandLight)
                thumbnailContent
                if document.isExpired {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.red, in: Circle())
                        .padding(8)
                }
            }
            .frame(height: 124)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusSM, style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(document.title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                Text(document.category.label)
                    .font(.caption2)
                    .foregroundStyle(Color.appMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        if let url = DocumentStore.thumbnailURL(for: document),
           let uiImage = UIImage(contentsOfFile: url.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 124)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM, style: .continuous))
        } else {
            VStack(spacing: 8) {
                Image(systemName: document.category.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.appBrand)
                Text("\(document.pageCount) pg")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appMuted)
            }
        }
    }
}
